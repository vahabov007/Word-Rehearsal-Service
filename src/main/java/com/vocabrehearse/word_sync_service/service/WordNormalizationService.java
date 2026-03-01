package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.regex.Pattern;

@Service
public class WordNormalizationService {

    // Common or not regex
    private static final Pattern FREQ =
            Pattern.compile("\\(([^)]*Common[^)]*)\\)", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);

    public void normalizeContent(VocabularyWord content) {
        if (content == null || content.getWord() == null) return;
        String target = content.getWord().trim().toLowerCase(Locale.ROOT);

        // Definitions
        LinkedHashSet<String> definitions = new LinkedHashSet<>();
        for (String definition : getSafeList(content.getDefinitions())) {
            String cleanedText = cleanText(definition);
            if (cleanedText.isBlank()) continue;
            cleanedText = removeFrequencyTag(cleanedText);
            if (cleanedText.toLowerCase(Locale.ROOT).equals(target)) continue;
            if (!cleanedText.isBlank()) definitions.add(cleanedText);
        }

        // Remove old definitions
        content.getDefinitions().clear();
        content.getDefinitions().addAll(definitions);

        // Examples
        LinkedHashSet<String> examples = new LinkedHashSet<>();
        for (String example : getSafeList(content.getExamples())) {
            String clean = cleanText(example);
            if (clean.isBlank()) continue;
            if (clean.toLowerCase(Locale.ROOT).equals(target)) continue;
            examples.add(clean);
        }

        content.getExamples().clear();
        content.getExamples().addAll(examples);
    }

    private List<String> getSafeList(List<String> list) {
        return list == null ? List.of() : list;
    }

    public String cleanText(String text) {
        if (text == null) return "";
        return text.trim()
                // "\\s+" -> Replaces any sequence of whitespace with a single space.
                .replaceAll("\\s+", " ")
                .replaceAll("^[\"'“”]+|[\"'“”]+$", "");
    }

    public String removeFrequencyTag(String definition) {
        if (definition == null) return "";
        return FREQ.matcher(definition).replaceAll("").trim();
    }
}