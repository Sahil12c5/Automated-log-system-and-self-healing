package com.autoheal.util;

import java.security.SecureRandom;

public class OTPUtil {
    private static final SecureRandom RANDOM = new SecureRandom();

    public static String generate4DigitOTP() {
        int otp = 1000 + RANDOM.nextInt(9000);
        return String.valueOf(otp);
    }
}
