package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class WordImportServiceTest {

    private final WordImportService wordImportService = new WordImportService(new WordParsingService());

    @Test
    void emptyExampleSlotIsTrackedPerWord() {
        WordImportService.ParseResult result = wordImportService.parseLines(List.of(
                "Draft:",
                "A preliminary version.",
                "Example 1:",
                "Pitch:",
                "The level of a sound.",
                "Example 1: Dogs can hear sounds with a higher pitch."
        ));

        VocabularyWord draft = result.getWords().get(0);
        VocabularyWord pitch = result.getWords().get(1);

        assertThat(draft.isHasEmptyExampleSlot()).isTrue();
        assertThat(draft.getExamples()).isEmpty();
        assertThat(pitch.isHasEmptyExampleSlot()).isFalse();
        assertThat(pitch.getExamples()).containsExactly("Dogs can hear sounds with a higher pitch.");
    }
}
