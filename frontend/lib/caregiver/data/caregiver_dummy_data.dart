import '../models/caregiver.dart';

final List<Caregiver> caregiverList = [
  Caregiver(
    id: '1',
    name: 'Sarah Jenkins',
    profession: 'Registered Nurse',
    imageUrl: 'assets/images/caregiver1.jpg',
    rating: 4.9,
    experience: 8,
    distance: 2.3,
    hourlyRate: 25,
    isVerified: true,
    specialties: ['Elder Care', 'Dementia Care'],
    languages: ['English', 'Spanish'],
    about:
    'Experienced registered nurse with over 8 years of providing compassionate home healthcare for elderly patients.',
  ),

  Caregiver(
    id: '2',
    name: 'Emma Wilson',
    profession: 'Care Assistant',
    imageUrl: 'assets/images/caregiver2.jpg',
    rating: 4.8,
    experience: 5,
    distance: 3.8,
    hourlyRate: 20,
    isVerified: true,
    specialties: ['Post Surgery', 'Mobility Assistance'],
    languages: ['English'],
    about:
    'Dedicated caregiver specializing in post-surgery recovery and daily living assistance.',
  ),

  Caregiver(
    id: '3',
    name: 'Michael Brown',
    profession: 'Physiotherapist',
    imageUrl: 'assets/images/caregiver3.jpg',
    rating: 4.7,
    experience: 6,
    distance: 5.0,
    hourlyRate: 30,
    isVerified: false,
    specialties: ['Physiotherapy', 'Rehabilitation'],
    languages: ['English', 'French'],
    about:
    'Licensed physiotherapist helping patients recover mobility and independence.',
  ),

  Caregiver(
    id: '4',
    name: 'Sophia Green',
    profession: 'Senior Care Specialist',
    imageUrl: 'assets/images/caregiver4.jpg',
    rating: 5.0,
    experience: 10,
    distance: 1.8,
    hourlyRate: 35,
    isVerified: true,
    specialties: ['Senior Care', 'Medication Support'],
    languages: ['English', 'German'],
    about:
    'Highly experienced senior care specialist focused on medication management and companionship.',
  ),

  Caregiver(
    id: '5',
    name: 'David Lee',
    profession: 'Home Nurse',
    imageUrl: 'assets/images/caregiver5.jpg',
    rating: 4.6,
    experience: 4,
    distance: 4.2,
    hourlyRate: 22,
    isVerified: true,
    specialties: ['Home Nursing', 'Diabetes Care'],
    languages: ['English', 'Chinese'],
    about:
    'Professional home nurse experienced in chronic disease management and patient monitoring.',
  ),
];