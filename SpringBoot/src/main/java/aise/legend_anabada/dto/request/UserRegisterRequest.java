package aise.legend_anabada.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserRegisterRequest {
    private String name;
    private String studentNumber;
    private String department;
    private String grade;
    private String email;
    private String password;
}
