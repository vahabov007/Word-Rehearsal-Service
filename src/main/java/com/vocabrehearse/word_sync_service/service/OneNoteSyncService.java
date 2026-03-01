package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import lombok.extern.slf4j.Slf4j;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import tools.jackson.databind.JsonNode;

import java.util.ArrayList;
import java.util.List;

@Service @Slf4j
public class OneNoteSyncService {

    private final VocabService vocabService;
    private final WordImportService wordImportService;

    private final WebClient webClient;

    public OneNoteSyncService(WebClient.Builder webClient, VocabService vocabService, WordImportService wordImportService) {
        this.vocabService = vocabService;
        this.webClient = webClient.baseUrl("https://graph.microsoft.com/v1.0").build();
        this.wordImportService = wordImportService;

    }

    @Transactional
    public void processHtml(String html) {
        Document document = Jsoup.parse(html);
        Elements paragraphs = document.select("p");
        List<String> readyParagraphs  = new ArrayList<>();

        for (Element paragraph : paragraphs) {
            String text = paragraph.text();
            if (text != null && !text.trim().isEmpty()) {
                readyParagraphs.add(text);
            }
        }
        WordImportService.ParseResult result = wordImportService.parseLines(readyParagraphs);
        for (VocabularyWord word : result.getWords()) {
            vocabService.saveStrict(word, result.hasEmptyExampleSlot());
        }
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

        processHtml(htmlContent);
        log.info("The html content successfully fetched and parsed.");
    }
}
