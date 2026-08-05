import '../models/caregiver.dart';

final List<Caregiver> caregiverList = [
  Caregiver(
    id: '1',
    name: 'Sarah Jenkins',
    profession: 'Registered Nurse',
    imageUrl: 'https://i.pravatar.cc/150?u=sarah',
    rating: 4.9,
    experience: 8,
    distance: 2.3,
    hourlyRate: 250,
    isVerified: true,
    specialties: ['Elder Care', 'Dementia Care'],
    about:
    'Experienced registered nurse with over 8 years of providing compassionate home healthcare for elderly patients.',
    gender: 'Female',
    availabilityType: 'Full-time',
  ),
  Caregiver(
    id: '2',
    name: 'Emma Wilson',
    profession: 'Care Assistant',
    imageUrl: 'https://i.pravatar.cc/150?u=emma',
    rating: 4.8,
    experience: 5,
    distance: 3.8,
    hourlyRate: 200,
    isVerified: true,
    specialties: ['Post Surgery', 'Mobility Assistance'],
    about:
    'Dedicated caregiver specializing in post-surgery recovery and daily living assistance.',
    gender: 'Female',
    availabilityType: 'Part-time',
  ),
  Caregiver(
    id: '3',
    name: 'Michael Brown',
    profession: 'Physiotherapist',
    imageUrl: 'https://i.pravatar.cc/150?u=michael',
    rating: 4.7,
    experience: 6,
    distance: 5.0,
    hourlyRate: 350,
    isVerified: false,
    specialties: ['Physiotherapy', 'Rehabilitation'],
    about:
    'Licensed physiotherapist helping patients recover mobility and independence.',
    gender: 'Male',
    availabilityType: 'On-call',
  ),
];