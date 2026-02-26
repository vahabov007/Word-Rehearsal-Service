package com.vocabrehearse.word_sync_service.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class VocabularyWord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String word;

    @Column(columnDefinition = "TEXT")
    private String synonyms;

    @Column(columnDefinition = "TEXT")
    private String antonyms;

    private String usageFrequency; // common or not

    @Column(name = "next_review_date")
    private LocalDate nextReviewDate = LocalDate.now();

    @Column(name = "ease_factor")
    private Double easeFactor = 2.5;

    @Column(name = "interval_days")
    private Integer intervalDays = 0;

    @Column(name = "repetitions")
    private Integer repetitions = 0;

    @ElementCollection
    @CollectionTable(name = "vocabulary_word_definitions", schema = "word_service")
    @Column(name = "definitions", columnDefinition = "TEXT") // Add this!
    private List<String> definitions = new ArrayList<>();

    @ElementCollection
    @CollectionTable(name = "vocabulary_word_examples", schema = "word_service")
    @Column(name = "examples", columnDefinition = "TEXT") // Add this too!
    private List<String> examples = new ArrayList<>();

    @Column(name = "context_paragraph", columnDefinition = "TEXT")
    private String contextParagraph;

    private int masteryLevel = 0;
    private LocalDateTime lastRehearsed;

    @Lob // for large object
    private String imageUrl;

    @Column(name = "is_ready")
    private boolean isReady = true;

    public String getSynonyms() {
        return synonyms == null ? "Undefined" : synonyms;
    }

    public String getUsageFrequency() {
        return usageFrequency == null ? "Undefined" : usageFrequency;
    }
}