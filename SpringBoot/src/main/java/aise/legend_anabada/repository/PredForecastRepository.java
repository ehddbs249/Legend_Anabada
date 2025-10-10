package aise.legend_anabada.repository;

import aise.legend_anabada.entity.PredForecast;
import org.springframework.data.repository.CrudRepository;

import java.util.UUID;

public interface PredForecastRepository extends CrudRepository<PredForecast, UUID> {
}
