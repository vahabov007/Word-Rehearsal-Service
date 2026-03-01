package com.vocabrehearse.word_sync_service.service;

import com.vocabrehearse.word_sync_service.model.VocabularyWord;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Service @RequiredArgsConstructor
public class FileSyncService {

    @Value("${app.dict.file-path}") private String filePath;

    private final WordImportService wordImportService;
    private final VocabService vocabService;

    @Transactional
    public void syncFromFile() throws IOException {
        Path path = Paths.get(filePath);
        List<String> lines = Files.readAllLines(path);

        WordImportService.ParseResult parseResult = wordImportService.parseLines(lines);
        for (VocabularyWord word : parseResult.getWords()) {
            vocabService.saveStrict(word, false);
        }
    }
}