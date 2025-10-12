package aise.legend_anabada.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

import java.time.OffsetDateTime;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "\"User\"")
public class User {
    @Id
    @ColumnDefault("gen_random_uuid()")
    @Column(name = "user_id", nullable = false)
    private UUID id;

    @Column(name = "email", nullable = false, length = 100)
    private String email;

    @Column(name = "password", nullable = false, length = 100)
    private String password;

    @Column(name = "student_number", nullable = false, length = 10)
    private String studentNumber;

    @Column(name = "department", nullable = false, length = 20)
    private String department;

    @Column(name = "grade", nullable = false)
    private String grade;

    @Column(name = "name", nullable = false, length = 10)
    private String name;

    @ColumnDefault("now()")
    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "role", nullable = false, length = 20)
    private String role;

    @ColumnDefault("false")
    @Column(name = "verify", nullable = false)
    private Boolean verify;

    @Column(name = "expiryDate")
    private Date expiryDate;

    @OneToMany(mappedBy = "user")
    private Set<Book> books = new LinkedHashSet<>();

    @OneToMany(mappedBy = "user")
    private Set<BookTransaction> bookTransactions = new LinkedHashSet<>();

    @OneToMany(mappedBy = "borrower")
    private Set<BookTransaction> bookTransactionsBorrowed = new LinkedHashSet<>();

    @OneToMany(mappedBy = "user")
    private Set<PointTransaction> pointTransactions = new LinkedHashSet<>();

    @OneToMany(mappedBy = "user")
    private Set<Reservation> reservations = new LinkedHashSet<>();

    @OneToMany(mappedBy = "user")
    private Set<SystemLog> systemLogs = new LinkedHashSet<>();

    @OneToOne(mappedBy = "user")
    private UserPointBalance userPointBalance;

}