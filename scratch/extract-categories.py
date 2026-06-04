import csv

def extract_categories():
    categories = set()
    with open('e:/PROJECTS/mazhavilcostumes/apps/admin/docs/product02csv.csv', 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        # Skip the headers
        next(reader) # Products header
        next(reader) # Columns header Name,Description,Category,GST,Rent,Purchase Price,Qty
        
        for row in reader:
            if len(row) >= 3:
                cat = row[2].strip()
                if cat:
                    categories.add(cat)
                    
    print("Categories in CSV:")
    for cat in sorted(categories):
        slug = cat.lower().replace(' ', '-').replace('/', '-')
        print(f"- {cat} (slug: {slug})")

extract_categories()
