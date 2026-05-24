package com.vocabrehearse.word_sync_service.model;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class VocabularyWordTest {

    @Test
    void preparedForExamRequiresAtLeastOneNonBlankExampleAndNoEmptySlot() {
        VocabularyWord word = new VocabularyWord();
        word.setReady(true);
        word.setExamples(List.of("A complete example."));

        assertThat(word.isPreparedForExam()).isTrue();

        word.setExamples(List.of("   "));
        assertThat(word.isPreparedForExam()).isFalse();

        word.setExamples(List.of("A complete example."));
        word.setHasEmptyExampleSlot(true);
        assertThat(word.isPreparedForExam()).isFalse();
    }
}
