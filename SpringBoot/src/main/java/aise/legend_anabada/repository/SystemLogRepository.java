package aise.legend_anabada.repository;

import aise.legend_anabada.entity.SystemLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface SystemLogRepository extends JpaRepository<SystemLog, UUID> {
}
