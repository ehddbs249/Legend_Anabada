package aise.legend_anabada.repository;

import aise.legend_anabada.entity.UserPointBalance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface UserPointBalanceRepository extends JpaRepository<UserPointBalance, UUID> {
}
