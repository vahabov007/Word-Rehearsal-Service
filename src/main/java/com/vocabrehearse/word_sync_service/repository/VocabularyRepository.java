package com.vocabrehearse.word_sync_service.repository;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
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
      AND v.next_review_date <= CURRENT_DATE
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_definitions d
          WHERE d.vocabulary_word_id = v.id
            AND NULLIF(BTRIM(d.definitions), '') IS NOT NULL
      )
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_examples e
          WHERE e.vocabulary_word_id = v.id
            AND NULLIF(BTRIM(e.examples), '') IS NOT NULL
      )
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
            AND NULLIF(BTRIM(d.definitions), '') IS NOT NULL
      )
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_examples e
          WHERE e.vocabulary_word_id = v.id
            AND NULLIF(BTRIM(e.examples), '') IS NOT NULL
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
            AND NULLIF(BTRIM(d.definitions), '') IS NOT NULL
      )
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_examples e
          WHERE e.vocabulary_word_id = v.id
            AND NULLIF(BTRIM(e.examples), '') IS NOT NULL
      )
    """,
            nativeQuery = true)
    Page<VocabularyWord> findDueWordsStrictly(Pageable pageable);

    @Query(value = """
    SELECT * FROM word_service.vocabulary_word v
    WHERE LOWER(v.word) LIKE LOWER(CONCAT('%', :query, '%'))
      AND v.is_ready = true
      AND EXISTS (
          SELECT 1
          FROM word_service.vocabulary_word_examples e
          WHERE e.vocabulary_word_id = v.id
            AND NULLIF(BTRIM(e.examples), '') IS NOT NULL
      )
    ORDER BY v.word
    """, nativeQuery = true)
    List<VocabularyWord> findPreparedByWordContainingIgnoreCase(@Param("query") String query);
}
