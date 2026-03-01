package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.exception.exceptions.WordDefinitionNotFoundException;
import com.vocabrehearse.word_sync_service.dictionary.DictionaryProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service @RequiredArgsConstructor
public class FallbackDictionaryService {

    private final WordNormalizationService wordNormalizationService;

    private final List<DictionaryProvider> providers;

    public String requireDefinition(String word) {
        if (word == null || word.trim().isEmpty()) {
            throw new WordDefinitionNotFoundException("UNKNOWN");
        }

        for (DictionaryProvider provider : providers) {
            var defOpt = provider.findDefinition(word.trim());
            if (defOpt.isPresent()) {
                String clean = wordNormalizationService.cleanText(defOpt.get());
                if (!clean.isBlank()) return clean;
            }
        }

        throw new WordDefinitionNotFoundException(word);
    }
}