from sqlalchemy.orm import Session
from app.db.session import SessionLocal
# Import all models to ensure mappers are initialized
from app.models.user import User
from app.models.elder import Elder
from app.models.family import Family
from app.models.caregiver import Caregiver
from app.models.booking import Booking
from app.models.notification import Notification
from app.models.binding import FamilyElderLink
from app.models.medicine import Medicine
from app.models.complaint import Complaint, ComplaintNote
from app.models.donation import Donation
from app.models.reminder import Appointment, CareReminder
from app.models.chat import Conversation, ConversationParticipant, ConversationKey, Message, MessageAttachment

def mark_donations_completed():
    db = SessionLocal()
    try:
        # Find all pending donations
        pending_donations = db.query(Donation).filter(Donation.payment_status == 'pending').all()
        print(f"Found {len(pending_donations)} pending donations.")

        for donation in pending_donations:
            print(f"Updating Donation #{donation.id} from 'pending' to 'completed'...")
            donation.payment_status = 'completed'

        db.commit()
        print("All pending donations have been marked as COMPLETED successfully!")
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    mark_donations_completed()
