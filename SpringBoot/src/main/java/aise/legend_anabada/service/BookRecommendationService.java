package aise.legend_anabada.service;

import aise.legend_anabada.entity.Book;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class BookRecommendationService {
    public List<Book> getPersonalizedRecommendations(String userId) {
        // 시스템은 사용자의 전공, 수강 과목, 검색·열람·예약·수령 이력을 바탕으로 개인화 추천을 제공한다.
        // 추천 결과에는 추천 사유가 간단히 함께 표시된다(예: "같은 학과 학생들이 많이 빌린 교재").
        return null;
    }

    public Map<String, Integer> predictBookDemand(String semester) {
        // 시스템은 학기별 교과과정 데이터와 과거 예약/대여 데이터를 분석하여 수요를 예측한다.
        // 특정 과목에서 수요가 집중될 것으로 예상되면 관리자에게 알림을 제공한다.
        return null;
    }

    public void generateLockerOperationPlan(String semester) {
        // 관리자는 수요 예측 결과를 바탕으로 사물함 운영 계획과 교재 확보 전략을 수립할 수 있다.
    }
}
