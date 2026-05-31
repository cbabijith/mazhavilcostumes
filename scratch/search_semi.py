import csv

csv_file_path = r"e:\PROJECTS\mazhavilcostumes\apps\admin\docs\product02csv.csv"

with open(csv_file_path, mode='r', encoding='utf-8') as f:
    line = f.readline()
    while line and not line.startswith("Name,Description"):
        line = f.readline()
    
    reader = csv.DictReader(f, fieldnames=["Name", "Description", "Category", "GST", "Rent", "Purchase Price", "Qty"])
    
    count = 0
    for idx, row in enumerate(reader, 1):
        cat = row.get("Category", "").strip()
        if "Semi" in cat or "semi" in cat:
            print(f"Row {idx}: Name={row.get('Name')}, Description={row.get('Description')}, Category={cat}")
            count += 1
            if count >= 20:
                break
