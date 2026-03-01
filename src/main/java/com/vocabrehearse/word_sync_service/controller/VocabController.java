package com.vocabrehearse.word_sync_service.controller;

import com.vocabrehearse.word_sync_service.dto.GradeRequest;
import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import com.vocabrehearse.word_sync_service.repository.VocabularyRepository;
import com.vocabrehearse.word_sync_service.service.FileSyncService;
import com.vocabrehearse.word_sync_service.service.OneNoteSyncService;
import com.vocabrehearse.word_sync_service.service.VocabService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController @RequiredArgsConstructor
@RequestMapping("/api/v1/words")
@Tag(name = "Mobile Rehearsal API",
     description = "Endpoints for your phone to fetch words")
public class VocabController {

    private final VocabularyRepository repository;
    private final VocabService vocabService;
    private final OneNoteSyncService oneNoteSyncService;
    private final FileSyncService fileSyncService;

    @PostMapping("/sync")
    @Operation(summary = "Real sync: Pulls 'My English Words' from OneNote")
    public ResponseEntity<String> syncWithOneNote(@RegisteredOAuth2AuthorizedClient("graph")OAuth2AuthorizedClient auth2AuthorizedClient) {
        String accessToken = auth2AuthorizedClient.getAccessToken().getTokenValue();
        oneNoteSyncService.syncMyEnglishWord(accessToken);
        return ResponseEntity.ok("Synchronization with OneNote successful!");
    }

    @GetMapping("/rehearse")
    public ResponseEntity<Page<VocabularyWord>> getWordsForPractice(@RequestParam(defaultValue = "0") int page,
                                                                    @RequestParam(defaultValue = "10") int size) {

        PageRequest pageRequest = PageRequest.of(page, size);
        Page<VocabularyWord> dueWords = repository.findDueWordsStrictly(pageRequest);

        return ResponseEntity.ok(dueWords);
    }

    @PostMapping("/{id}/grade")
    @Operation(summary = "Submit a rehearsal grade via JSON body")
    public ResponseEntity<Void> submitReview(@PathVariable Long id,
                                             @Valid @RequestBody GradeRequest gradeRequest) {
        vocabService.processReviewResult(id, gradeRequest.getGrade());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/file")
    @Operation(summary = "File sync: every word stores in word.txt file.")
    public ResponseEntity<String> syncFromFile() {
        try {
            fileSyncService.syncFromFile();
            return ResponseEntity.ok("Sync successful!");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    @GetMapping("/count-due")
    @Operation(summary = "Get the number of words waiting for review")
    public ResponseEntity<Long> getDueCount() {
        return ResponseEntity.ok(repository.countPreparedWords());
    }

    @GetMapping("/search")
    @Operation(summary = "Search for specific words by text")
    public ResponseEntity<List<VocabularyWord>> searchWords(@RequestParam String query) {
        List<VocabularyWord> results = vocabService.findWordByText(query);
        return ResponseEntity.ok(results);
    }


}

//    @GetMapping("/today")
//    @Operation(summary = "Get the list of words to practice today")
//    public ResponseEntity<List<VocabularyWord>> getDailyRehearsal() {
//        List<VocabularyWord> words = vocabService.getStrictWordsForToday();
//
//        if (words.isEmpty()) {
//            return ResponseEntity.noContent().build(); // Phone shows "Great job! All caught up."
//        }
//
//        return ResponseEntity.ok(words);
//    }


