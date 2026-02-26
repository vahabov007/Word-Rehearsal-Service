package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import com.vocabrehearse.word_sync_service.repository.VocabularyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Service @RequiredArgsConstructor
public class FileSyncService {

    @Value("${app.dict.file-path}") private String filePath;

    private final VocabularyRepository vocabularyRepository;
    private final FallbackDictionaryService fallbackDictionaryService;

    private final WordNormalizationService normalization;
    private final WordParsingService parsing;

    @Transactional
    public void syncFromFile() throws IOException {
        Path path = Paths.get(filePath);
        List<String> lines = Files.readAllLines(path);
        VocabularyWord current = null;
        boolean parsingParagraph = false;
        boolean hasEmptyExampleSlot = false;
        for (String raw : lines) {
            String text = raw == null ? "" : raw.trim();
            if (text.isEmpty()) continue;

            // 1) New word header
            if (parsing.isWordHeaderLine(text)) {
                saveStrict(current, hasEmptyExampleSlot);
                current = new VocabularyWord();
                current.setWord(parsing.extractWordFromHeader(text).orElseThrow());
                initDefaults(current);
                parsingParagraph = false;
                hasEmptyExampleSlot = false;
                continue; }
            if (current == null) continue;

            // 2) Paragraph section
            if (parsing.isParagraphHeader(text)) {
                parsingParagraph = true;
                current.setContextParagraph("");
                continue;}

            // 3) Synonyms
            String syn = parsing.tryParseSynonyms(text);
            if (syn != null) {
                parsingParagraph = false;
                if (!syn.isBlank()) current.setSynonyms(syn);
                continue;}

            // 4) Antonyms
            String ant = parsing.tryParseAntonyms(text);
            if (ant != null) {
                parsingParagraph = false;
                if (!ant.isBlank()) current.setAntonyms(ant);
                continue;}

            // 5) Example lines
            WordParsingService.ExampleParse ex = parsing.tryParseExample(text);
            if (ex != null) {
                parsingParagraph = false;
                if (ex.exampleText().isBlank()) {
                    hasEmptyExampleSlot = true;
                } else {
                    current.getExamples().add(ex.exampleText());
                }
                continue;}

            // 6) Paragraph body
            if (parsingParagraph) {
                String existing = current.getContextParagraph();
                if (existing == null || existing.equalsIgnoreCase("Undefined")) existing = "";
                current.setContextParagraph((existing + " " + text).trim());
                continue;
            }

            // 7) Otherwise: definition line
            current.getDefinitions().add(text); }
        saveStrict(current, hasEmptyExampleSlot);
    }

    private void initDefaults(VocabularyWord w) {
        w.setReady(true);
        w.setUsageFrequency("Undefined");
        w.setSynonyms(null);
        w.setAntonyms(null);
        w.setContextParagraph("Undefined");
    }

    private void saveStrict(VocabularyWord vocabularyWord, boolean hasEmptyExampleSlot) {
        if (vocabularyWord == null || vocabularyWord.getWord() == null) return;
        normalization.sanitize(vocabularyWord);

        if (vocabularyWord.getDefinitions().isEmpty()) {
            String fallback = fallbackDictionaryService.requireDefinition(vocabularyWord.getWord());
            vocabularyWord.getDefinitions().add(fallback);}

        boolean ready = !(hasEmptyExampleSlot || vocabularyWord.getExamples().isEmpty());
        vocabularyWord.setReady(ready);

        normalization.sanitize(vocabularyWord);
        vocabularyWord.setReady(ready);

        vocabularyRepository.findByWord(vocabularyWord.getWord())
                .ifPresentOrElse(existing -> {
                    existing.getDefinitions().clear();
                    existing.getDefinitions().addAll(vocabularyWord.getDefinitions());
                    existing.getExamples().clear();
                    existing.getExamples().addAll(vocabularyWord.getExamples());
                    existing.setSynonyms(normalizeUndefined(vocabularyWord.getSynonyms()));
                    existing.setAntonyms(normalizeUndefined(vocabularyWord.getAntonyms()));
                    existing.setUsageFrequency(normalizeUndefined(vocabularyWord.getUsageFrequency()));

                    String para = vocabularyWord.getContextParagraph();
                    existing.setContextParagraph(para != null ? para : "Undefined");

                    existing.setReady(vocabularyWord.isReady());
                    vocabularyRepository.save(existing);
                }, () -> {
                    if (vocabularyWord.getContextParagraph() == null) vocabularyWord.setContextParagraph("Undefined");
                    vocabularyRepository.save(vocabularyWord);
                });
    }

    private String normalizeUndefined(String val) {
        if (val == null) return null;
        String t = val.trim();
        return t.equalsIgnoreCase("Undefined") ? null : t;
    }
}