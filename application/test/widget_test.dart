import 'package:application/models/vocab_word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps multi-meaning payload safely', () {
    final word = VocabWord.fromJson({
      'id': 7,
      'word': 'Pitch',
      'meanings': [
        {
          'partOfSpeech': 'noun',
          'definition': 'The level of a sound.',
          'frequency': 'Very Common',
          'synonyms': ['tone', null, 'key'],
        },
        {
          'partOfSpeech': 'verb',
          'definition': 'To throw something.',
          'frequency': null,
          'synonyms': 'throw, toss',
        },
      ],
      'examples': ['Dogs can hear a higher pitch.'],
      'ready': true,
    });

    expect(word.word, 'Pitch');
    expect(word.meanings, hasLength(2));
    expect(word.meanings.first.synonyms, ['tone', 'key']);
    expect(word.meanings.last.frequency, 'Common');
    expect(word.examples.single, 'Dogs can hear a higher pitch.');
    expect(word.hasValidExamples, isTrue);
    expect(word.isReady, isTrue);
  });

  test('maps legacy flat definitions into meanings', () {
    final word = VocabWord.fromJson({
      'word': 'Draft',
      'definitions': ['A preliminary version.'],
      'synonyms': 'outline, sketch',
      'usageFrequency': 'Common',
    });

    expect(word.meanings.single.definition, 'A preliminary version.');
    expect(word.meanings.single.synonyms, ['outline', 'sketch']);
    expect(word.previewDefinition, 'A preliminary version.');
    expect(word.hasValidExamples, isFalse);
  });

  test('drops null and empty example slots during parsing', () {
    final word = VocabWord.fromJson({
      'word': 'Unprepared',
      'definitions': ['Not ready yet.'],
      'examples': [null, '', '   '],
    });

    expect(word.examples, isEmpty);
    expect(word.hasValidExamples, isFalse);
  });
}
