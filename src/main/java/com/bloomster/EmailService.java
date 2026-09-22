package com.bloomster;


import org.simplejavamail.api.email.Email;
import org.simplejavamail.email.EmailBuilder;
import org.simplejavamail.api.mailer.Mailer;
import org.simplejavamail.mailer.MailerBuilder;

public class EmailService {

    private final Mailer mailer;

    public EmailService() {
        mailer = MailerBuilder
                .withSMTPServer(
                        "smtp.gmail.com",
                        587,
                        "Sumitagrawal59856@gmail.com",
                        " ympg ohtw eqqk njjx"
                )
                .buildMailer();
    }

    public void send(String to, String subject, String html) {

        Email email = EmailBuilder.startingBlank()
                .from("My App", "Sumitagrawal59856@gmail.com")
                .to(to)
                .withSubject(subject)
                .withHTMLText(html)
                .buildEmail();

        mailer.sendMail(email);
    }
}


