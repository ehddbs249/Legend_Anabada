package aise.legend_anabada.restController;

import aise.legend_anabada.service.LockerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/locker")
public class LockerController {
    @Autowired
    private LockerService lockerService;

    // ------------------- 사물함 개방 -------------------
    @PostMapping("/{lockerId}/open")
    public ResponseEntity<String> openLocker(@PathVariable String lockerId,
                                             @RequestParam String userId) {
        lockerService.openLocker(lockerId, userId);
        return ResponseEntity.ok("사물함 개방 요청 완료: " + lockerId);
    }

    // ------------------- 사물함 닫힘 -------------------
    @PostMapping("/{lockerId}/close")
    public ResponseEntity<String> closeLocker(@PathVariable String lockerId,
                                              @RequestParam String userId) {
        lockerService.closeLocker(lockerId, userId);
        return ResponseEntity.ok("사물함 닫힘 처리 완료: " + lockerId);
    }

    // ------------------- 사물함 상태 모니터링 -------------------
    @GetMapping("/monitor")
    public ResponseEntity<String> monitorLockerStatus() {
        lockerService.monitorLockerStatus();
        return ResponseEntity.ok("사물함 상태 모니터링 수행");
    }

    // ------------------- 고장난 사물함 비활성화 -------------------
    @PostMapping("/{lockerId}/disable")
    public ResponseEntity<String> disableBrokenLocker(@PathVariable String lockerId) {
        lockerService.disableBrokenLocker(lockerId);
        return ResponseEntity.ok("고장 사물함 비활성화 완료: " + lockerId);
    }

    // ------------------- 관리자 비상 개방 -------------------
    @PostMapping("/{lockerId}/emergency-open")
    public ResponseEntity<String> emergencyOpenLocker(@PathVariable String lockerId,
                                                      @RequestParam String adminId,
                                                      @RequestParam String reason) {
        lockerService.emergencyOpenLocker(lockerId, adminId, reason);
        return ResponseEntity.ok("비상 개방 완료: " + lockerId + ", 사유: " + reason);
    }
}
