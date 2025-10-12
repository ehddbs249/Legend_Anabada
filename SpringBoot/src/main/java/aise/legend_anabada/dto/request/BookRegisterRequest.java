package aise.legend_anabada.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BookRegisterRequest {
    private String title;
    private String author;
    private String isbn;
    private String publisher;
    private String originalPrice;
    private String department;
    private String subject;
    private String condition;
}
