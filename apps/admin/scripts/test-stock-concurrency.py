"""Verify stock locks using separate connections to a disposable local PostgreSQL.

Run with --bin pointing to PostgreSQL binaries and --port to the dedicated local
stock_test cluster. Creates a fresh database; accepts no remote host/credentials.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import time
import uuid

parser = argparse.ArgumentParser()
parser.add_argument('--bin', required=True)
parser.add_argument('--port', required=True, type=int)
args = parser.parse_args()
root = Path(__file__).resolve().parents[3]
database = 'stock_regression_' + uuid.uuid4().hex[:12]
flags = 0x08000000 if os.name == 'nt' else 0
base = [str(Path(args.bin) / 'psql'), '-h', '127.0.0.1', '-p', str(args.port),
        '-U', 'stock_test', '-X', '-qAt', '-v', 'ON_ERROR_STOP=1']


def query(sql, db=database):
    """Run SQL only on the dedicated local test cluster."""
    result = subprocess.run(base + ['-d', db, '-c', sql], capture_output=True,
                            text=True, creationflags=flags)
    if result.returncode:
        raise RuntimeError(result.stderr)
    return result.stdout.strip()


assert query('SELECT current_user', 'postgres') == 'stock_test'
query('CREATE DATABASE ' + database, 'postgres')


def fixture_id(number):
    """Return a synthetic identifier shared by every test fixture."""
    return f'00000000-0000-0000-0000-{number:012d}'


schema = (root / 'database/latest_full_schema.sql').read_text(encoding='utf-8')
tables = ['branches', 'staff', 'products', 'product_inventory', 'orders', 'order_items',
          'payments', 'order_status_history', 'order_reservations', 'cleaning_records']
setup = """
CREATE FUNCTION uuid_generate_v4() RETURNS uuid LANGUAGE sql AS $$ SELECT gen_random_uuid() $$;
DO $$ BEGIN
  IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='anon') THEN
    CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role;
  END IF;
END $$;
"""
for table in tables:
    start = schema.index(f'CREATE TABLE public.{table} (')
    setup += schema[start:schema.index('\n);', start) + 4]
    setup += f'ALTER TABLE {table} ADD PRIMARY KEY(id);'
setup += """
ALTER TABLE orders ADD COLUMN invoice_number text;
ALTER TABLE order_items ADD COLUMN original_price_per_day numeric;
ALTER TABLE order_items ADD FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE;
ALTER TABLE order_status_history ADD FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE;
ALTER TABLE product_inventory ADD FOREIGN KEY(product_id) REFERENCES products(id);
ALTER TABLE product_inventory ADD UNIQUE(product_id,branch_id);
"""
for name in ['046_atomic_order_cancellation.sql', '047_cancellation_global_stock.sql',
             '048_stock_integrity.sql', '049_stock_bounds.sql']:
    setup += (root / 'database/migrations' / name).read_text(encoding='utf-8')
result = subprocess.run(base + ['-d', database], input=setup, capture_output=True,
                        text=True, creationflags=flags)
if result.returncode:
    raise RuntimeError(result.stderr)


def reset(available=21, status='ongoing'):
    """Restore the same fixture before each contention case."""
    query(f"""TRUNCATE {','.join(tables)} CASCADE;
INSERT INTO branches(id,store_id,name,address,is_main) VALUES('{fixture_id(2)}','{fixture_id(1)}','Main','Test',true);
INSERT INTO staff(id,store_id,branch_id,name,email,role,is_active) VALUES('{fixture_id(10)}','{fixture_id(1)}','{fixture_id(2)}','Staff','staff@example.test','staff',true);
INSERT INTO products(id,store_id,name,slug,quantity,available_quantity,price_per_day) VALUES('{fixture_id(20)}','{fixture_id(1)}','FANCY-20','fancy-20',30,{available},100);
INSERT INTO product_inventory(product_id,branch_id,quantity,available_quantity) VALUES('{fixture_id(20)}','{fixture_id(2)}',30,{available});
INSERT INTO orders(id,store_id,branch_id,customer_id,status,start_date,end_date,total_amount) VALUES('{fixture_id(30)}','{fixture_id(1)}','{fixture_id(2)}','{fixture_id(40)}','{status}','2026-11-11','2026-11-14',1000);
INSERT INTO order_items(id,order_id,product_id,quantity,price_per_day) VALUES('{fixture_id(50)}','{fixture_id(30)}','{fixture_id(20)}',9,100);""")


def receive(order=30, item=50, quantity=9):
    """Build a return using synthetic fixture identifiers."""
    data = json.dumps({'items': [{'item_id': fixture_id(item), 'returned_quantity': quantity,
                                 'condition_rating': 'good'}]})
    return f"SELECT return_order_stock_safe('{fixture_id(order)}','{data}','{fixture_id(10)}');"


def race(first, second):
    """Hold the first transaction open until a second connection is blocked."""
    env = {**os.environ, 'PGAPPNAME': 'stock_lock_holder'}
    holder = subprocess.Popen(base + ['-d', database, '-c',
                              'BEGIN;' + first + 'SELECT pg_sleep(1.5);COMMIT;'],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              text=True, env=env, creationflags=flags)
    deadline = time.monotonic() + 10
    while query("SELECT count(*) FROM pg_stat_activity WHERE application_name='stock_lock_holder' AND wait_event='PgSleep'") != '1':
        if time.monotonic() > deadline or holder.poll() is not None:
            raise RuntimeError('Holder did not acquire its locks')
        time.sleep(.03)
    started = time.monotonic()
    query(second)
    elapsed = time.monotonic() - started
    _, err = holder.communicate(timeout=15)
    if holder.returncode:
        raise RuntimeError(err)
    assert elapsed > .6, 'Second connection did not wait for the held row lock'


def available():
    """Read the physical availability counter after both commits."""
    return int(query('SELECT available_quantity FROM products'))


reset()
race(receive(), receive())
assert available() == 30
assert query('SELECT count(*) FROM order_status_history') == '1'
print('PASS: simultaneous retries restore the same return once', flush=True)
reset(19)
query(f"INSERT INTO orders SELECT (jsonb_populate_record(o,jsonb_build_object('id','{fixture_id(31)}'))).* FROM orders o; INSERT INTO order_items(id,order_id,product_id,quantity,price_per_day) VALUES('{fixture_id(51)}','{fixture_id(31)}','{fixture_id(20)}',2,100)")
race(receive(), receive(31, 51, 2))
assert available() == 30
print('PASS: separate orders sharing stock preserve both returns', flush=True)
reset()
race(f"SELECT update_product_stock_safe('{fixture_id(20)}','{{\"quantity\":35,\"available_quantity\":35}}');", receive())
assert available() == 35
print('PASS: product edit racing a return preserves unavailable stock', flush=True)
reset()
delete = f"SELECT delete_order_stock_safe('{fixture_id(30)}','{fixture_id(10)}');"
race(delete, delete)
assert available() == 30
print('PASS: duplicate deletes restore outstanding stock once', flush=True)
reset(30, 'scheduled')
start = f"SELECT update_order_stock_safe('{fixture_id(30)}','{{\"status\":\"ongoing\"}}',NULL,'{fixture_id(10)}');"
race(start, start)
assert available() == 21
print('PASS: duplicate starts deduct stock once', flush=True)
print('Evidence database: ' + database + ' (local disposable cluster)')
