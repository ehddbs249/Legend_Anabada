package aise.legend_anabada.restController;

import aise.legend_anabada.entity.User;
import aise.legend_anabada.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {
    @Autowired
    private UserService userService;

    // 회원가입
    @PostMapping("/register")
    public ResponseEntity<String> registerUser(@RequestBody User user) {
        userService.registerUser(user);
        return ResponseEntity.ok("회원가입 완료");
    }

    // 학생 인증
    @PostMapping("/authenticate")
    public ResponseEntity<String> authenticateUser(@RequestParam String email,
                                                   @RequestParam String password) {
        userService.authenticateUser(email, password);
        return ResponseEntity.ok("학생 인증 완료");
    }

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<String> loginUser(@RequestParam String email,
                                            @RequestParam String password) {
        userService.loginUser(email, password);
        return ResponseEntity.ok("로그인 성공");
    }

    // 로그아웃
    @PostMapping("/logout")
    public ResponseEntity<String> logoutUser() {
        userService.logoutUser();
        return ResponseEntity.ok("로그아웃 완료");
    }

    // 세션 확인
    @GetMapping("/session-check")
    public ResponseEntity<Boolean> sessionCheck(@RequestParam String email,
                                                @RequestParam String password,
                                                @RequestParam String sessionId) {
        boolean valid = userService.sessionCheck(email, password, sessionId);
        return ResponseEntity.ok(valid);
    }

    // 개인정보 수정
    @PutMapping("/edit")
    public ResponseEntity<String> editUser(@RequestParam String email,
                                           @RequestParam String password,
                                           @RequestParam String sessionId,
                                           @RequestBody User updatedUser) {
        userService.editUser(email, password, sessionId);
        return ResponseEntity.ok("사용자 정보 수정 완료");
    }

    // 대여·반납·기부 내역 조회
    @GetMapping("/transactions")
    public ResponseEntity<String> viewTransactionHistory(@RequestParam String email,
                                                         @RequestParam String sessionId) {
        userService.viewTransactionHistory(email, sessionId);
        return ResponseEntity.ok("거래 내역 조회 완료");
    }

    // 계정 탈퇴 요청
    @DeleteMapping("/delete")
    public ResponseEntity<String> requestAccountDeletion(@RequestParam String email,
                                                         @RequestParam String sessionId) {
        userService.requestAccountDeletion(email, sessionId);
        return ResponseEntity.ok("계정 탈퇴 요청 완료");
    }

    // 포인트 관리
    @GetMapping("/points")
    public ResponseEntity<String> managePoints(@RequestParam String email,
                                               @RequestParam String sessionId) {
        userService.managePoints(email, sessionId);
        return ResponseEntity.ok("포인트 내역 조회 완료");
    }
}
