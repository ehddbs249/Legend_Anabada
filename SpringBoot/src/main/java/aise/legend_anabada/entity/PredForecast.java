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
@Table(name = "pred_forecasts")
public class PredForecast {
    @Id
    @ColumnDefault("gen_random_uuid()")
    @Column(name = "pred_id", nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "book_id", nullable = false)
    private Book book;

    @Column(name = "pred_demand", nullable = false)
    private Integer predDemand;

    @Column(name = "pred_basis", length = 100)
    private String predBasis;

    @ColumnDefault("now()")
    @Column(name = "pred_at", nullable = false)
    private OffsetDateTime predAt;

    @Column(name = "semester", nullable = false, length = 20)
    private String semester;

}