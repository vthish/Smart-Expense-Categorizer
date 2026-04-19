import csv
import random

# Categories and keywords in Sinhala, Singlish, and English
data_map = {
    "Food": {
        "templates": [
            "kama walata {amt}", "{amt} kewa", "lunch ekata {amt}", "kema gaththa {amt}",
            "breakfast {amt}", "dinner ekata {amt}", "bth kawa {amt}", "tea ekata {amt}",
            "කෑම වලට {amt}", "දවල් කෑමට {amt}", "{amt} කෑමට ගියා", "රෑ කෑම {amt}",
            "Spent {amt} for food", "Lunch cost {amt}", "Buy snacks {amt}"
        ]
    },
    "Transport": {
        "templates": [
            "bus ekata {amt}", "{amt} petrol", "train ticket {amt}", "threewheel ekata {amt}",
            "pickme {amt}", "uber ekata {amt}", "trel walata {amt}", "petrol gahuwa {amt}",
            "බස් එකට {amt}", "{amt} පෙට්‍රල් වලට", "කෝච්චියට {amt}", "ත්‍රීවීල් එකට {amt}",
            "Spent {amt} for bus", "Petrol cost {amt}", "Taxi fare {amt}"
        ]
    },
    "Entertainment": {
        "templates": [
            "film ekata {amt}", "movie ticket {amt}", "trip ekata {amt}", "match ekata {amt}",
            "game reload {amt}", "fun ekata {amt}", "party {amt}", "cinema {amt}",
            "ෆිල්ම් එකට {amt}", "ට්‍රිප් එකට {amt}", "සෙල්ලම් කරන්න {amt}", "මූවී එකට {amt}",
            "Spent {amt} for movie", "Trip expenses {amt}", "Gaming {amt}"
        ]
    }
}

def generate_csv(filename="assets/data.csv", rows=1000):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["sentence", "category"])
        
        for _ in range(rows):
            category = random.choice(list(data_map.keys()))
            template = random.choice(data_map[category]["templates"])
            amount = random.randint(20, 5000) # Random amount between 20 and 5000
            
            sentence = template.format(amt=amount)
            writer.writerow([sentence, category])

    print(f"Success! {filename} generated with {rows} rows.")

if __name__ == "__main__":
    generate_csv()