package com.vocabrehearse.word_sync_service.model;

import jakarta.persistence.*;
import lombok.*;
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

    @ElementCollection // Stores multiple definitions/meanings
    private List<String> definitions = new ArrayList<>();

    @Column(columnDefinition = "TEXT")
    private String synonyms;

    private String usageFrequency; // common or not

    @ElementCollection
    private List<String> examples = new ArrayList<>();

    private int masteryLevel = 0;
    private LocalDateTime lastRehearsed;

    @Lob // for large objects
    private String imageUrl;
}