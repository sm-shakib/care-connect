from sqlalchemy.orm import Session
from app.models.user import User
from app.models.notification import Notification

def notify_admins(db: Session, title: str, body: str, notification_type: str, **kwargs):
    """
    Creates a notification for all admin users.
    """
    admins = db.query(User).filter(User.role == "admin").all()
    for admin in admins:
        notification = Notification(
            user_id=admin.id,
            title=title,
            body=body,
            type=notification_type,
            **kwargs
        )
        db.add(notification)
    # We don't commit here, the caller should commit.
