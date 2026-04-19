import csv
import random

# Massive data map for wide keyword coverage
data_map = {
    "Food": [
        "lunch {amt}", "dinner {amt}", "kema {amt}", "breakfast {amt}", "rice {amt}", "බත් {amt}", "කෑම {amt}", "kewa {amt}",
        "kottu {amt}", "hoppers {amt}", "wade {amt}", "short eats {amt}", "bakery {amt}", "tea {amt}", "coffee {amt}",
        "ubereats {amt}", "pickme food {amt}", "restaurant {amt}", "hotel bill {amt}", "snacks {amt}", "biscuit {amt}",
        "cool drink {amt}", "දවල් කෑමට {amt}", "රෑ කෑම {amt}", "තේ බොන්න {amt}", "බනිස් {amt}", "කොත්තු {amt}", "කඩෙන් කෑවා {amt}",
        "rice and curry {amt}", "burger {amt}", "pizza {amt}", "subway {amt}", "street food {amt}", "drink {amt}"
    ],
    "Transport": [
        "bus {amt}", "train {amt}", "petrol {amt}", "taxi {amt}", "බස් එකට {amt}", "කෝච්චියට {amt}", "තෙල් {amt}", "tuk {amt}",
        "pickme {amt}", "uber {amt}", "diesel {amt}", "fuel {amt}", "bike service {amt}", "car wash {amt}", "parking {amt}",
        "highway toll {amt}", "threewheel {amt}", "ticket {amt}", "season {amt}", "පෙට්‍රල් {amt}", "ඩිසල් {amt}", "ත්‍රීවීල් {amt}",
        "vehicle repair {amt}", "tire change {amt}", "auto {amt}", "transport cost {amt}", "office go {amt}", "fare {amt}"
    ],
    "Utilities": [
        "bill {amt}", "reload {amt}", "data {amt}", "wifi {amt}", "dialog {amt}", "බිල් එකට {amt}", "රීලෝඩ් {amt}",
        "current bill {amt}", "water bill {amt}", "electricity {amt}", "mobitel {amt}", "hutch {amt}", "slt bill {amt}",
        "fiber {amt}", "internet {amt}", "recharge {amt}", "gas {amt}", "ලයිට් බිල {amt}", "වතුර බිල {amt}", "ගෑස් {amt}",
        "phone bill {amt}", "home rent {amt}", "garbage fee {amt}", "broadband {amt}", "prepaid {amt}", "postpaid {amt}"
    ],
    "Shopping": [
        "clothes {amt}", "shoes {amt}", "shoppin {amt}", "ඇඳුම් ගත්තා {amt}", "බඩු ගත්තා {amt}", "daraz {amt}", "grocery {amt}",
        "supermarket {amt}", "keells {amt}", "cargills {amt}", "arpico {amt}", "shampoo {amt}", "soap {amt}", "kitchen items {amt}",
        "furniture {amt}", "watch {amt}", "bag {amt}", "tshirt {amt}", "pants {amt}", "බඩු ගත්තා {amt}", "සපත්තු {amt}",
        "vegetables {amt}", "meat {amt}", "fish {amt}", "sugar {amt}", "milk powder {amt}", "dhal {amt}", "rice bag {amt}"
    ],
    "Health": [
        "doctor {amt}", "beheth {amt}", "hospital {amt}", "pharmacy {amt}", "බෙහෙත් වලට {amt}", "ඩොක්ටර්ට {amt}",
        "medical test {amt}", "clinic {amt}", "medicine {amt}", "panadol {amt}", "dentist {amt}", "eye check {amt}",
        "vitamin {amt}", "operation {amt}", "lab {amt}", "channeling {amt}", "හොස්පිට්ල් {amt}", "ෆාමසි {amt}", "චැනලින් {amt}",
        "fitness {amt}", "physio {amt}", "dental {amt}", "ayurvedic {amt}", "health insurance {amt}"
    ],
    "Education": [
        "class fee {amt}", "book {amt}", "course {amt}", "පන්ති ගාස්තු {amt}", "පොත් වලට {amt}", "tuition {amt}",
        "exam fee {amt}", "university {amt}", "degree {amt}", "stationary {amt}", "pen and paper {amt}", "poth {amt}",
        "panthi {amt}", "workshop {amt}", "library {amt}", "online course {amt}", "udemy {amt}", "coursera {amt}",
        "කෝස් එකට {amt}", "විභාග ගාස්තු {amt}", "පෑන් පැන්සල් {amt}"
    ],
    "Entertainment": [
        "movie {amt}", "trip {amt}", "party {amt}", "game {amt}", "ට්‍රිප් {amt}", "ෆිල්ම් {amt}", "cinema {amt}",
        "netflix {amt}", "spotify {amt}", "youtube premium {amt}", "match ticket {amt}", "gaming {amt}", "beach {amt}",
        "vacation {amt}", "outing {amt}", "beer {amt}", "liquor {amt}", "club {amt}", "සෙල්ලම් කරන්න {amt}", "විනෝදෙට {amt}",
        "streaming {amt}", "adventure {amt}", "concert {amt}", "show {amt}"
    ],
    "Personal Care": [
        "salon {amt}", "barber {amt}", "makeup {amt}", "සැලෝන් එකට {amt}", "කොණ්ඩය කැපුවා {amt}", "hair cut {amt}",
        "gym {amt}", "shaving {amt}", "perfume {amt}", "skincare {amt}", "body lotion {amt}", "facewash {amt}",
        "ජිම් එකට {amt}", "මේකප් {amt}", "hair color {amt}", "trimming {amt}", "spa {amt}", "beauty {amt}", "soap {amt}"
    ],
    "Finance": [
        "loan {amt}", "insurance {amt}", "interest {amt}", "bank fee {amt}", "tax {amt}", "credit card {amt}", "payment {amt}",
        "නයි පියවන්න {amt}", "ලෝන් එකට {amt}", "ඉන්ෂුවරන්ස් {amt}", "stock {amt}", "crypto {amt}", "investment {amt}",
        "leasing {amt}", "finance {amt}", "අතමාරුව {amt}", "ණය {amt}", "අතමාරු ගත්තා {amt}"
    ],
    "Gifts & Charity": [
        "gift {amt}", "birthday {amt}", "wedding {amt}", "donation {amt}", "charity {amt}", "dansal {amt}", "pin {amt}",
        "present {amt}", "offer {amt}", "තෑගි {amt}", "ආධාර {amt}", "පින් වලට {amt}", "දානය {amt}", "බර්ත්ඩේ {amt}",
        "helping {amt}", "alms {amt}", "religious {amt}"
    ],
    "Other": [
        "other {amt}", "misc {amt}", "lost {amt}", "don't know {amt}", "unknown {amt}", "spent {amt}", "cash {amt}",
        "අතින් ගියා {amt}", "මුදල් {amt}", "වෙනත් {amt}", "නිකම්ම {amt}", "pocket money {amt}", "general {amt}"
    ]
}

def generate_csv(filename="../assets/data.csv", rows=10000):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["sentence", "category"])
        
        for _ in range(rows):
            category = random.choice(list(data_map.keys()))
            template = random.choice(data_map[category])
            
            # Randomizing the amount to make the data realistic
            amount = random.randint(20, 50000)
            
            # Building variations: amount at the end, middle, or start
            variation = random.choice([
                template.format(amt=amount),
                f"{amount} {template.replace('{amt}', '').strip()}",
                f"{template.replace('{amt}', '').strip()} Rs.{amount}",
                f"{template.replace('{amt}', '').strip()} salli {amount}"
            ])
            
            writer.writerow([variation, category])

    print(f"Dataset generated with {rows} rows across {len(data_map)} categories.")

if __name__ == "__main__":
    generate_csv()