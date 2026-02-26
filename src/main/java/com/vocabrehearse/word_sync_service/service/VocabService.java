package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import com.vocabrehearse.word_sync_service.repository.VocabularyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Slf4j @Service @RequiredArgsConstructor
public class VocabService {

    private final VocabularyRepository vocabularyRepository;
    private final FallbackDictionaryService fallbackDictionaryService;
    private final WordParsingService wordParsingService;
    private final WordNormalizationService wordNormalizationService;

    private static final int INITIAL_INTERVAL_FIRST_SUCCESS = 1;
    private static final int INITIAL_INTERVAL_SECOND_SUCCESS = 6;
    private static final int MIN_PASSING_GRADE = 3;

    public List<VocabularyWord> findWordByText(String query) {
        return vocabularyRepository.findByWordContainingIgnoreCase(query);
    }

    @Transactional
    public void processHtml(String html) {
        Document document = Jsoup.parse(html);
        Elements paragraphs = document.select("p");

        VocabularyWord current = null;
        boolean parsingParagraph = false;
        boolean hasEmptyExampleSlot = false;

        for (Element p : paragraphs) {
            String text = p.text() == null ? "" : p.text().trim();
            if (text.isEmpty()) continue;

            // Word header
            if (wordParsingService.isWordHeaderLine(text) || isHiddenNewWord(text)) {
                saveWordStrict(current, hasEmptyExampleSlot);
                current = new VocabularyWord();
                current.setWord(extractWord(text));
                initDefaults(current);
                parsingParagraph = false;
                hasEmptyExampleSlot = false;
                continue;}

            if (current == null) continue;

            if (wordParsingService.isParagraphHeader(text)) {
                parsingParagraph = true;
                current.setContextParagraph("");
                continue;}

            String syn = wordParsingService.tryParseSynonyms(text);
            if (syn != null) {
                parsingParagraph = false;
                current.setSynonyms(syn.isBlank() ? null : syn);
                continue;}

            String ant = wordParsingService.tryParseAntonyms(text);
            if (ant != null) {
                parsingParagraph = false;
                current.setAntonyms(ant.isBlank() ? null : ant);
                continue;}

            var exampleParse = wordParsingService.tryParseExample(text);
            if (exampleParse != null) {
                parsingParagraph = false;
                if (exampleParse.exampleText().isBlank()) {
                    hasEmptyExampleSlot = true;
                } else {
                    current.getExamples().add(exampleParse.exampleText());
                }
                continue;}

            // Paragraph body
            if (parsingParagraph) {
                String existing = current.getContextParagraph();
                if (existing == null || existing.equalsIgnoreCase("Undefined")) existing = "";
                current.setContextParagraph((existing + " " + text).trim());
                continue;
            }
            String def = text.replaceAll("^\\d+\\s*-\\s*", "").trim();

            if (wordParsingService.isWordHeaderLine(def)) continue;

            if (!def.isBlank()) current.getDefinitions().add(def);
        }

        saveWordStrict(current, hasEmptyExampleSlot);
    }

    @Transactional
    public void processReviewResult(Long wordId, int grade) {
        vocabularyRepository.findById(wordId).ifPresent(word -> {
            if (grade >= MIN_PASSING_GRADE) {
                applySuccessfulReview(word, grade);
            } else {
                applyFailedReview(word);
            }
            word.setNextReviewDate(LocalDate.now().plusDays(word.getIntervalDays()));
            vocabularyRepository.save(word);
        });
    }

//    public Page<VocabularyWord> getStrictWordsForToday(int page, int size) {
//        return vocabularyRepository.findDueWordsStrictly(PageRequest.of(page, size));
//    }


    private void initDefaults(VocabularyWord vocabularyWord) {
        vocabularyWord.setReady(true);
        vocabularyWord.setSynonyms(null);
        vocabularyWord.setAntonyms(null);
        vocabularyWord.setUsageFrequency("Undefined");
        vocabularyWord.setContextParagraph("Undefined");
    }

    private boolean isHiddenNewWord(String text) {
        return text.contains(" : [") && !text.toLowerCase().startsWith("example");
    }

    private String extractWord(String headerOrHidden) {
        if (wordParsingService.isWordHeaderLine(headerOrHidden)) {
            return wordParsingService.extractWordFromHeader(headerOrHidden).orElseThrow();
        }
        // hidden format: "Concrete : [konkrit]" -> take left of ':'
        return headerOrHidden.split(":", 2)[0].trim();
    }

    private void saveWordStrict(VocabularyWord w, boolean hasEmptyExampleSlot) {
        if (w == null || w.getWord() == null) return;

        wordNormalizationService.sanitize(w);

        if (w.getDefinitions().isEmpty()) {
            String fallbackDef = fallbackDictionaryService.requireDefinition(w.getWord());
            w.getDefinitions().add(fallbackDef);
        }

        if (hasEmptyExampleSlot || w.getExamples().isEmpty()) {
            w.setReady(false);
        }

        wordNormalizationService.sanitize(w);

        vocabularyRepository.findByWord(w.getWord())
                .ifPresentOrElse(existing -> {

                    existing.getDefinitions().clear();
                    existing.getDefinitions().addAll(w.getDefinitions());

                    existing.getExamples().clear();
                    existing.getExamples().addAll(w.getExamples());

                    String syn = w.getSynonyms();
                    existing.setSynonyms("Undefined".equalsIgnoreCase(syn) ? null : syn);

                    existing.setAntonyms(w.getAntonyms());

                    String freq = w.getUsageFrequency();
                    existing.setUsageFrequency("Undefined".equalsIgnoreCase(freq) ? null : freq);

                    existing.setContextParagraph(
                            w.getContextParagraph() == null ? "Undefined" : w.getContextParagraph()
                    );

                    existing.setReady(w.isReady());

                    vocabularyRepository.save(existing);
                }, () -> {
                    if (w.getContextParagraph() == null) w.setContextParagraph("Undefined");

                    vocabularyRepository.save(w); });
    }

    private Double calculateNewEaseFactor(Double easeFactor, int grade) {
        double newEase = easeFactor + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
        return Math.max(1.3, newEase);
    }

    private void applySuccessfulReview(VocabularyWord word, int grade) {
        int repetitions = word.getRepetitions();
        int interval = (repetitions == 0) ? INITIAL_INTERVAL_FIRST_SUCCESS :
                (repetitions == 1) ? INITIAL_INTERVAL_SECOND_SUCCESS :
                        (int) Math.round(word.getIntervalDays() * (word.getEaseFactor() / 100.0));
        word.setIntervalDays(interval);
        word.setRepetitions(repetitions + 1);
        word.setEaseFactor(calculateNewEaseFactor(word.getEaseFactor(), grade));
    }

    private void applyFailedReview(VocabularyWord word) {
        word.setRepetitions(0);
        word.setIntervalDays(1);
    }
}