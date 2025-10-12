package aise.legend_anabada.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserCreateRequest {
    String user_id;
    String email;
    String password;
    String student_number;
    String department;
    String name;
    String created_at;
    String role;
    boolean verify;
    String expiryDate;
}
