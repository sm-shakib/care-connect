import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings

def send_email(to_email: str, subject: str, body: str):
    """
    Sends an email using SMTP settings from the central config.
    Supports both Port 587 (TLS) and Port 465 (SSL).
    """
    if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
        print("Email not sent: SMTP_USER or SMTP_PASSWORD not set in environment.")
        return False

    msg = MIMEMultipart()
    msg['From'] = settings.FROM_EMAIL or settings.SMTP_USER
    msg['To'] = to_email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))

    try:
        if settings.SMTP_PORT == 465:
            # Use SSL for port 465
            server = smtplib.SMTP_SSL(settings.SMTP_SERVER, settings.SMTP_PORT)
        else:
            # Use TLS for port 587
            server = smtplib.SMTP(settings.SMTP_SERVER, settings.SMTP_PORT)
            server.starttls()

        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
        text = msg.as_string()
        server.sendmail(msg['From'], to_email, text)
        server.quit()
        return True
    except Exception as e:
        print(f"Failed to send email to {to_email}: {e}")
        return False
