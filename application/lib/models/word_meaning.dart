class WordMeaning {
  final String partOfSpeech;
  final String definition;
  final String frequency;
  final List<String> synonyms;

  const WordMeaning({
    required this.partOfSpeech,
    required this.definition,
    required this.frequency,
    required this.synonyms,
  });

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    return WordMeaning(
      partOfSpeech: _cleanText(
        json['partOfSpeech'] ?? json['part_of_speech'] ?? json['pos'],
        fallback: 'General',
      ),
      definition: _cleanText(json['definition'] ?? json['meaning']),
      frequency: _cleanText(
        json['frequency'] ?? json['usageFrequency'] ?? json['usage_frequency'],
        fallback: 'Common',
      ),
      synonyms: _cleanStringList(json['synonyms']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'frequency': frequency,
      'synonyms': synonyms,
    };
  }

  static WordMeaning fromLegacyDefinition({
    required String definition,
    String? partOfSpeech,
    String? frequency,
    List<String> synonyms = const [],
  }) {
    return WordMeaning(
      partOfSpeech: _cleanText(partOfSpeech, fallback: 'General'),
      definition: _cleanText(definition),
      frequency: _cleanText(frequency, fallback: 'Common'),
      synonyms: synonyms,
    );
  }

  static String _cleanText(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'undefined') return fallback;
    return text;
  }

  static List<String> _cleanStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty && item.toLowerCase() != 'undefined')
          .toSet()
          .toList(growable: false);
    }

    return value
        .toString()
        .split(RegExp(r'[,;]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty && item.toLowerCase() != 'undefined')
        .toSet()
        .toList(growable: false);
  }
}
