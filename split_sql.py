import re

# Read the complete SQL file
with open('database/migrations/024_import_products_complete.sql', 'r', encoding='utf-8') as f:
    content = f.read()

# Split into sections
# Section 1: Categories creation
category_section = content[content.find('-- Set variables'):content.find('-- ============================================================================')]

# Section 2: Products (split into batches of 200)
products_section = content[content.find('-- INSERT ALL PRODUCTS'):content.find('-- CREATE PRODUCT INVENTORY RECORDS')]

# Section 3: Product inventory
inventory_section = content[content.find('-- CREATE PRODUCT INVENTORY RECORDS'):]

# Split products into batches
# Split by individual INSERT statements (each ends with semicolon)
lines = products_section.split('\n')
current_statement = []
statements = []

for line in lines:
    current_statement.append(line)
    if line.strip().endswith(';'):
        statement = '\n'.join(current_statement)
        if statement.strip().startswith('INSERT INTO products'):
            statements.append(statement)
        current_statement = []

# Group into batches of 100
batch_size = 100
batches = []
for i in range(0, len(statements), batch_size):
    batch = statements[i:i+batch_size]
    batches.append('\n\n'.join(batch))

# Write category section
with open('database/migrations/024_01_categories.sql', 'w', encoding='utf-8') as f:
    f.write(category_section)
    f.write('\n')
print('Created: database/migrations/024_01_categories.sql')

# Write product batches
for i, batch in enumerate(batches):
    with open(f'database/migrations/024_02_products_batch_{i+1}.sql', 'w', encoding='utf-8') as f:
        f.write('-- ============================================================================\n')
        f.write(f'-- Product Batch {i+1}: Products {i*batch_size + 1} to {min((i+1)*batch_size, len(statements))}\n')
        f.write('-- ============================================================================\n\n')
        f.write(batch)
        f.write('\n')
    print(f'Created: database/migrations/024_02_products_batch_{i+1}.sql ({len(batch.split("INSERT INTO")) - 1} products)')

# Write inventory section
with open('database/migrations/024_03_inventory.sql', 'w', encoding='utf-8') as f:
    f.write(inventory_section)
    f.write('\n')
print('Created: database/migrations/024_03_inventory.sql')

print(f'\nTotal batches: {len(batches) + 2}')
print('Run them in order: 01 -> 02 batches -> 03')
