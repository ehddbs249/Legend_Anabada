package aise.legend_anabada.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthResponse<T> {
    private boolean success;
    private String token;
    private String massage;
    private T data;
}
