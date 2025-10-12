package aise.legend_anabada.service;

import aise.legend_anabada.config.exception.ExpiredTokenException;
import aise.legend_anabada.config.exception.FileUploadException;
import aise.legend_anabada.dto.request.BookRegisterRequest;
import aise.legend_anabada.dto.AuthResponse;
import aise.legend_anabada.entity.Book;
import aise.legend_anabada.repository.BookRepository;
import aise.legend_anabada.repository.UserRepository;
import aise.legend_anabada.util.FileUtil;
import aise.legend_anabada.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Service
public class BookService {
    @Autowired
    private BookRepository bookRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private FileUtil fileUtil;

    public AuthResponse<Void> registerBook(String token, List<MultipartFile> images, BookRegisterRequest request) {
        if(!JwtUtil.validateToken(token)){
            throw new ExpiredTokenException("인증 만료됨");
        }

        UUID uuid = UUID.randomUUID();

        for (MultipartFile image : images) {
            try {
                if (image != null && !image.isEmpty()) {
                    String fileName = image.getOriginalFilename();
                    String filePath = "/" + uuid + "/" + fileName;
                    fileUtil.save(image, filePath);
                }
            } catch (IOException e) {
                throw new FileUploadException("사진 업로드 실패");
            }
        }

        // TODO Book 엔티티 생성
        Book book = new Book();
        book.setId(uuid);

        String email = JwtUtil.getEmailFromToken(token);
        userRepository.findByEmail(email).ifPresent(book::setUser);

        bookRepository.save(book);

        return new AuthResponse<Void>(true, JwtUtil.generateToken(email), request.getTitle() + " 교재 등록이 완료되었습니다.", null);
    }

    public void editBookInfo(String bookId, Book updatedBook) {
        // 등록자는 예약이 걸리기 전까지 교재 정보를 수정할 수 있으며, 예약 이후에는 관리자만 수정 가능하다.
    }

    public void categorizeBook(String bookId, String department, String subject, int grade, String examCategory) {
        // 교재는 학과, 과목, 학년, 시험 대비 등 다중 카테고리로 분류할 수 있으며,
        // 분류 정보는 검색과 추천에 활용된다.
    }
}
