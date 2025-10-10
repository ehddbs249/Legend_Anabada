package aise.legend_anabada.service;

import aise.legend_anabada.entity.Book;
import aise.legend_anabada.repository.BookRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class BookSearchService {
    @Autowired
    private BookRepository bookRepository;

    public List<Book> searchBooks(String keyword, String schoolId) {
        // 사용자는 제목, 저자 등을 기준으로 교재를 검색할 수 있다.
        // 동일 학교 사용자만 검색 결과를 열람할 수 있다.
        return null;
    }

    public List<Book> filterSearchResults(List<Book> books, String state, int minPoints, int maxPoints,
                                          LocalDate registrationDate, String sortBy) {
        // 검색 결과는 상태, 포인트, 등록일, 인기순 등의 조건으로 필터링할 수 있다.
        return null;
    }

    public Book viewBookDetails(String bookId, String schoolId) {
        // 교재 상세 화면에서는 제목, 저자, 출판사, 상태, 결함 태그, 포인트 가격, 카테고리 정보를 확인할 수 있다.
        // 사용자는 표지 사진과 결함 사진을 확대하여 확인할 수 있다.
        // 교재가 보관된 사물함 위치가 함께 표시된다.
        return null;
    }

    public void reportBookIssue(String bookId, String userId, String reportContent) {
        // 신고 기능을 통해 상태 불일치나 문제를 제보할 수 있다.
    }

    public void reserveBook(String bookId, String userId) {
        // 사용자는 원하는 교재를 예약할 수 있다.
        // 예약 시 포인트가 임시로 홀딩되며, 수령 확정 시 포인트가 차감된다.
        // 예약 후 일정 시간 내 교재를 수령하지 않으면 자동 취소되며, 포인트는 즉시 반환된다.
        // 예약 과정 및 결과는 등록자와 예약자 모두에게 알림으로 전달된다.
    }
}
