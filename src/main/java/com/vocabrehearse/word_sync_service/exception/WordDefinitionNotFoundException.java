package com.vocabrehearse.word_sync_service.exception;

public class WordDefinitionNotFoundException extends RuntimeException {
    public WordDefinitionNotFoundException(String word) {
        super("No valid definition could be found for word: " + word);
    }
}