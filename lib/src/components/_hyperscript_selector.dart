class Selector {
  // Regular expressions to extract the tag name, id, and classes.
  static final _tagNameRegex = RegExp(r'^([a-zA-Z]+)?');
  static final _idRegex = RegExp(r'#([a-zA-Z0-9_-]+)');
  static final _classRegex = RegExp(r'\.([a-zA-Z0-9_-]+)');

  String tagName;
  String? id;
  List<String> classes;

  Selector({required this.tagName, this.id, required this.classes});

  factory Selector.parse(String selector) {
    String tagName = 'div'; // Default tag name.
    String? id;
    List<String> classes = [];

    // Extract the tag name.
    final tagMatch = _tagNameRegex.firstMatch(selector);
    if (tagMatch != null && tagMatch.group(1) != null) {
      tagName = tagMatch.group(1)!;
      selector = selector.substring(tagMatch.group(0)!.length);
    }

    // Extract ID.
    final idMatch = _idRegex.firstMatch(selector);
    if (idMatch != null) {
      id = idMatch.group(1);
      selector = selector.substring(idMatch.group(0)!.length);
    }

    // Extract classes.
    final classMatches = _classRegex.allMatches(selector);
    for (final match in classMatches) {
      classes.add(match.group(1)!);
    }

    return Selector(tagName: tagName, id: id, classes: classes);
  }
}
