package com.vocabrehearse.word_sync_service.dictionary;

import java.util.Optional;

public interface DictionaryProvider {
    Optional<String> findDefinition(String word);
    String name();
}