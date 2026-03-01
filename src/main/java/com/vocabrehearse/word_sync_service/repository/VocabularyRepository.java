package com.vocabrehearse.word_sync_service.repository;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VocabularyRepository extends JpaRepository<VocabularyWord, Long> {
    Optional<VocabularyWord> findByWord(String word);

    @Query(value = """
    SELECT COUNT(*)
    FROM word_service.vocabulary_word v
    WHERE v.is_ready = true
      AND EXISTS (SELECT 1 FROM word_service.vocabulary_word_definitions d WHERE d.vocabulary_word_id = v.id)
      AND EXISTS (SELECT 1 FROM word_service.vocabulary_word_examples e WHERE e.vocabulary_word_id = v.id)
    """, nativeQuery = true)
    long countPreparedWords();

    @Query(value = """
    SELECT * FROM word_service.vocabulary_word v
    WHERE v.next_review_date <= CURRENT_DATE
      AND v.is_ready = true
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_definitions d
          WHERE d.vocabulary_word_id = v.id
      )
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_examples e
          WHERE e.vocabulary_word_id = v.id
      )
    ORDER BY RANDOM()
    """,
            countQuery = """
    SELECT COUNT(*) FROM word_service.vocabulary_word v
    WHERE v.next_review_date <= CURRENT_DATE
      AND v.is_ready = true
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_definitions d
          WHERE d.vocabulary_word_id = v.id
      )
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_examples e
          WHERE e.vocabulary_word_id = v.id
      )
    """,
            nativeQuery = true)
    Page<VocabularyWord> findDueWordsStrictly(Pageable pageable);

    List<VocabularyWord> findByWordContainingIgnoreCase(String query);
}