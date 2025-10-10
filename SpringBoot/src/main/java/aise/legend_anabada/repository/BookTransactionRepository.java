package aise.legend_anabada.repository;

import aise.legend_anabada.entity.BookTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface BookTransactionRepository extends JpaRepository<BookTransaction, UUID> {
}
