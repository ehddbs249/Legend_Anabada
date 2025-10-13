package aise.legend_anabada.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "user_point_balance")
public class UserPointBalance {
    @Id
    @Column(name = "user_id", nullable = false)
    private UUID id;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ColumnDefault("0")
    @Column(name = "point_total", nullable = false)
    private Integer pointTotal;

    @ColumnDefault("0")
    @Column(name = "total_earned", nullable = false)
    private Integer totalEarned;

    @ColumnDefault("0")
    @Column(name = "total_spent", nullable = false)
    private Integer totalSpent;

}