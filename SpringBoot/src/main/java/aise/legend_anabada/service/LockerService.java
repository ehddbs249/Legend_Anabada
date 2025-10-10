package aise.legend_anabada.service;

import org.springframework.stereotype.Service;

@Service
public class LockerService {
    public void openLocker(String lockerId, String userId) {
        // 사용자는 앱을 통해 사물함을 개폐할 수 있다.
        // 개폐 성공, 실패, 문 열림, 문 닫힘 상태는 모두 로그로 기록된다.
    }

    public void closeLocker(String lockerId, String userId) {
        // 문 닫힘 상태를 기록하고, 문이 정상적으로 닫혔는지 확인한다.
        // 5분 이상 닫히지 않으면 관리자에게 알림을 전송하고 필요 시 시스템 자체적으로 조치를 한다.
    }

    public void monitorLockerStatus() {
        // 시스템은 각 칸의 문 상태를 실시간으로 모니터링한다.
        // 센서 오류, 네트워크 장애 발생 시 관리자에게 알림을 전송하며 필요시 조치를 수행한다.
    }

    public void disableBrokenLocker(String lockerId) {
        // 고장난 칸은 자동으로 비활성화되어 예약이나 입고에 배정되지 않는다.
    }

    public void emergencyOpenLocker(String lockerId, String adminId, String reason) {
        // 관리자 권한으로 비상 개방을 수행할 수 있다.
        // 비상 개방 사유와 담당자는 반드시 기록된다.
    }
}
