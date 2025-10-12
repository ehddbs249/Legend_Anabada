package aise.legend_anabada.config.exception;

public class ExpiredTokenException extends RuntimeException {
    public ExpiredTokenException() {
        super();
    }

    public ExpiredTokenException(String message) {
        super(message);
    }
}
