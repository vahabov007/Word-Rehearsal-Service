package com.vocabrehearse.word_sync_service.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import tools.jackson.databind.JsonNode;

@Service
@Slf4j
public class OneNoteSyncService {

    private final VocabService vocabService;
    private final WebClient webClient;

    public OneNoteSyncService(WebClient.Builder webClient, VocabService vocabService) {
        this.vocabService = vocabService;
        this.webClient = webClient.baseUrl("https://graph.microsoft.com/v1.0").build();

    }

    public void syncMyEnglishWord(String accessToken) {
        JsonNode response = this.webClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/me/onenote/pages")
                        .queryParam("$filter", "title eq 'My English Words'")
                        .queryParam("$select", "id,title") // double check
                        .build())
                .headers(httpHeaders -> httpHeaders.setBearerAuth(accessToken))
                .retrieve()
                .bodyToMono(JsonNode.class)
                .block();

        /*
        the response can be like that :
        {
            "@odata.context": "...",
            "value": [
            { "id": "123", "title": "My English Words" }
             ]
        }
        */
        // Because of that we are getting value.

        if (response != null && response.has("value") && response.get("value").isArray()) {
            String pageId = response.get("value").get(0).get("id").asText();
            getAndParseContent(pageId, accessToken);

        }


    }

    public void getAndParseContent(String pageId, String accessToken) {
        String htmlContent = this.webClient.get()
                .uri("/me/onenote/pages/{id}/content", pageId)
                .headers(httpHeaders -> httpHeaders.setBearerAuth(accessToken))
                .retrieve() // Send these to Microsoft's servers.
                .bodyToMono(String.class)
                .block();

        vocabService.processHtml(htmlContent);

        log.info("The html content successfully fetched and parsed.");
    }


}
