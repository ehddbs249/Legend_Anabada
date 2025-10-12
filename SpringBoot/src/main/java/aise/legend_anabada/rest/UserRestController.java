package aise.legend_anabada.rest;

import aise.legend_anabada.config.Status;
import aise.legend_anabada.config.exception.ExpiredTokenException;
import aise.legend_anabada.config.exception.InvalidEmailException;
import aise.legend_anabada.config.exception.InvalidPasswordException;
import aise.legend_anabada.dto.request.AuthRequest;
import aise.legend_anabada.dto.request.LoginRequest;
import aise.legend_anabada.dto.request.UserRegisterRequest;
import aise.legend_anabada.dto.response.AuthResponse;
import aise.legend_anabada.dto.response.Response;
import aise.legend_anabada.entity.User;
import aise.legend_anabada.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserRestController {
    @Autowired
    private UserService userService;

    // 회원가입
    @PostMapping("/register")
    public ResponseEntity<Response<Void>> registerUser(@RequestBody UserRegisterRequest request) {
        Response<Void> response = userService.registerUser(request);

        return ResponseEntity.ok(response);
    }

    // 메일 전송
    @PostMapping("/auth")
    public ResponseEntity<Response<Void>> authUser(@RequestBody AuthRequest request) {
        try {
            Response<Void> response = userService.authenticateUser(request);
            return ResponseEntity.ok(response);
        } catch (InvalidEmailException e) {
            return ResponseEntity.status(Status.BAD_REQUEST)
                    .body(new Response<>(false, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(Status.INTERNAL_SERVER_ERROR)
                    .body(new Response<>(false, e.getMessage(), null));
        }
    }

    // 학생 인증
    @GetMapping("/verify")
    @ResponseBody
    public ResponseEntity<Response<Void>> verifyUser(@RequestParam("token") String token) {
        try {
            Response<Void> response = userService.verifyEmail(token);
            return ResponseEntity.ok(response);
        } catch (InvalidEmailException e) {
            return ResponseEntity.status(Status.BAD_REQUEST)
                    .body(new Response<>(false, e.getMessage(), null));
        } catch (ExpiredTokenException e) {
            return ResponseEntity.status(Status.UNAUTHORIZED)
                    .body(new Response<>(false, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(Status.INTERNAL_SERVER_ERROR)
                    .body(new Response<>(false, e.getMessage(), null));
        }
    }

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<AuthResponse<String>> loginUser(@RequestBody LoginRequest request) {
        try {
            AuthResponse<String> response = userService.loginUser(request);
            return ResponseEntity.ok(response);
        } catch (InvalidEmailException e) {
            return ResponseEntity.status(Status.BAD_REQUEST)
                    .body(new AuthResponse<>(false, null, e.getMessage(), null));
        } catch (InvalidPasswordException e) {
            return ResponseEntity.status(Status.UNAUTHORIZED)
                    .body(new AuthResponse<>(false, null, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(Status.INTERNAL_SERVER_ERROR)
                    .body(new AuthResponse<>(false, null, e.getMessage(), null));
        }
    }

    // 로그아웃
    @PostMapping("/logout")
    public ResponseEntity<Response<Void>> logoutUser() {
        // 플러터에서 토큰 삭제하기
        return ResponseEntity.ok(new Response<Void>(true, "로그아웃 완료", null));
    }

    // TODO 개인정보 수정
    @PutMapping("/edit")
    public ResponseEntity<String> editUser(@RequestParam String email,
                                           @RequestParam String password,
                                           @RequestParam String sessionId,
                                           @RequestBody User updatedUser) {
        userService.editUser(email, password, sessionId);
        return ResponseEntity.ok("사용자 정보 수정 완료");
    }

    // TODO 대여·반납·기부 내역 조회
    @GetMapping("/transactions")
    public ResponseEntity<String> viewTransactionHistory(@RequestParam String email,
                                                         @RequestParam String sessionId) {
        userService.viewTransactionHistory(email, sessionId);
        return ResponseEntity.ok("거래 내역 조회 완료");
    }

    // TODO 계정 탈퇴 요청
    @DeleteMapping("/delete")
    public ResponseEntity<String> requestAccountDeletion(@RequestParam String email,
                                                         @RequestParam String sessionId) {
        userService.requestAccountDeletion(email, sessionId);
        return ResponseEntity.ok("계정 탈퇴 요청 완료");
    }

    // TODO 포인트 관리
    @GetMapping("/points")
    public ResponseEntity<String> managePoints(@RequestParam String email,
                                               @RequestParam String sessionId) {
        userService.managePoints(email, sessionId);
        return ResponseEntity.ok("포인트 내역 조회 완료");
    }
}
