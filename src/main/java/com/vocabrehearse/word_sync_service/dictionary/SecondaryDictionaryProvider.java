package com.vocabrehearse.word_sync_service.dictionary;

import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class SecondaryDictionaryProvider implements DictionaryProvider {

    @Override
    public Optional<String> findDefinition(String word) {
        return Optional.empty();
    }

    @Override
    public String name() {
        return "";
    }
}