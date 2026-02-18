package com.vocabrehearse.word_sync_service.repository;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface VocabularyRepository extends JpaRepository<VocabularyWord, Long> {
    Optional<VocabularyWord> findByWord(String word);
}