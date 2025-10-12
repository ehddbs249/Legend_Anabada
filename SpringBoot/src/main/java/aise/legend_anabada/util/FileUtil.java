package aise.legend_anabada.util;

import aise.legend_anabada.config.AppProperties;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Component
public class FileUtil {

    private final AppProperties appProperties;

    public FileUtil(AppProperties appProperties) {
        this.appProperties = appProperties;
    }

    public String save(MultipartFile file, String fileName) throws IOException {
        Path path = Paths.get(appProperties.getUpload_dir() + fileName);
        Files.createDirectories(path.getParent());
        file.transferTo(path.toFile());
        return path.toString();
    }
}