package com.vocabrehearse.word_sync_service.controller;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import com.vocabrehearse.word_sync_service.repository.VocabularyRepository;
import com.vocabrehearse.word_sync_service.service.OneNoteSyncService;
import com.vocabrehearse.word_sync_service.service.VocabService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.client.OAuth2AuthorizationContext;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/words")
@RequiredArgsConstructor
@Tag(name = "Mobile Rehearsal API",
     description = "Endpoints for your phone to fetch words")
public class VocabController {

    private final VocabularyRepository repository;
    private final VocabService vocabService;
    private final OneNoteSyncService oneNoteSyncService;

    @PostMapping("/sync")
    @Operation(summary = "Real sync: Pulls 'My English Words' from OneNote")
    public ResponseEntity<String> syncWithOneNote(@RegisteredOAuth2AuthorizedClient("graph")OAuth2AuthorizedClient auth2AuthorizedClient) {
        String accessToken = auth2AuthorizedClient.getAccessToken().getTokenValue();
        oneNoteSyncService.syncMyEnglishWord(accessToken);
        return ResponseEntity.ok("Synchronization with OneNote successful!");

    }

    @GetMapping("/rehearse")
    @Operation(summary = "Fetch words that are due for review based on Spaced Repetition")
    public Page<VocabularyWord> getWordsForPractice(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        return null;

    }


}


