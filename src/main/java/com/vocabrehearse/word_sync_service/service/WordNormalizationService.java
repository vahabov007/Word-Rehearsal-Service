package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.regex.Pattern;

@Service
public class WordNormalizationService {

    private static final Pattern FREQ =
            Pattern.compile("\\(([^)]*Common[^)]*)\\)", Pattern.CASE_INSENSITIVE);

    public void sanitize(VocabularyWord w) {
        if (w == null || w.getWord() == null) return;
        String target = w.getWord().trim().toLowerCase(Locale.ROOT);

        // Definations
        LinkedHashSet<String> defs = new LinkedHashSet<>();
        for (String d : safeList(w.getDefinitions())) {
            String clean = normalize(d);
            if (clean.isBlank()) continue;
            clean = stripFrequency(clean);
            if (clean.toLowerCase(Locale.ROOT).equals(target)) continue;
            if (!clean.isBlank()) defs.add(clean);}

        w.getDefinitions().clear();
        w.getDefinitions().addAll(defs);

        // Examples
        LinkedHashSet<String> exs = new LinkedHashSet<>();
        for (String e : safeList(w.getExamples())) {
            String clean = normalize(e);
            if (clean.isBlank()) continue;
            if (clean.toLowerCase(Locale.ROOT).equals(target)) continue;
            exs.add(clean);}

        w.getExamples().clear();
        w.getExamples().addAll(exs);
    }

    private List<String> safeList(List<String> list) {
        return list == null ? List.of() : list;
    }

    public String normalize(String s) {
        if (s == null) return "";
        return s.trim()
                .replaceAll("\\s+", " ")
                .replaceAll("^[\"'“”]+|[\"'“”]+$", "");
    }

    public String stripFrequency(String definition) {
        if (definition == null) return "";
        return FREQ.matcher(definition).replaceAll("").trim();
    }
}