package aise.legend_anabada.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserEditRequest {
    private String name;
    private String department;
    private String email;
    private String password;
}
