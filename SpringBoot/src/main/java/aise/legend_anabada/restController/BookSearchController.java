package aise.legend_anabada.restController;

import aise.legend_anabada.entity.Book;
import aise.legend_anabada.service.BookSearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/search")
public class BookSearchController {
    @Autowired
    private BookSearchService bookSearchService;

    // ------------------- 교재 검색 -------------------
    @GetMapping("/search")
    public ResponseEntity<List<Book>> searchBooks(@RequestParam String keyword,
                                                  @RequestParam String schoolId) {
        List<Book> books = bookSearchService.searchBooks(keyword, schoolId);
        return ResponseEntity.ok(books);
    }

    // ------------------- 검색 결과 필터링 -------------------
    @PostMapping("/filter")
    public ResponseEntity<List<Book>> filterSearchResults(@RequestBody List<Book> books,
                                                          @RequestParam(required = false) String state,
                                                          @RequestParam(required = false, defaultValue = "0") int minPoints,
                                                          @RequestParam(required = false, defaultValue = "999999") int maxPoints,
                                                          @RequestParam(required = false) LocalDate registrationDate,
                                                          @RequestParam(required = false, defaultValue = "popularity") String sortBy) {
        List<Book> filtered = bookSearchService.filterSearchResults(books, state, minPoints, maxPoints, registrationDate, sortBy);
        return ResponseEntity.ok(filtered);
    }

    // ------------------- 교재 상세 조회 -------------------
    @GetMapping("/{bookId}")
    public ResponseEntity<Book> viewBookDetails(@PathVariable String bookId,
                                                @RequestParam String schoolId) {
        Book book = bookSearchService.viewBookDetails(bookId, schoolId);
        return ResponseEntity.ok(book);
    }

    // ------------------- 교재 문제 신고 -------------------
    @PostMapping("/{bookId}/report")
    public ResponseEntity<String> reportBookIssue(@PathVariable String bookId,
                                                  @RequestParam String userId,
                                                  @RequestParam String reportContent) {
        bookSearchService.reportBookIssue(bookId, userId, reportContent);
        return ResponseEntity.ok("교재 신고 완료");
    }

    // ------------------- 교재 예약 -------------------
    @PostMapping("/{bookId}/reserve")
    public ResponseEntity<String> reserveBook(@PathVariable String bookId,
                                              @RequestParam String userId) {
        bookSearchService.reserveBook(bookId, userId);
        return ResponseEntity.ok("교재 예약 완료");
    }
}
