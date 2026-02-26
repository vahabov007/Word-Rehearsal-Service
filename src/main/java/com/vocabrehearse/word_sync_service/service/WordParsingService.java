package com.vocabrehearse.word_sync_service.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Locale;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service @Slf4j
public class WordParsingService {

    private static final Pattern WORD_HEADER =
            Pattern.compile("^([A-Za-z][A-Za-z\\s'\\-]*)\\s*:\\s*(\\[[^\\]]+\\])?\\s*$");

    private static final Pattern EXAMPLE =
            Pattern.compile("^Example\\s*\\d*\\s*:\\s*(.*)$", Pattern.CASE_INSENSITIVE);

    private static final Pattern SYNONYMS =
            Pattern.compile("^Synonyms\\s*:\\s*(.*)$", Pattern.CASE_INSENSITIVE);

    private static final Pattern ANTONYMS =
            Pattern.compile("^Antonyms\\s*:\\s*(.*)$", Pattern.CASE_INSENSITIVE);

    public boolean isWordHeaderLine(String text) {
        if (text == null) return false;
        String t = text.trim();
        if (t.isEmpty()) return false;

        String lower = t.toLowerCase(Locale.ROOT);

        if (lower.startsWith("example")) return false;
        if (lower.startsWith("synonyms")) return false;
        if (lower.startsWith("antonyms")) return false;
        if (isParagraphHeader(t)) return false;

        return WORD_HEADER.matcher(t).matches();
    }

    public Optional<String> extractWordFromHeader(String text) {
        if (text == null) return Optional.empty();
        Matcher m = WORD_HEADER.matcher(text.trim());
        if (!m.matches()) return Optional.empty();

        String word = m.group(1);
        return word == null ? Optional.empty() : Optional.of(word.trim());
    }

    public boolean isParagraphHeader(String text) {
        if (text == null) return false;
        String t = text.trim().toLowerCase(Locale.ROOT);
        return t.equals("paragraph :") || t.equals("paragraph:");
    }

    public String tryParseSynonyms(String text) {
        return matchPayload(SYNONYMS, text);
    }

    public String tryParseAntonyms(String text) {
        return matchPayload(ANTONYMS, text);
    }

    public ExampleParse tryParseExample(String text) {
        String payload = matchPayload(EXAMPLE, text);
        if (payload == null) return null;
        return new ExampleParse(payload);
    }

    private String matchPayload(Pattern pattern, String text) {
        if (text == null) return null;
        Matcher m = pattern.matcher(text.trim());
        if (!m.matches()) return null;

        String payload = m.group(1);
        return payload == null ? "" : payload.trim();
    }

    public record ExampleParse(String exampleText) {}
}