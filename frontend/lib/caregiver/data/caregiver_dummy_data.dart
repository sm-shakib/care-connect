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
    languages: ['English', 'Bengali'],
    about:
        'Experienced registered nurse with over 8 years of providing compassionate home healthcare for elderly patients.',
    nid: '1988123456789',
    certifications: [
      'Advanced Nursing Certificate',
      'Geriatric Care Specialist'
    ],
    gender: 'Female',
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
    languages: ['English', 'Bengali'],
    about:
        'Dedicated caregiver specializing in post-surgery recovery and daily living assistance.',
    nid: '1992987654321',
    certifications: ['Home Care Assistant Training'],
    gender: 'Female',
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
    languages: ['English'],
    about:
        'Licensed physiotherapist helping patients recover mobility and independence.',
    nid: '1985456123789',
    certifications: ['Certified Physiotherapist'],
    gender: 'Male',
  ),
];
