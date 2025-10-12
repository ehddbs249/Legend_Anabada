package aise.legend_anabada.config;

public class Status {
    // 200 - OK
    // 400 - Bad Request ( 잘못된 요청 )
    // 401 - Unauthorized ( 인증 / 로그인 )
    // 403 - Forbidden ( 권한 없음 )
    // 500 - Internal Server Error ( 서버 내부 오류 )
    
    public static final int OK = 200;
    public static final int BAD_REQUEST = 400;
    public static final int UNAUTHORIZED = 401;
    public static final int FORBIDDEN = 403;
    public static final int INTERNAL_SERVER_ERROR = 500;
}
