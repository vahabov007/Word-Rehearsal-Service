package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import com.vocabrehearse.word_sync_service.repository.VocabularyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Slf4j @Service @RequiredArgsConstructor
public class VocabService {

    private final VocabularyRepository vocabularyRepository;

    private final FallbackDictionaryService fallbackDictionaryService;
    private final WordNormalizationService wordNormalizationService;

    private static final int INITIAL_INTERVAL_FIRST_SUCCESS = 1;
    private static final int INITIAL_INTERVAL_SECOND_SUCCESS = 6;
    private static final int MIN_PASSING_GRADE = 3;

    public List<VocabularyWord> findWordByText(String query) {
        return vocabularyRepository.findByWordContainingIgnoreCase(query);
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

    @Transactional
    public void saveStrict(VocabularyWord vocabularyWord, boolean hasEmptyExampleSlot) {
        if (vocabularyWord == null || vocabularyWord.getWord() == null) return;
        wordNormalizationService.normalizeContent(vocabularyWord);

        if (vocabularyWord.getDefinitions().isEmpty()) {
            String fallback = fallbackDictionaryService.requireDefinition(vocabularyWord.getWord());
            vocabularyWord.getDefinitions().add(fallback);
        }

        boolean ready = !(hasEmptyExampleSlot || vocabularyWord.getExamples().isEmpty());
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

                    String contextParagraph = vocabularyWord.getContextParagraph();
                    existing.setContextParagraph(contextParagraph != null ? contextParagraph : "Undefined");

                    existing.setReady(vocabularyWord.isReady());
                    vocabularyRepository.save(existing);
                }, () -> {
                    if (vocabularyWord.getContextParagraph() == null) vocabularyWord.setContextParagraph("Undefined");
                    vocabularyRepository.save(vocabularyWord);
                });
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

    private String normalizeUndefined(String value) {
        if (value == null) return null;
        String trimmedValue = value.trim();
        return trimmedValue.equalsIgnoreCase("Undefined") ? null : trimmedValue;
    }
}

//    public Page<VocabularyWord> getStrictWordsForToday(int page, int size) {
//        return vocabularyRepository.findDueWordsStrictly(PageRequest.of(page, size));
//    }