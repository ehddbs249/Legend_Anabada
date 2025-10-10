package aise.legend_anabada.restController;

import aise.legend_anabada.entity.Book;
import aise.legend_anabada.service.BookRecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/recommend")
public class BookRecommendationController {
    @Autowired
    private BookRecommendationService recommendationService;

    // ------------------- 개인화 교재 추천 -------------------
    @GetMapping("/personalized")
    public ResponseEntity<List<Book>> getPersonalizedRecommendations(@RequestParam String userId) {
        List<Book> recommendations = recommendationService.getPersonalizedRecommendations(userId);
        return ResponseEntity.ok(recommendations);
    }

    // ------------------- 교재 수요 예측 -------------------
    @GetMapping("/demand")
    public ResponseEntity<Map<String, Integer>> predictBookDemand(@RequestParam String semester) {
        Map<String, Integer> demand = recommendationService.predictBookDemand(semester);
        return ResponseEntity.ok(demand);
    }

    // ------------------- 사물함 운영 계획 생성 -------------------
    @PostMapping("/locker-plan")
    public ResponseEntity<String> generateLockerOperationPlan(@RequestParam String semester) {
        recommendationService.generateLockerOperationPlan(semester);
        return ResponseEntity.ok("사물함 운영 계획 및 교재 확보 전략 생성 완료: " + semester);
    }
}
