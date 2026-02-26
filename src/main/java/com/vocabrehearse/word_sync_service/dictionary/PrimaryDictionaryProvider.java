package com.vocabrehearse.word_sync_service.dictionary;

import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class PrimaryDictionaryProvider implements DictionaryProvider {

    @Override
    public Optional<String> findDefinition(String word) {
        // primary lookup logic here
        return Optional.empty();
    }

    @Override
    public String name() {
        return "primary";
    }
}