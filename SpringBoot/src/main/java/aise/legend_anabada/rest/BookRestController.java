package aise.legend_anabada.rest;

import aise.legend_anabada.config.Status;
import aise.legend_anabada.config.exception.ExpiredTokenException;
import aise.legend_anabada.dto.request.BookRegisterRequest;
import aise.legend_anabada.dto.response.AuthResponse;
import aise.legend_anabada.dto.response.Response;
import aise.legend_anabada.entity.Book;
import aise.legend_anabada.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Stack;

@RestController
@RequestMapping("/api/book")
public class BookRestController {
    @Autowired
    private BookService bookService;

    // 교재 등록
    @PostMapping("/register")
    public ResponseEntity<AuthResponse<Void>> registerBookAutomatically(@RequestHeader("Authorization") String token,
                                                                        @RequestPart("images") List<MultipartFile> images,
                                                                        @RequestPart("data") BookRegisterRequest request) {
        try {
            AuthResponse<Void> response = bookService.registerBook(token, images, request);
            return ResponseEntity.ok(response);
        } catch (ExpiredTokenException e) {
            return ResponseEntity.status(Status.UNAUTHORIZED)
                    .body(new AuthResponse<>(false, null, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(Status.INTERNAL_SERVER_ERROR)
                    .body(new AuthResponse<>(false, null, e.getMessage(), null));
        }
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
