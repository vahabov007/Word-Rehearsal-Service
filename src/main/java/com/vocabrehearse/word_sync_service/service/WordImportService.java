package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service @RequiredArgsConstructor
public class WordImportService {

    private final WordParsingService wordParsingService;

    public ParseResult parseLines(List<String> lines) {
        List<VocabularyWord> words = new ArrayList<>();
        VocabularyWord current = null;
        boolean parsingParagraph = false;
        boolean hasEmptyExampleSlot = false;

        for (String raw : lines) {
            String text = raw == null ? "" : raw.trim();
            if (text.isEmpty()) continue;

            // New word header
            if (wordParsingService.isWordHeaderLine(text)) {
                if (current != null) {
                    words.add(current);
                }
                current = new VocabularyWord();
                current.setWord(wordParsingService.extractWordFromHeader(text).orElseThrow());
                initDefaults(current);
                parsingParagraph = false;
                hasEmptyExampleSlot = false;
                continue;
            }
            if (current == null) continue;

            // Paragraph section start
            if (wordParsingService.isParagraphHeader(text)) {
                parsingParagraph = true;
                current.setContextParagraph("");
                continue;
            }
            // Synonyms
            String synonyms = wordParsingService.tryParseSynonyms(text);
            if (synonyms != null) {
                parsingParagraph = false;
                current.setSynonyms(synonyms.isBlank() ? null : synonyms);
                continue;
            }
            // Antonyms
            String antonyms = wordParsingService.tryParseAntonyms(text);
            if (antonyms != null) {
                parsingParagraph = false;
                current.setAntonyms(antonyms.isBlank() ? null : antonyms);
                continue;
            }
            // Example
            String exampleText = wordParsingService.tryParseExample(text);
            if (exampleText != null) {
                parsingParagraph = false;
                if (exampleText.isBlank()) {
                    hasEmptyExampleSlot = true;
                } else {
                    current.getExamples().add(exampleText);
                }
                continue;
            }
            // Paragraph
            if (parsingParagraph) {
                String existing = current.getContextParagraph();
                if (existing == null || existing.equalsIgnoreCase("Undefined")) existing = "";
                current.setContextParagraph((existing + " " + text).trim());
                continue;
            }
            // Definition line
            current.getDefinitions().add(text);
        }
        if (current != null) {
            words.add(current);
        }
        return new ParseResult(words, hasEmptyExampleSlot);
    }

    private void initDefaults(VocabularyWord vocabularyWord) {
        vocabularyWord.setReady(true);
        vocabularyWord.setUsageFrequency("Undefined");
        vocabularyWord.setSynonyms(null);
        vocabularyWord.setAntonyms(null);
        vocabularyWord.setContextParagraph("Undefined");
    }

    public static class ParseResult {
        @Getter
        private final List<VocabularyWord> words;
        private final boolean hasEmptyExampleSlot;

        public ParseResult(List<VocabularyWord> words, boolean hasEmptyExampleSlot) {
            this.words = words;
            this.hasEmptyExampleSlot = hasEmptyExampleSlot;
        }

        public boolean hasEmptyExampleSlot() {
            return hasEmptyExampleSlot;
        }
    }
}
