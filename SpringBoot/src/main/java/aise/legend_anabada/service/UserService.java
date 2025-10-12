package aise.legend_anabada.service;

import aise.legend_anabada.AppProperties;
import aise.legend_anabada.JwtUtil;
import aise.legend_anabada.dto.request.AuthRequest;
import aise.legend_anabada.dto.request.LoginRequest;
import aise.legend_anabada.dto.request.RegisterRequest;
import aise.legend_anabada.dto.response.AuthResponse;
import aise.legend_anabada.dto.response.Response;
import aise.legend_anabada.entity.User;
import aise.legend_anabada.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Optional;
import java.util.UUID;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private JavaMailSender mailSender;
    @Autowired
    private AppProperties appProperties;

    private final BCryptPasswordEncoder bCryptPasswordEncoder = new BCryptPasswordEncoder();

    public Response<Void> registerUser(RegisterRequest request) {
        // 사용자는 학교 이메일 인증을 통해 회원가입을 진행할 수 있다.
        String name = request.getName();
        String studentNumber = request.getStudentNumber();
        String department = request.getDepartment();
        String grade = request.getGrade();
        String email = request.getEmail();
        String password = request.getPassword();
        
        // 패스워드 암호화
        String encodedPassword = bCryptPasswordEncoder.encode(password);
        
        // 이메일 인증
        UUID uuid = UUID.randomUUID();
        Date expiryDate = new Date(System.currentTimeMillis() + 24 * 60 * 60 * 1000); // 24시간
        
        User user = new User();

        user.setId(uuid);
        user.setEmail(email);
        user.setPassword(encodedPassword);
        user.setStudentNumber(studentNumber);
        user.setDepartment(department);
        user.setName(name);
        user.setRole("학생");

        // 이메일 인증용
        // user.setExpiryDate(expiryDate);

        userRepository.save(user);

        sendMail(email, uuid.toString());

        return new Response<Void>(true, "이메일로 인증 메일이 발송되었습니다.", null);
    }

    public Response<Void> authenticateUser(AuthRequest request) {
        String email = request.getEmail();

        Optional<User> user = userRepository.findByEmail(email);
        if (user.isEmpty()){
            return new Response<Void>(false, "이메일이 존재하지 않습니다.", null);
        }

        String token = user.get().getId().toString();

        sendMail(email, token);

        return new Response<Void>(true, "이메일로 인증 메일이 발송되었습니다.", null);
    }

    public void sendMail(String email, String token) {
        // 회원가입 시 학번과 학과 정보를 입력하여 학생 인증을 받아야 한다.
        String subject = "[LEGEND 아나바다] 이메일 인증";
        String verificationUrl = appProperties.getBase_url() + "/api/user/verify?token=" + token;
        String message = "아래 링크를 클릭하여 이메일을 인증하세요:\n" + verificationUrl;

        SimpleMailMessage mail = new SimpleMailMessage();
        mail.setTo(email);
        mail.setSubject(subject);
        mail.setText(message);
        mailSender.send(mail);
    }

    public Response<Void> verifyEmail(String token) {
        UUID uuid = UUID.fromString(token);
        Optional<User> user = userRepository.findById(uuid);

        if (user.isEmpty()) {
            return new Response<Void>(false, "유효하지 않은 토큰", null);
        }

        User user_ = user.get();

        if (user_.getExpiryDate().before(new Date())) {
            return new Response<Void>(false, "토큰 만료", null);
        }

        user_.setVerify(true);
        userRepository.save(user_);

        return new Response<Void>(true, "인증 성공", null);
    }

    public AuthResponse<String> loginUser(LoginRequest request) {
        // 로그인은 이메일(ID)과 비밀번호를 입력하여 시스템에 대조하고, 일치할 경우 접속을 허용한다.
        String email = request.getEmail();
        String password = request.getPassword();

        Optional<User> user = userRepository.findById(email);

        boolean isSuccess = false;
        String token = "";
        String message = "로그인 실패";

        if (user.isPresent()) {
            String encodedPassword = bCryptPasswordEncoder.encode(password);
            isSuccess = user.get().getPassword().equals(encodedPassword);
        }

        if (isSuccess) {
            token = JwtUtil.generateToken(email);
            message = "로그인 성공";
        }

        return new AuthResponse<String>(isSuccess, token, message, email);
    }

    public void editUser(String email, String password, String sessionId) {
        // 사용자는 개인정보(이름, 학과, 이메일)를 수정할 수 있다.
    }

    public void viewTransactionHistory(String email, String sessionId) {
        // 사용자는 본인의 대여·반납·기부 내역을 조회할 수 있다.
    }

    public void requestAccountDeletion(String email, String sessionId) {
        // 계정 탈퇴 요청 시, 진행 중인 거래가 없을 경우에만 탈퇴가 가능하다.
    }

    public void managePoints(String email, String sessionId) {
        // 사용자의 포인트는 교재 기부 및 이벤트로 적립되며, 예약·대여·연체 시 차감된다.
        // 포인트는 충전 및 소멸이 가능하며, 24개월 미사용 시 자동 소멸되고 소멸 30일 전 고지된다.
        // 포인트 내역은 사용자 본인과 관리자가 모두 열람할 수 있다.
    }
}
