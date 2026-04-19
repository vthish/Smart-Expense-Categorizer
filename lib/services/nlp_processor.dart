class NLPProcessor {
  static Map<String, dynamic> process(String input) {
    String text = input.toLowerCase();
    double amount = 0;
    String category = "Other";

    // Extract amount using Regex
    RegExp regExp = RegExp(r'\d+');
    var match = regExp.firstMatch(text);
    if (match != null) {
      amount = double.tryParse(match.group(0)!) ?? 0;
    }

    // Keyword mapping for 3 languages
    Map<String, List<String>> keywords = {
      "Food": ["කෑවා", "kema", "food", "lunch", "dinner", "kewa", "bth", "rice"],
      "Transport": ["බස්", "bus", "petrol", "train", "coach", "trel", "three wheel", "the l"],
      "Entertainment": ["film", "movie", "sira", "fun", "trip", "match", "game"],
    };

    keywords.forEach((cat, words) {
      for (var word in words) {
        if (text.contains(word)) {
          category = cat;
          break;
        }
      }
    });

    return {"amount": amount, "category": category};
  }
}