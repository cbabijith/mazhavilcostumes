import csv

csv_file_path = r"e:\PROJECTS\mazhavilcostumes\apps\admin\docs\product02csv.csv"

with open(csv_file_path, mode='r', encoding='utf-8') as f:
    line = f.readline()
    while line and not line.startswith("Name,Description"):
        line = f.readline()
    
    reader = csv.DictReader(f, fieldnames=["Name", "Description", "Category", "GST", "Rent", "Purchase Price", "Qty"])
    
    for idx, row in enumerate(reader, 1):
        name = row.get("Name", "").strip()
        if name == "SEMI-1" or name.startswith("SEMI-1-") or name.startswith("SEMI-01") or name == "SEMI-01":
            print(f"Match found! Row {idx} in CSV (Line {idx+2}): Name={name}, Description={row.get('Description')}, Category={row.get('Category')}")
            # Let's print out what row index it is overall
            # (First product starts at index 0)
            print(f"Parsed index: {idx - 1}")
