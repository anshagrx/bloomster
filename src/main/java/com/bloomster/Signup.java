package com.bloomster;

import java.util.Map;

import com.myServlet.DB;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import org.mindrot.jbcrypt.BCrypt;

@WebServlet({"/create-account"})
public class Signup extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {

            ReadJSON readJSON = new ReadJSON();

            Map<String, Object> data =
                    readJSON.readJSON(request);


            int id =
                    (int) (Math.random() * 9000) + 1000;


            String email =
                    (String) data.get("email");

            String first_name =
                    (String) data.get("first_name");

            String last_name =
                    (String) data.get("last_name");

            String username =
                    last_name + first_name;

            String password =
                    (String) data.get("password");


            Boolean verified = false;


            int otp =
                    (int) (Math.random() * 9000) + 1000;


            /*
             * =====================================================
             * PASSWORD HASH
             * =====================================================
             *
             * Password ko plain text me DB me save nahi karna.
             *
             * BCrypt one-way hash banata hai.
             */

            String hashedPassword =
                    BCrypt.hashpw(
                            password,
                            BCrypt.gensalt(12)
                    );


            /*
             * =====================================================
             * DATABASE
             * =====================================================
             *
             * PreparedStatement use kar rahe hain.
             */

            String sql =
                    "INSERT INTO user " +
                    "(id, first_name, last_name, email, password, " +
                    "username, verified, otp) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";


            try (Connection con =
                         DB.getConnection();

                 PreparedStatement ps =
                         con.prepareStatement(sql)) {


                ps.setInt(1, id);

                ps.setString(
                        2,
                        first_name
                );

                ps.setString(
                        3,
                        last_name
                );

                ps.setString(
                        4,
                        email
                );

                /*
                 * BCrypt HASH save hoga
                 */
                ps.setString(
                        5,
                        hashedPassword
                );

                ps.setString(
                        6,
                        username
                );

                ps.setBoolean(
                        7,
                        verified
                );

                ps.setInt(
                        8,
                        otp
                );


                ps.executeUpdate();
            }


            /*
             * =====================================================
             * SEND OTP
             * =====================================================
             */

            EmailService emailService =
                    new EmailService();


            emailService.send(
                    email,
                    "Verify Email",
                    "<h1>Welcome!</h1>" +
                    "<p>Your OTP is : " +
                    otp +
                    "</p>"
            );


            PrintWriter out =
                    response.getWriter();


            response.setStatus(
                    HttpServletResponse.SC_OK
            );


            out.write(
                    "OTP sent successfully!, Check your Mail!!"
            );


        } catch (SQLException e) {

            System.out.println(
                    "Message: " +
                    e.getMessage()
            );

            System.out.println(
                    "SQLState: " +
                    e.getSQLState()
            );

            System.out.println(
                    "ErrorCode: " +
                    e.getErrorCode()
            );

            e.printStackTrace();


            throw new ServletException(
                    "Unable to create account",
                    e
            );

        } catch (Exception e) {

            e.printStackTrace();

            throw new ServletException(
                    "Unable to create account",
                    e
            );
        }
    }
}