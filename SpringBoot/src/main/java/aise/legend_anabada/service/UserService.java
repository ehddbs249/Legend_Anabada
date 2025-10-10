package aise.legend_anabada.service;

import aise.legend_anabada.entity.User;
import aise.legend_anabada.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public void registerUser(User user) {
        // 사용자는 학교 이메일 인증을 통해 회원가입을 진행할 수 있다.
    }

    public void authenticateUser(String email, String password) {
        // 회원가입 시 학번과 학과 정보를 입력하여 학생 인증을 받아야 한다.
    }

    public void loginUser(String email, String password) {
        // 로그인은 이메일(ID)과 비밀번호를 입력하여 시스템에 대조하고, 일치할 경우 접속을 허용한다.
    }

    public void logoutUser() {
        // 로그아웃은 현재 로그인된 사용자의 세션을 즉시 종료한다.
    }

    public boolean sessionCheck(String email, String password, String sessionId) {
        // 로그인 성공 시 세션이 발급되며, 30분 동안 유지된다.
        return false;
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
