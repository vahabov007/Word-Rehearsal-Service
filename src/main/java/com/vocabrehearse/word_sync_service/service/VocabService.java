package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import com.vocabrehearse.word_sync_service.repository.VocabularyRepository;
import lombok.RequiredArgsConstructor;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service @RequiredArgsConstructor
public class VocabService {

    private final VocabularyRepository vocabularyRepository;

    public void processHtml(String html) {
        Document document = Jsoup.parse(html);
         Elements paragraphs = document.select("p");
         VocabularyWord currentWord = null;

         for (Element paragraph : paragraphs) {
             String text = paragraph.text().trim();

             // 1. Identify Word Header (e.g., "Strap :", "Convict :", "Weep :")
             if (text.matches("^[A-Za-z\\s]+ :$")) {
                 if (currentWord != null) {
                     VocabularyWord finalWord = currentWord;
                     vocabularyRepository.findByWord(currentWord.getWord())
                             .ifPresentOrElse(
                                     existing -> {
                                         // Update existing record with new definitions/examples
                                         existing.setDefinitions(finalWord.getDefinitions());
                                         existing.setExamples(finalWord.getExamples());
                                         existing.setSynonyms(finalWord.getSynonyms());
                                         existing.setImageUrl(finalWord.getImageUrl());
                                         vocabularyRepository.save(existing);
                                     },
                                     () -> vocabularyRepository.save(finalWord) // Save as new
                             );
                 }
                 currentWord = new VocabularyWord();
                 currentWord.setWord(text.replace(":", "").trim());
                 continue;
             }
             if (currentWord == null) continue;
             if (text.matches("^\\d+ - .*")) {
                 currentWord.getDefinitions().add(text);
                 extractFrequency(text, currentWord);
                 // The delimiter itself is removed (Synonyms :)
             } else if (text.contains("Synonyms :")) {
                 // This regex captures everything after 'Synonyms :'
                 // but STOPS before it hits 'Example' or the end of the line ($)
                 Pattern synonymPattern = Pattern.compile("Synonyms\\s*:\\s*(.*?)(?=\\bExample\\b|$)");
                 Matcher matcher = synonymPattern.matcher(text);
                 if (matcher.find()) {
                     String rawSynonyms = matcher.group(1).trim();
                     if (rawSynonyms.endsWith(".")) {
                         rawSynonyms = rawSynonyms.substring(0, rawSynonyms.length() - 1);
                     }
                     currentWord.setSynonyms(rawSynonyms);
                 }
             } else if (text.contains("Example")) {
                 String examplePart = text.split(":", 2)[1].trim();
                 if (!examplePart.isEmpty()) {
                     currentWord.getExamples().add(examplePart);
                 }
             }
             Element image = paragraph.selectFirst("img");
             if (image != null) {
                 // The src (source) attribute contains the URL.
                 currentWord.setImageUrl(image.attr("src"));
             }
         }
    }

    private void extractFrequency(String text, VocabularyWord word) {
        Pattern pattern = Pattern.compile("\\(([^)]*Common[^)]*)\\)");
        Matcher matcher = pattern.matcher(text);

        if(matcher.find()) {
            word.setUsageFrequency(matcher.group(1).trim());
        } else {
            word.setUsageFrequency("Undefined");
        }

    }
}