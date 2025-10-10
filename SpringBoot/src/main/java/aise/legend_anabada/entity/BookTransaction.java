package aise.legend_anabada.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "book_transaction")
public class BookTransaction {
    @Id
    @ColumnDefault("gen_random_uuid()")
    @Column(name = "trans_id", nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "book_id", nullable = false)
    private Book book;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "trans_status", nullable = false, length = 20)
    private String transStatus;

    @ColumnDefault("now()")
    @Column(name = "trans_date", nullable = false)
    private OffsetDateTime transDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "borrower_id")
    private User borrower;

}