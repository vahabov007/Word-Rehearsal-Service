package com.vocabrehearse.word_sync_service.exception.exceptions;

public class WordDefinitionNotFoundException extends RuntimeException {
    public WordDefinitionNotFoundException(String word) {
        super("No valid definition could be found for word: " + word);
    }
}