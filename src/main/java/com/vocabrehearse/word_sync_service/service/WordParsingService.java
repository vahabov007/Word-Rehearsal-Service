package com.vocabrehearse.word_sync_service.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Locale;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service @Slf4j
public class WordParsingService {

    // Supports: résumé :, İstanbul :, əlaqə :, O'Neill :, co-operate :, Concrete : [konkrit]
    private static final Pattern WORD_HEADER =
            Pattern.compile("^([\\p{L}][\\p{L}\\p{M}\\s'\\-]*)\\s*:\\s*(\\[[^\\]]+\\])?\\s*$");

    private static final Pattern EXAMPLE =
            Pattern.compile("^Example\\s*\\d*\\s*:\\s*(.*)$", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);

    private static final Pattern SYNONYMS =
            Pattern.compile("^Synonyms\\s*:\\s*(.*)$", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);

    private static final Pattern ANTONYMS =
            Pattern.compile("^Antonyms\\s*:\\s*(.*)$", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);

    public boolean isWordHeaderLine(String text) {
        if (text == null) return false;
        String trimmedText = text.trim();
        if (trimmedText.isEmpty()) return false;
        // Locale.ROOT => It avoids cultural differences.
        String normalizedText = trimmedText.toLowerCase(Locale.ROOT);

        if (!isItWord(normalizedText)) return false;
        if (isParagraphHeader(trimmedText)) return false;

        return WORD_HEADER.matcher(trimmedText).matches();
    }


    public Optional<String> extractWordFromHeader(String text) {
        if (text == null) return Optional.empty();
        Matcher matcher = WORD_HEADER.matcher(text.trim());
        if (!matcher.matches()) return Optional.empty();

        /*
         Example : group(0) → "Concrete : [konkrit]"
                   group(1) → "Concrete"
                   group(2) → "[konkrit]"
        */

        String word = matcher.group(1);
        return word == null ? Optional.empty() : Optional.of(word.trim());
    }

    public boolean isParagraphHeader(String text) {
        if (text == null) return false;
        String trimmedText = text.trim().toLowerCase(Locale.ROOT);
        return trimmedText.equals("paragraph :") || trimmedText.equals("paragraph:");
    }

    public String tryParseSynonyms(String text) {
        if(text == null) return null;
        // It gives us Synonym words
        return matchPayload(SYNONYMS, text);
    }

    public String tryParseAntonyms(String text) {
        if(text == null) return null;
        // It gives us Antonym words
        return matchPayload(ANTONYMS, text);
    }

    public String tryParseExample(String text) {
        if(text == null) return null;
        // It gives us Examples
        return matchPayload(EXAMPLE, text);
    }

    private String matchPayload(Pattern pattern, String text) {
        if (text == null) return null;
        Matcher matcher = pattern.matcher(text.trim());
        if (!matcher.matches()) return null;

        String payload = matcher.group(1);
        return payload == null ? "" : payload.trim();
    }

    private boolean isItWord(String text)
    {
        if (text.startsWith("example")) return false;
        if (text.startsWith("synonyms")) return false;
        if (text.startsWith("antonyms")) return false;
        return true;
    }
}