package com.bloomster;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;


public class JwtUtil {

    /*
     * IMPORTANT:
     * Production mein isko environment variable se lo.
     *
     * Example:
     * JWT_SECRET=your-very-long-secret-key...
     */
    private static final String SECRET = "^2B[AYP|f;|jOabVubE_SX)S)1S;O2Sf";
        //     System.getenv("JWT_SECRET");

    private static final long ACCESS_TOKEN_EXPIRATION =
            15 * 60 * 1000; // 15 minutes

    private static final long REFRESH_TOKEN_EXPIRATION =
            30L * 24 * 60 * 60 * 1000; // 30 days

    private static SecretKey getKey() {

        if (SECRET == null || SECRET.length() < 32) {
            throw new IllegalStateException(
                    "JWT_SECRET environment variable must be at least 32 characters"
            );
        }

        return Keys.hmacShaKeyFor(
                SECRET.getBytes(StandardCharsets.UTF_8)
        );
    }

    public static String generateAccessToken(int userId, String email) {

        Date now = new Date();
        Date expiry = new Date(
                now.getTime() + ACCESS_TOKEN_EXPIRATION
        );

        return Jwts.builder()
                .subject(String.valueOf(userId))
                .claim("email", email)
                .claim("type", "access")
                .issuedAt(now)
                .expiration(expiry)
                .signWith(getKey())
                .compact();
    }

    public static String generateRefreshToken(int userId) {

        Date now = new Date();
        Date expiry = new Date(
                now.getTime() + REFRESH_TOKEN_EXPIRATION
        );

        return Jwts.builder()
                .subject(String.valueOf(userId))
                .claim("type", "refresh")
                .issuedAt(now)
                .expiration(expiry)
                .signWith(getKey())
                .compact();
    }

    public static Claims validateToken(String token) {

        return Jwts.parser()
                .verifyWith(getKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public static int getUserId(String token) {

        Claims claims = validateToken(token);

        return Integer.parseInt(
                claims.getSubject()
        );
    }

    public static String getTokenType(String token) {

        Claims claims = validateToken(token);

        return claims.get("type", String.class);
    }
}