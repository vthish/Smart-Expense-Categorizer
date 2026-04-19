import csv
import random

data_map = {
    "Food": ["lunch {amt}", "dinner {amt}", "kema {amt}", "breakfast {amt}", "rice {amt}", "බත් {amt}", "කෑම {amt}", "kewa {amt}"],
    "Transport": ["bus {amt}", "train {amt}", "petrol {amt}", "taxi {amt}", "බස් එකට {amt}", "කෝච්චියට {amt}", "තෙල් {amt}", "tuk {amt}"],
    "Utilities": ["bill {amt}", "reload {amt}", "data {amt}", "wifi {amt}", "dialog {amt}", "බිල් එකට {amt}", "රීලෝඩ් {amt}"],
    "Entertainment": ["movie {amt}", "trip {amt}", "party {amt}", "game {amt}", "ට්‍රිප් {amt}", "ෆිල්ම් {amt}"],
    "Health": ["doctor {amt}", "beheth {amt}", "hospital {amt}", "pharmacy {amt}", "බෙහෙත් වලට {amt}", "ඩොක්ටර්ට {amt}"],
    "Shopping": ["clothes {amt}", "shoes {amt}", "shoppin {amt}", "ඇඳුම් ගත්තා {amt}", "බඩු ගත්තා {amt}"],
    "Education": ["class fee {amt}", "book {amt}", "course {amt}", "පන්ති ගාස්තු {amt}", "පොත් වලට {amt}"],
    "Personal Care": ["salon {amt}", "barber {amt}", "makeup {amt}", "සැලෝන් එකට {amt}", "කොණ්ඩය කැපුවා {amt}"],
}

def generate_csv(filename="../assets/data.csv", rows=3000):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["sentence", "category"])
        for _ in range(rows):
            category = random.choice(list(data_map.keys()))
            template = random.choice(data_map[category])
            amount = random.randint(100, 5000)
            writer.writerow([template.format(amt=amount), category])
    print(f"Dataset generated with {rows} rows.")

if __name__ == "__main__":
    generate_csv()