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
        veterinarians = [
            {
                'id': 'vet1',
                'name': 'Dr. Sarah Wilson',
                'email': 'sarah.wilson@vetcare.com',
                'cpf': '12345678900',
                'phone': '(11) 98765-4321',
                'role': 'veterinarian',
                'status': 'active',
                'profileCompleted': True,
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
                'name': 'João Silva',
                'email': 'joao.silva@email.com',
                'cpf': '98765432100',
                'phone': '(11) 98888-7777',
                'role': 'tutor',
                'status': 'active',
                'profileCompleted': True,
                'pets': ['pet1', 'pet2'],
                'preferredVetId': 'vet1',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
        ]

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
                'tutorId': 'tutor1',
                'ownerName': 'João Silva',
                'status': 'active',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
        ]

        clinics = [
            {
                'id': 'clinic1',
                'name': 'VetCare Clinic',
                'cnpj': '12345678000190',
                'phone': '(11) 3333-4444',
                'email': 'contact@vetcare.com',
                'veterinarians': ['vet1'],
                'status': 'active',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
        ]

        def add_document(collection_name, data):
            try:
                db.collection(collection_name).document(data['id']).set(data)
                print(f"Added to {collection_name}: {data['id']}")
            except Exception as error:
                print(f"Error adding {data['id']} to {collection_name}: {error}")
                raise error

        # Seed the database
        for vet in veterinarians:
            add_document('users', vet)
        for tutor in tutors:
            add_document('users', tutor)
        for pet in pets:
            add_document('pets', pet)
        for clinic in clinics:
            add_document('clinics', clinic)

        print("Database seeded successfully!")

    except Exception as error:
        print(f"Error seeding database: {error}")
        exit(1)

if __name__ == "__main__":
    seed_database()