package aise.legend_anabada.restController;

import aise.legend_anabada.entity.Book;
import aise.legend_anabada.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/book")
public class BookController {
    @Autowired
    private BookService bookService;

    // ------------------- 교재 자동 등록 -------------------
    @PostMapping("/register/auto")
    public ResponseEntity<String> registerBookAutomatically(@RequestBody Book book) {
        bookService.registerBookAutomatically(book);
        return ResponseEntity.ok("교재 자동 등록 완료: " + book.getTitle());
    }

    // ------------------- 교재 수동 등록 -------------------
    @PostMapping("/register/manual")
    public ResponseEntity<String> registerBookManually(@RequestBody Book book) {
        bookService.registerBookManually(book);
        return ResponseEntity.ok("교재 수동 등록 완료: " + book.getTitle());
    }

    // ------------------- 교재 정보 수정 -------------------
    @PutMapping("/{bookId}/edit")
    public ResponseEntity<String> editBookInfo(@PathVariable String bookId,
                                               @RequestBody Book updatedBook) {
        bookService.editBookInfo(bookId, updatedBook);
        return ResponseEntity.ok("교재 정보 수정 완료: " + bookId);
    }

    // ------------------- 교재 카테고리 분류 -------------------
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
