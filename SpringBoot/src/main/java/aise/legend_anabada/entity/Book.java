package aise.legend_anabada.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

import java.time.OffsetDateTime;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "book")
public class Book {
    @Id
    @ColumnDefault("gen_random_uuid()")
    @Column(name = "book_id", nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(name = "title", nullable = false, length = 100)
    private String title;

    @Column(name = "author", nullable = false, length = 50)
    private String author;

    @Column(name = "publisher", length = 50)
    private String publisher;

    @ColumnDefault("0")
    @Column(name = "point_price", nullable = false)
    private Integer pointPrice;

    @Column(name = "condition_grade", length = 10)
    private String conditionGrade;

    @Column(name = "dmg_tag", length = 10)
    private String dmgTag;

    @Column(name = "img_url", length = 500)
    private String imgUrl;

    @ColumnDefault("now()")
    @Column(name = "registered_at", nullable = false)
    private OffsetDateTime registeredAt;

    @OneToMany(mappedBy = "book")
    private Set<BookTransaction> bookTransactions = new LinkedHashSet<>();

    @OneToMany(mappedBy = "book")
    private Set<PredForecast> predForecasts = new LinkedHashSet<>();

    @OneToMany(mappedBy = "book")
    private Set<Reservation> reservations = new LinkedHashSet<>();

}