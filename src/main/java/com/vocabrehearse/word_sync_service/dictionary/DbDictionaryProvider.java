package com.vocabrehearse.word_sync_service.dictionary;

import com.vocabrehearse.word_sync_service.repository.VocabularyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class DbDictionaryProvider implements DictionaryProvider {

    private final VocabularyRepository repository;

    @Override
    public Optional<String> findDefinition(String word) {
        if (word == null || word.isBlank()) return Optional.empty();

        return repository.findByWord(word.trim())
                .flatMap(w -> (w.getDefinitions() == null || w.getDefinitions().isEmpty())
                        ? Optional.empty()
                        : Optional.ofNullable(w.getDefinitions().get(0)));
    }

    @Override
    public String name() {
        return "db";
    }
}