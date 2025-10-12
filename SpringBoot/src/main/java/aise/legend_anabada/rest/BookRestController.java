package aise.legend_anabada.rest;

import aise.legend_anabada.dto.request.BookRegisterRequest;
import aise.legend_anabada.dto.response.AuthResponse;
import aise.legend_anabada.dto.response.Response;
import aise.legend_anabada.entity.Book;
import aise.legend_anabada.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/book")
public class BookRestController {
    @Autowired
    private BookService bookService;

    // 교재 등록
    @PostMapping("/register")
    public ResponseEntity<AuthResponse<Void>> registerBookAutomatically(@RequestHeader("Authorization") String token,
                                                                        @RequestPart("image") MultipartFile image,
                                                                        @RequestPart("data") BookRegisterRequest request) {
        AuthResponse<Void> response = bookService.registerBook(token, image, request);
        return ResponseEntity.ok(response);
    }

    // TODO 교재 정보 수정
    @PutMapping("/{bookId}/edit")
    public ResponseEntity<String> editBookInfo(@PathVariable String bookId,
                                               @RequestBody Book updatedBook) {
        bookService.editBookInfo(bookId, updatedBook);
        return ResponseEntity.ok("교재 정보 수정 완료: " + bookId);
    }

    // TODO 교재 카테고리 분류
    @PostMapping("/{bookId}/categorize")
    public ResponseEntity<String> categorizeBook(@PathVariable String bookId,
                                                 @RequestParam String department,
                                                 @RequestParam String subject,
                                                 @RequestParam int grade,
                                                 @RequestParam String examCategory) {
        bookService.categorizeBook(bookId, department, subject, grade, examCategory);
        return ResponseEntity.ok("교재 카테고리 분류 완료: " + bookId);
    }
}
