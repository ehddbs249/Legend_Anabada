package aise.legend_anabada.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BookRegisterRequest {
    private String category;
    private String title;
    private String author;
    private String publisher;
    private String condition;
    private String dmgTag;
}
