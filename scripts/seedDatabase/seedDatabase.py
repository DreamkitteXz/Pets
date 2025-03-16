import os
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Firebase Admin SDK
cred = credentials.Certificate("d:/Projects/crud-app/scripts/seedDatabase/cred.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def create_timestamp(date_str=None):
    if date_str:
        return datetime.strptime(date_str, '%Y-%m-%d')
    return firestore.SERVER_TIMESTAMP

def seed_database():
    try:
        # Users collection (including both veterinarians and tutors)
        veterinarians = [
            {
                'id': 'vet1',
                'email': 'sarah.wilson@vetcare.com',
                'name': 'Dr. Sarah Wilson',
                'cpf': '12345678900',
                'phone': '(11) 98765-4321',
                'profileCompleted': True,
                'role': 'veterinarian',
                'status': 'active',
                'address': {
                    'street': 'Av. Paulista',
                    'number': '1000',
                    'complement': 'Sala 101',
                    'neighborhood': 'Bela Vista',
                    'city': 'São Paulo',
                    'state': 'SP',
                    'zipCode': '01310-100'
                },
                'crmv': 'CRMV-SP 12345',
                'specialties': ['Small Animals', 'Surgery', 'Dermatology'],
                'yearsOfExperience': 8,
                'clinicId': 'clinic1',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
        ]

        tutors = [
            {
                'id': 'tutor1',
                'email': 'joao.silva@email.com',
                'name': 'João Silva',
                'cpf': '98765432100',
                'phone': '(11) 98888-7777',
                'profileCompleted': True,
                'role': 'tutor',
                'status': 'active',
                'address': {
                    'street': 'Rua Augusta',
                    'number': '500',
                    'complement': 'Apto 52',
                    'neighborhood': 'Consolação',
                    'city': 'São Paulo',
                    'state': 'SP',
                    'zipCode': '01304-000'
                },
                'pets': ['pet1', 'pet2'],
                'preferredVetId': 'vet1',
                'emergencyContact': {
                    'name': 'Maria Silva',
                    'phone': '(11) 97777-6666',
                    'relationship': 'Spouse'
                },
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
        ]

        # Vaccines collection
        vaccines = [
            {
                'id': 'vaccine1',
                'name': 'V10 (Polivalente)',
                'manufacturer': 'Zoetis',
                'batchNumber': 'ZT123456',
                'expirationDate': create_timestamp('2025-12-31'),
                'administrationDate': create_timestamp('2023-06-15'),
                'nextDueDate': create_timestamp('2024-06-15'),
                'petId': 'pet1',
                'petName': 'Max',
                'petSpecies': 'Dog',
                'petBreed': 'Labrador',
                'petWeight': 25.5,
                'ownerId': 'tutor1',
                'ownerName': 'João Silva',
                'ownerContact': '(11) 98888-7777',
                'veterinarianId': 'vet1',
                'veterinarianName': 'Dr. Sarah Wilson',
                'crmvNumber': 'CRMV-SP 12345',
                'clinicName': 'VetCare Clinic',
                'clinicCnpj': '12345678000190',
                'clinicAddress': {
                    'street': 'Av. Paulista',
                    'number': '1000',
                    'neighborhood': 'Bela Vista',
                    'city': 'São Paulo',
                    'state': 'SP'
                },
                'status': 'approved',
                'validationDetails': {
                    'validatedAt': create_timestamp('2023-06-15'),
                    'validatedBy': 'vet1',
                    'notes': 'Vaccine administered according to protocol',
                    'rejectionReason': ''
                },
                'labelImage': 'https://storage.firebase.com/vaccines/labels/vaccine1.jpg',
                'notes': 'Pet showed no adverse reaction',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
        ]

        # Pets collection
        pets = [
            {
                'id': 'pet1',
                'name': 'Max',
                'species': 'Dog',
                'breed': 'Labrador',
                'birthDate': create_timestamp('2020-01-15'),
                'color': 'Golden',
                'gender': 'Male',
                'weight': 25.5,
                'isNeutered': True,
                'chipNumber': 'CHIP123456',
                'ownerId': 'tutor1',
                'ownerName': 'João Silva',
                'vaccines': ['vaccine1'],
                'veterinarians': ['vet1'],
                'status': 'active',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP,
                'createdBy': 'vet1',
                'tutorId': 'tutor1',
                'emergencyContacts': [
                    {
                        'name': 'Maria Silva',
                        'phone': '(11) 97777-6666',
                        'relationship': 'Spouse'
                    }
                ],
                'medicalNotes': 'Healthy dog with no major health issues',
                'allergies': ['Chicken'],
                'chronicConditions': 'None'
            },
            {
                'id': 'pet2',
                'name': 'Luna',
                'species': 'Cat',
                'breed': 'Siamese',
                'birthDate': create_timestamp('2021-03-10'),
                'color': 'Cream with brown points',
                'gender': 'Female',
                'weight': 4.2,
                'isNeutered': True,
                'chipNumber': 'CHIP654321',
                'ownerId': 'tutor1',
                'ownerName': 'João Silva',
                'vaccines': [],
                'veterinarians': ['vet1'],
                'status': 'active',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP,
                'createdBy': 'vet1',
                'tutorId': 'tutor1',
                'emergencyContacts': [
                    {
                        'name': 'Maria Silva',
                        'phone': '(11) 97777-6666',
                        'relationship': 'Spouse'
                    }
                ],
                'medicalNotes': 'Healthy cat, regular check-ups',
                'allergies': [],
                'chronicConditions': 'None'
            }
        ]

        # Clinics collection
        clinics = [
            {
                'id': 'clinic1',
                'name': 'VetCare Clinic',
                'cnpj': '12345678000190',
                'phone': '(11) 3333-4444',
                'email': 'contact@vetcare.com',
                'address': {
                    'street': 'Av. Paulista',
                    'number': '1000',
                    'complement': 'Térreo',
                    'neighborhood': 'Bela Vista',
                    'city': 'São Paulo',
                    'state': 'SP',
                    'zipCode': '01310-100'
                },
                'veterinarians': ['vet1'],
                'status': 'active',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
        ]

        # Appointments collection
        appointments = [
            {
                'id': 'appointment1',
                'petId': 'pet1',
                'tutorId': 'tutor1',
                'veterinarianId': 'vet1',
                'clinicId': 'clinic1',
                'date': create_timestamp('2023-07-10'),
                'type': 'checkup',
                'status': 'completed',
                'notes': 'Regular annual check-up, all vitals normal',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            },
            {
                'id': 'appointment2',
                'petId': 'pet2',
                'tutorId': 'tutor1',
                'veterinarianId': 'vet1',
                'clinicId': 'clinic1',
                'date': create_timestamp('2023-07-15'),
                'type': 'vaccination',
                'status': 'scheduled',
                'notes': 'First vaccination appointment',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
        ]

        def add_document(collection_name, data):
            try:
                doc_id = data.pop('id')
                db.collection(collection_name).document(doc_id).set(data)
                print(f"Added to {collection_name}: {doc_id}")
            except Exception as error:
                print(f"Error adding document to {collection_name}: {error}")
                raise error

        # Seed the database
        for vet in veterinarians:
            add_document('users', vet)
        for tutor in tutors:
            add_document('users', tutor)
        for vaccine in vaccines:
            add_document('vaccines', vaccine)
        for pet in pets:
            add_document('pets', pet)
        for clinic in clinics:
            add_document('clinics', clinic)
        for appointment in appointments:
            add_document('appointments', appointment)

        print("Database seeded successfully!")

    except Exception as error:
        print(f"Error seeding database: {error}")
        exit(1)

if __name__ == "__main__":
    seed_database()