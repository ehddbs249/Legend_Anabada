package aise.legend_anabada.repository;

import aise.legend_anabada.entity.PointTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface PointTransactionRepository extends JpaRepository<PointTransaction, UUID> {
}
