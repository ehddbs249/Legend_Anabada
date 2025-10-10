package aise.legend_anabada.repository;

import aise.legend_anabada.entity.Locker;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface LockerRepository extends JpaRepository<Locker, UUID> {
}
