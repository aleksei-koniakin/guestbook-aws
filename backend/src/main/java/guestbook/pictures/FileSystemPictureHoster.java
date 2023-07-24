package guestbook.pictures;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Component
@Profile("file")
public class FileSystemPictureHoster implements PictureHoster {
    private final FileSystemHosterSettings settings;

    public FileSystemPictureHoster(FileSystemHosterSettings settings) {
        this.settings = settings;
    }

    @Override
    public String hostPicture(BufferedImage picture) throws IOException {
        String imageName = UUID.randomUUID().toString() + ".png";
        Path filePath = Paths.get(settings.getFilePath().toString(), imageName);
        File outputFile = filePath.toFile();
        ImageIO.write(picture, "png", outputFile);
        return settings.getUrlPrefix() + "/" + imageName;
    }
}

@Controller
@Profile("file")
class FileSystemPictureController {
  private final FileSystemHosterSettings settings;

  public FileSystemPictureController(FileSystemHosterSettings settings) {
    this.settings = settings;
  }

  @GetMapping(value = "/images/{name}.png", produces = "image/png")
  public ResponseEntity<?> handle(@PathVariable("name") String imageName) throws IOException {
    Path filePath = Paths.get(settings.getFilePath().toString(), imageName + ".png");
    if (Files.isRegularFile(filePath)) {
      return ResponseEntity.ok(Files.readAllBytes(filePath));
    } else {
      return ResponseEntity.notFound().build();
    }
  }
}
