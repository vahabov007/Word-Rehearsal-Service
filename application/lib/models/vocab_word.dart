class VocabWord {
  final int id;
  final String word;
  final List<String> definitions;
  final List<String> examples;
  final String? synonyms;
  final String? antonyms;
  final String? usageFrequency;
  final String? contextParagraph;
  final bool isReady;

  VocabWord({
    required this.id,
    required this.word,
    required this.definitions,
    required this.examples,
    required this.isReady,
    this.synonyms,
    this.antonyms,
    this.usageFrequency,
    this.contextParagraph,
  });

  factory VocabWord.fromJson(Map<String, dynamic> json) {
    return VocabWord(
      id: (json['id'] ?? 0) as int,
      word: (json['word'] ?? '') as String,
      definitions: (json['definitions'] as List? ?? []).map((e) => e.toString()).toList(),
      examples: (json['examples'] as List? ?? []).map((e) => e.toString()).toList(),
      synonyms: _normalizeOptional(json['synonyms']),
      antonyms: _normalizeOptional(json['antonyms']),
      usageFrequency: _normalizeOptional(json['usageFrequency']),
      contextParagraph: _normalizeOptional(json['contextParagraph']),
      isReady: json['isReady'] == true || json['ready'] == true,
    );
  }

  static String? _normalizeOptional(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    if (s.toLowerCase() == "undefined") return null;
    return s;
  }
}