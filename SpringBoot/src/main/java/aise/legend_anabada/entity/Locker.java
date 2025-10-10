package aise.legend_anabada.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "locker")
public class Locker {
    @Id
    @ColumnDefault("gen_random_uuid()")
    @Column(name = "locker_id", nullable = false)
    private UUID id;

    @Column(name = "locker_status", nullable = false, length = 20)
    private String lockerStatus;

    @Column(name = "is_broken")
    private Boolean isBroken;

    @Column(name = "locker_num")
    private Integer lockerNum;

    @OneToMany(mappedBy = "locker")
    private Set<SystemLog> systemLogs = new LinkedHashSet<>();

}