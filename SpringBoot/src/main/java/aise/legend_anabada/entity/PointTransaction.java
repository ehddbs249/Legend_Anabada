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
@Table(name = "point_transaction")
public class PointTransaction {
    @Id
    @ColumnDefault("gen_random_uuid()")
    @Column(name = "trans_id", nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "point_change", nullable = false)
    private Integer pointChange;

    @Column(name = "trans_type", nullable = false, length = 50)
    private String transType;

    @ColumnDefault("now()")
    @Column(name = "trans_date", nullable = false)
    private OffsetDateTime transDate;

}