import 'word_meaning.dart';

class VocabWord {
  final int id;
  final String word;
  final List<WordMeaning> meanings;
  final List<String> examples;
  final String? antonyms;
  final String? contextParagraph;
  final bool isReady;

  const VocabWord({
    required this.id,
    required this.word,
    required this.meanings,
    required this.examples,
    required this.isReady,
    this.antonyms,
    this.contextParagraph,
  });

  factory VocabWord.fromJson(Map<String, dynamic> json) {
    final legacySynonyms = _cleanStringList(json['synonyms']);
    final usageFrequency = _cleanOptional(
      json['usageFrequency'] ?? json['usage_frequency'] ?? json['frequency'],
    );
    final parsedMeanings = _parseMeanings(
      json['meanings'] ?? json['definitions'],
      usageFrequency: usageFrequency,
      legacySynonyms: legacySynonyms,
    );

    return VocabWord(
      id: _cleanInt(json['id']),
      word: _cleanText(json['word'] ?? json['headword'], fallback: 'Untitled'),
      meanings: parsedMeanings,
      examples: _cleanStringList(json['examples'] ?? json['sentences']),
      antonyms: _cleanOptional(json['antonyms']),
      contextParagraph: _cleanOptional(json['contextParagraph']),
      isReady: json['isReady'] == true || json['ready'] == true,
    );
  }

  List<String> get definitions {
    return meanings.map((meaning) => meaning.definition).where((text) => text.isNotEmpty).toList();
  }

  String? get synonyms {
    final values = meanings.expand((meaning) => meaning.synonyms).toSet().toList();
    return values.isEmpty ? null : values.join(', ');
  }

  String? get usageFrequency => meanings.isEmpty ? null : meanings.first.frequency;

  String get primaryPartOfSpeech {
    if (meanings.isEmpty) return 'General';
    return meanings.first.partOfSpeech;
  }

  String get previewDefinition {
    final firstDefinition = definitions.firstOrNull;
    return firstDefinition == null || firstDefinition.isEmpty ? 'No definition available yet.' : firstDefinition;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meanings': meanings.map((meaning) => meaning.toJson()).toList(),
      'examples': examples,
      'antonyms': antonyms,
      'contextParagraph': contextParagraph,
      'isReady': isReady,
    };
  }

  static List<WordMeaning> _parseMeanings(
    dynamic payload, {
    required String? usageFrequency,
    required List<String> legacySynonyms,
  }) {
    if (payload is List && payload.isNotEmpty) {
      return payload.map((item) {
        if (item is Map<String, dynamic>) {
          return WordMeaning.fromJson(item);
        }
        if (item is Map) {
          return WordMeaning.fromJson(Map<String, dynamic>.from(item));
        }
        return WordMeaning.fromLegacyDefinition(
          definition: item.toString(),
          frequency: usageFrequency,
          synonyms: legacySynonyms,
        );
      }).where((meaning) => meaning.definition.isNotEmpty).toList(growable: false);
    }

    final singleDefinition = _cleanOptional(payload);
    if (singleDefinition == null) return const [];
    return [
      WordMeaning.fromLegacyDefinition(
        definition: singleDefinition,
        frequency: usageFrequency,
        synonyms: legacySynonyms,
      ),
    ];
  }

  static int _cleanInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _cleanText(dynamic value, {String fallback = ''}) {
    return _cleanOptional(value) ?? fallback;
  }

  static String? _cleanOptional(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'undefined') return null;
    return text;
  }

  static List<String> _cleanStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
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
