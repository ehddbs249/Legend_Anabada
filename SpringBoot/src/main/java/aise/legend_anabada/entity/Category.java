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
@Table(name = "category")
public class Category {
    @Id
    @ColumnDefault("gen_random_uuid()")
    @Column(name = "category_id", nullable = false)
    private UUID id;

    @Column(name = "category_name", nullable = false, length = 50)
    private String categoryName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_category_id")
    private Category parentCategory;

    @Column(name = "classfication_type", nullable = false, length = 50)
    private String classficationType;

    @OneToMany(mappedBy = "category")
    private Set<Book> books = new LinkedHashSet<>();

    @OneToMany(mappedBy = "parentCategory")
    private Set<Category> categories = new LinkedHashSet<>();

}