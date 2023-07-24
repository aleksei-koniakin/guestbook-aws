package guestbook.pictures;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Component
@ConfigurationProperties(prefix = "guestbook.pictures.local")
public class FileSystemHosterSettings {
    private Path filePath = Paths.get("build/local-db").toAbsolutePath();
    private String urlPrefix = "http://localhost:8080/images";

    public Path getFilePath() {
        try {
            Files.createDirectories(filePath);
        } catch (IOException e) {
            throw new RuntimeException("Failed to create local paths at " + filePath + ". " + e.getMessage(), e);
        }
        return filePath;
    }

    public void setFilePath(Path filePath) {
        this.filePath = filePath;
    }

    public String getUrlPrefix() {
        return urlPrefix;
    }

    public void setUrlPrefix(String urlPrefix) {
        this.urlPrefix = urlPrefix;
    }
}
