package aise.legend_anabada.service;

import aise.legend_anabada.dto.request.BookRegisterRequest;
import aise.legend_anabada.dto.response.AuthResponse;
import aise.legend_anabada.dto.response.Response;
import aise.legend_anabada.entity.Book;
import aise.legend_anabada.repository.BookRepository;
import aise.legend_anabada.repository.UserRepository;
import aise.legend_anabada.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class BookService {
    @Autowired
    private BookRepository bookRepository;
    @Autowired
    private UserRepository userRepository;

    public AuthResponse<Void> registerBook(String token, MultipartFile image, BookRegisterRequest request) {
        if(!JwtUtil.validateToken(token)){
            return new AuthResponse<Void>(false, null, "로그인 필요", null);
        }

        String email = JwtUtil.getEmailFromToken(token);

        try{

        } catch (Exception e) {
            return new AuthResponse<Void>(false, JwtUtil.generateToken(email), "사진 업로드 실패", null);
        }

        Book book = new Book();


        return new AuthResponse<Void>(true, JwtUtil.generateToken(email), request.getTitle() + "교재 등록이 완료되었습니다.", null);
    }

    public void registerBookAutomatically(Book book) {
        // 사용자는 자동 혹은 수동으로 책을 인식하여 등록할 수 있다.
        // 자동 인식 시 시스템은 OCR을 통해 제목, 저자, 출판사를 가져온다.
        // 시스템은 교재 상태를 새것/상/중/하 4단계로 판단하고, 필요 시 결함 태그(필기, 낙서, 찢김, 젖음 등)를 추가한다.
        // 자동 인식이 실패하거나 수정이 필요할 시 수동 입력 화면으로 전환된다.
        // 교재 등록이 완료되면 고유 식별번호(Book ID)가 부여된다.
        // 교재 상태와 결함 정보는 상세 화면과 예약 시 참고 정보로 제공된다.
    }

    public void registerBookManually(Book book) {
        // 수동 등록 시 사용자는 제목, 저자, 출판사, 발행연도, 가격(또는 무료 여부)을 직접 입력해야 한다.
        // 교재 등록이 완료되면 고유 식별번호(Book ID)가 부여된다.
        // 교재 상태와 결함 정보는 상세 화면과 예약 시 참고 정보로 제공된다.
    }

    public void editBookInfo(String bookId, Book updatedBook) {
        // 등록자는 예약이 걸리기 전까지 교재 정보를 수정할 수 있으며, 예약 이후에는 관리자만 수정 가능하다.
    }

    public void categorizeBook(String bookId, String department, String subject, int grade, String examCategory) {
        // 교재는 학과, 과목, 학년, 시험 대비 등 다중 카테고리로 분류할 수 있으며,
        // 분류 정보는 검색과 추천에 활용된다.
    }
}
