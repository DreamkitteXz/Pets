#!/usr/bin/env python3
"""
Seed script para o banco de dados da plataforma Pets.
Cria usuários no Firebase Auth e documentos em todas as coleções do Firestore.

Uso:
    python seedDatabase.py          # idempotente: só cria o que ainda não existe
    python seedDatabase.py --reset  # apaga todos os dados seed e reinicia
"""
import os
import sys
import argparse
from datetime import datetime, timezone, timedelta

import firebase_admin
from firebase_admin import credentials, firestore, auth as fb_auth

# ---------------------------------------------------------------------------
# Inicialização do Firebase
# ---------------------------------------------------------------------------
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
cred = credentials.Certificate(os.path.join(SCRIPT_DIR, 'cred.json'))
firebase_admin.initialize_app(cred)
db = firestore.client()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def ts(date_str=None, days_offset=0):
    """Retorna um datetime UTC. Formato de date_str: 'YYYY-MM-DD'."""
    if date_str:
        dt = datetime.strptime(date_str, '%Y-%m-%d').replace(tzinfo=timezone.utc)
    else:
        dt = datetime.now(timezone.utc)
    return dt + timedelta(days=days_offset)


def ensure_auth_user(uid, email, password, display_name, email_verified=True):
    """Cria um usuário no Firebase Auth se ainda não existir."""
    try:
        fb_auth.get_user(uid)
        print(f'  [skip]   Auth  {email}')
    except fb_auth.UserNotFoundError:
        fb_auth.create_user(
            uid=uid,
            email=email,
            password=password,
            display_name=display_name,
            email_verified=email_verified,
        )
        print(f'  [create] Auth  {email}')


def upsert(collection, doc_id, data):
    """Salva um documento no Firestore (sobrescreve se existir)."""
    db.collection(collection).document(doc_id).set(data)
    print(f'  [upsert] {collection}/{doc_id}')


def delete_collection(collection):
    """Apaga todos os documentos de uma coleção."""
    for doc in db.collection(collection).stream():
        doc.reference.delete()
    print(f'  [reset]  {collection}')


def delete_auth_user(uid):
    try:
        fb_auth.delete_user(uid)
        print(f'  [reset]  Auth uid={uid}')
    except fb_auth.UserNotFoundError:
        pass


# ---------------------------------------------------------------------------
# Constantes de IDs de seed
# ---------------------------------------------------------------------------
SEED_UIDS = ['vet_seed_001', 'vet_seed_002', 'tutor_seed_001', 'tutor_seed_002']
SEED_COLLECTIONS = ['users', 'clinics', 'pets', 'vaccines', 'appointments', 'deworming']

# ---------------------------------------------------------------------------
# Usuários do Firebase Auth
# ---------------------------------------------------------------------------
AUTH_USERS = [
    {
        'uid': 'vet_seed_001',
        'email': 'vet1@petapp.dev',
        'password': 'Vet@12345',
        'display_name': 'Dra. Ana Beatriz Santos',
    },
    {
        'uid': 'vet_seed_002',
        'email': 'vet2@petapp.dev',
        'password': 'Vet@12345',
        'display_name': 'Dr. Carlos Eduardo Lima',
    },
    {
        'uid': 'tutor_seed_001',
        'email': 'tutor1@petapp.dev',
        'password': 'Tutor@12345',
        'display_name': 'Maria Fernanda Costa',
    },
    {
        'uid': 'tutor_seed_002',
        'email': 'tutor2@petapp.dev',
        'password': 'Tutor@12345',
        'display_name': 'Roberto Alves Nunes',
    },
]

# ---------------------------------------------------------------------------
# Documentos do Firestore
# ---------------------------------------------------------------------------
FIRESTORE_DOCS = {
    'users': {
        'vet_seed_001': {
            'email': 'vet1@petapp.dev',
            'name': 'Dra. Ana Beatriz Santos',
            'cpf': '321.654.987-00',
            'phone': '(11) 94321-8765',
            'profileCompleted': True,
            'role': 'veterinarian',
            'status': 'active',
            'emailVerified': True,
            'darkMode': False,
            'notifications': True,
            'language': 'pt-BR',
            'twoFactorAuth': False,
            'address': {
                'street': 'Av. Paulista',
                'number': '1500',
                'complement': 'Sala 210',
                'neighborhood': 'Bela Vista',
                'city': 'São Paulo',
                'state': 'SP',
                'zipCode': '01310-200',
            },
            'crmv': 'CRMV-SP 67890',
            'specialties': ['Clínica Geral', 'Cirurgia', 'Cardiologia'],
            'yearsOfExperience': 12,
            'clinicId': 'clinic_seed_001',
            'createdAt': ts('2024-01-15'),
            'updatedAt': ts('2025-11-10'),
        },
        'vet_seed_002': {
            'email': 'vet2@petapp.dev',
            'name': 'Dr. Carlos Eduardo Lima',
            'cpf': '456.789.123-00',
            'phone': '(21) 97654-3210',
            'profileCompleted': True,
            'role': 'veterinarian',
            'status': 'active',
            'emailVerified': True,
            'darkMode': True,
            'notifications': True,
            'language': 'pt-BR',
            'twoFactorAuth': False,
            'address': {
                'street': 'Rua Voluntários da Pátria',
                'number': '300',
                'complement': 'Sala 05',
                'neighborhood': 'Botafogo',
                'city': 'Rio de Janeiro',
                'state': 'RJ',
                'zipCode': '22270-010',
            },
            'crmv': 'CRMV-RJ 11223',
            'specialties': ['Dermatologia', 'Oncologia', 'Animais Exóticos'],
            'yearsOfExperience': 7,
            'clinicId': 'clinic_seed_002',
            'createdAt': ts('2024-03-22'),
            'updatedAt': ts('2025-12-01'),
        },
        'tutor_seed_001': {
            'email': 'tutor1@petapp.dev',
            'name': 'Maria Fernanda Costa',
            'cpf': '111.222.333-44',
            'phone': '(11) 91234-5678',
            'profileCompleted': True,
            'role': 'tutor',
            'status': 'active',
            'emailVerified': True,
            'darkMode': False,
            'notifications': True,
            'language': 'pt-BR',
            'twoFactorAuth': False,
            'address': {
                'street': 'Rua das Flores',
                'number': '123',
                'complement': 'Apto 41',
                'neighborhood': 'Pinheiros',
                'city': 'São Paulo',
                'state': 'SP',
                'zipCode': '05422-010',
            },
            'pets': ['pet_seed_001', 'pet_seed_002'],
            'preferredVetId': 'vet_seed_001',
            'emergencyContact': {
                'name': 'José Costa',
                'phone': '(11) 98888-0000',
                'relationship': 'Marido',
            },
            'createdAt': ts('2024-02-10'),
            'updatedAt': ts('2025-10-30'),
        },
        'tutor_seed_002': {
            'email': 'tutor2@petapp.dev',
            'name': 'Roberto Alves Nunes',
            'cpf': '555.666.777-88',
            'phone': '(21) 99876-5432',
            'profileCompleted': True,
            'role': 'tutor',
            'status': 'active',
            'emailVerified': True,
            'darkMode': False,
            'notifications': False,
            'language': 'pt-BR',
            'twoFactorAuth': False,
            'address': {
                'street': 'Av. das Américas',
                'number': '4200',
                'complement': 'Casa 3',
                'neighborhood': 'Barra da Tijuca',
                'city': 'Rio de Janeiro',
                'state': 'RJ',
                'zipCode': '22640-102',
            },
            'pets': ['pet_seed_003', 'pet_seed_004', 'pet_seed_005'],
            'preferredVetId': 'vet_seed_002',
            'emergencyContact': {
                'name': 'Lucia Nunes',
                'phone': '(21) 97777-1111',
                'relationship': 'Esposa',
            },
            'createdAt': ts('2024-04-05'),
            'updatedAt': ts('2025-09-15'),
        },
    },
    'clinics': {
        'clinic_seed_001': {
            'name': 'VetLife Clínica Veterinária',
            'cnpj': '12.345.678/0001-90',
            'phone': '(11) 3333-4444',
            'email': 'contato@vetlife.com.br',
            'address': {
                'street': 'Av. Paulista',
                'number': '1500',
                'complement': 'Térreo',
                'neighborhood': 'Bela Vista',
                'city': 'São Paulo',
                'state': 'SP',
                'zipCode': '01310-200',
            },
            'veterinarians': ['vet_seed_001'],
            'status': 'active',
            'createdAt': ts('2023-06-01'),
            'updatedAt': ts('2025-08-20'),
        },
        'clinic_seed_002': {
            'name': 'PetSaúde Centro Clínico',
            'cnpj': '98.765.432/0001-10',
            'phone': '(21) 2222-3333',
            'email': 'atendimento@petsaude.com.br',
            'address': {
                'street': 'Rua Voluntários da Pátria',
                'number': '300',
                'complement': 'Loja 1',
                'neighborhood': 'Botafogo',
                'city': 'Rio de Janeiro',
                'state': 'RJ',
                'zipCode': '22270-010',
            },
            'veterinarians': ['vet_seed_002'],
            'status': 'active',
            'createdAt': ts('2023-09-15'),
            'updatedAt': ts('2025-07-10'),
        },
    },
    'pets': {
        'pet_seed_001': {
            'name': 'Rex',
            'species': 'Cachorro',
            'breed': 'Golden Retriever',
            'birthDate': ts('2021-03-10'),
            'color': 'Dourado',
            'gender': 'Macho',
            'weight': 28.5,
            'isNeutered': True,
            'chipNumber': 'BRA123456789',
            'ownerId': 'tutor_seed_001',
            'ownerName': 'Maria Fernanda Costa',
            'vaccines': ['vac_seed_001', 'vac_seed_002', 'vac_seed_006'],
            'veterinarians': ['vet_seed_001'],
            'status': 'active',
            'createdAt': ts('2024-02-15'),
            'updatedAt': ts('2025-11-20'),
            'createdBy': 'vet_seed_001',
            'tutorId': 'tutor_seed_001',
            'emergencyContacts': [
                {'name': 'José Costa', 'phone': '(11) 98888-0000', 'relationship': 'Tutor substituto'},
            ],
            'medicalNotes': 'Animal saudável. Histórico de displasia de quadril leve.',
            'allergies': ['Frango'],
            'chronicConditions': 'Displasia de quadril grau I',
        },
        'pet_seed_002': {
            'name': 'Mia',
            'species': 'Gato',
            'breed': 'Persa',
            'birthDate': ts('2020-07-22'),
            'color': 'Branco',
            'gender': 'Fêmea',
            'weight': 4.1,
            'isNeutered': True,
            'chipNumber': 'BRA987654321',
            'ownerId': 'tutor_seed_001',
            'ownerName': 'Maria Fernanda Costa',
            'vaccines': ['vac_seed_003'],
            'veterinarians': ['vet_seed_001'],
            'status': 'active',
            'createdAt': ts('2024-02-15'),
            'updatedAt': ts('2025-10-05'),
            'createdBy': 'vet_seed_001',
            'tutorId': 'tutor_seed_001',
            'emergencyContacts': [],
            'medicalNotes': 'Propensa a DRC. Dieta úmida recomendada.',
            'allergies': [],
            'chronicConditions': 'Doença Renal Crônica grau I',
        },
        'pet_seed_003': {
            'name': 'Thor',
            'species': 'Cachorro',
            'breed': 'Bulldog Francês',
            'birthDate': ts('2022-11-05'),
            'color': 'Branco e tigrado',
            'gender': 'Macho',
            'weight': 11.2,
            'isNeutered': False,
            'chipNumber': 'BRA112233445',
            'ownerId': 'tutor_seed_002',
            'ownerName': 'Roberto Alves Nunes',
            'vaccines': ['vac_seed_004'],
            'veterinarians': ['vet_seed_002'],
            'status': 'active',
            'createdAt': ts('2024-05-01'),
            'updatedAt': ts('2025-09-20'),
            'createdBy': 'vet_seed_002',
            'tutorId': 'tutor_seed_002',
            'emergencyContacts': [
                {'name': 'Lucia Nunes', 'phone': '(21) 97777-1111', 'relationship': 'Tutora substituta'},
            ],
            'medicalNotes': 'Problemas respiratórios típicos da raça. Evitar esforço físico intenso.',
            'allergies': ['Proteína de leite'],
            'chronicConditions': 'Síndrome braquicefálica',
        },
        'pet_seed_004': {
            'name': 'Cleo',
            'species': 'Gato',
            'breed': 'Maine Coon',
            'birthDate': ts('2019-05-18'),
            'color': 'Tabby marrom',
            'gender': 'Fêmea',
            'weight': 6.8,
            'isNeutered': True,
            'chipNumber': 'BRA556677889',
            'ownerId': 'tutor_seed_002',
            'ownerName': 'Roberto Alves Nunes',
            'vaccines': ['vac_seed_005'],
            'veterinarians': ['vet_seed_001', 'vet_seed_002'],
            'status': 'active',
            'createdAt': ts('2024-01-20'),
            'updatedAt': ts('2025-12-01'),
            'createdBy': 'vet_seed_002',
            'tutorId': 'tutor_seed_002',
            'emergencyContacts': [],
            'medicalNotes': 'Animal idoso. Artrite nas patas traseiras.',
            'allergies': [],
            'chronicConditions': 'Artrite',
        },
        'pet_seed_005': {
            'name': 'Piu',
            'species': 'Pássaro',
            'breed': 'Calopsita',
            'birthDate': ts('2023-02-14'),
            'color': 'Amarelo e cinza',
            'gender': 'Macho',
            'weight': 0.09,
            'isNeutered': False,
            'chipNumber': '',
            'ownerId': 'tutor_seed_002',
            'ownerName': 'Roberto Alves Nunes',
            'vaccines': [],
            'veterinarians': ['vet_seed_002'],
            'status': 'active',
            'createdAt': ts('2024-06-10'),
            'updatedAt': ts('2025-06-10'),
            'createdBy': 'vet_seed_002',
            'tutorId': 'tutor_seed_002',
            'emergencyContacts': [],
            'medicalNotes': 'Animal saudável. Consulta anual recomendada.',
            'allergies': [],
            'chronicConditions': '',
        },
    },
    'vaccines': {
        'vac_seed_001': {
            'name': 'V10 Polivalente',
            'manufacturer': 'Zoetis',
            'batchNumber': 'ZT-2024-001',
            'expirationDate': ts('2026-06-30'),
            'administrationDate': ts('2025-06-15'),
            'nextDueDate': ts('2026-06-15'),
            'petId': 'pet_seed_001',
            'petName': 'Rex',
            'petSpecies': 'Cachorro',
            'petBreed': 'Golden Retriever',
            'petWeight': 28.5,
            'ownerId': 'tutor_seed_001',
            'ownerName': 'Maria Fernanda Costa',
            'ownerContact': '(11) 91234-5678',
            'veterinarianId': 'vet_seed_001',
            'veterinarianName': 'Dra. Ana Beatriz Santos',
            'crmvNumber': 'CRMV-SP 67890',
            'clinicName': 'VetLife Clínica Veterinária',
            'clinicCnpj': '12.345.678/0001-90',
            'clinicAddress': {
                'street': 'Av. Paulista', 'number': '1500',
                'neighborhood': 'Bela Vista', 'city': 'São Paulo', 'state': 'SP',
            },
            'status': 'approved',
            'validationDetails': {
                'vetValidation': {
                    'status': 'approved',
                    'validatedAt': ts('2025-06-15'),
                    'validatedBy': 'vet_seed_001',
                    'validatedByName': 'Dra. Ana Beatriz Santos',
                    'validatedByCrmv': 'CRMV-SP 67890',
                    'notes': 'Aplicação conforme protocolo. Animal reagiu bem.',
                    'rejectionReason': '',
                },
                'tutorValidation': {
                    'status': 'approved',
                    'validatedAt': ts('2025-06-16'),
                    'validatedBy': 'tutor_seed_001',
                    'notes': '',
                    'rejectionReason': '',
                },
            },
            'labelImage': 'https://placehold.co/600x400/EEF2FF/4338CA?text=V10+Polivalente',
            'labelImageMetadata': {
                'name': 'rotulo_v10_rex_20250615.jpg',
                'size': 248320,
                'contentType': 'image/jpeg',
                'timeCreated': ts('2025-06-15'),
                'updated': ts('2025-06-15'),
                'location': {
                    'latitude': -23.5613,
                    'longitude': -46.6566,
                },
            },
            'notes': 'Sem reação adversa observada.',
            'createdAt': ts('2025-06-15'),
            'updatedAt': ts('2025-06-16'),
        },
        'vac_seed_002': {
            'name': 'Antirrábica',
            'manufacturer': 'MSD Saúde Animal',
            'batchNumber': 'MSD-2025-R77',
            'expirationDate': ts('2026-12-31'),
            'administrationDate': ts('2025-09-10'),
            'nextDueDate': ts('2026-09-10'),
            'petId': 'pet_seed_001',
            'petName': 'Rex',
            'petSpecies': 'Cachorro',
            'petBreed': 'Golden Retriever',
            'petWeight': 28.5,
            'ownerId': 'tutor_seed_001',
            'ownerName': 'Maria Fernanda Costa',
            'ownerContact': '(11) 91234-5678',
            'veterinarianId': 'vet_seed_001',
            'veterinarianName': 'Dra. Ana Beatriz Santos',
            'crmvNumber': 'CRMV-SP 67890',
            'clinicName': 'VetLife Clínica Veterinária',
            'clinicCnpj': '12.345.678/0001-90',
            'clinicAddress': {
                'street': 'Av. Paulista', 'number': '1500',
                'neighborhood': 'Bela Vista', 'city': 'São Paulo', 'state': 'SP',
            },
            'status': 'vetApproved',
            'validationDetails': {
                'vetValidation': {
                    'status': 'approved',
                    'validatedAt': ts('2025-09-10'),
                    'validatedBy': 'vet_seed_001',
                    'validatedByName': 'Dra. Ana Beatriz Santos',
                    'validatedByCrmv': 'CRMV-SP 67890',
                    'notes': 'Vacina obrigatória aplicada conforme calendário.',
                    'rejectionReason': '',
                },
                'tutorValidation': {
                    'status': 'pending',
                    'validatedAt': None,
                    'validatedBy': '',
                    'notes': '',
                    'rejectionReason': '',
                },
            },
            'labelImage': 'https://placehold.co/600x400/FEF3C7/D97706?text=Antirrabica',
            'labelImageMetadata': {
                'name': 'rotulo_antirabica_rex_20250910.jpg',
                'size': 193024,
                'contentType': 'image/jpeg',
                'timeCreated': ts('2025-09-10'),
                'updated': ts('2025-09-10'),
                'location': {
                    'latitude': -23.5613,
                    'longitude': -46.6566,
                },
            },
            'notes': 'Aguardando confirmação do tutor.',
            'createdAt': ts('2025-09-10'),
            'updatedAt': ts('2025-09-10'),
        },
        'vac_seed_003': {
            'name': 'Leucemia Felina (FeLV)',
            'manufacturer': 'Boehringer Ingelheim',
            'batchNumber': 'BI-2025-F44',
            'expirationDate': ts('2027-03-31'),
            'administrationDate': ts('2025-11-20'),
            'nextDueDate': ts('2026-11-20'),
            'petId': 'pet_seed_002',
            'petName': 'Mia',
            'petSpecies': 'Gato',
            'petBreed': 'Persa',
            'petWeight': 4.1,
            'ownerId': 'tutor_seed_001',
            'ownerName': 'Maria Fernanda Costa',
            'ownerContact': '(11) 91234-5678',
            'veterinarianId': 'vet_seed_001',
            'veterinarianName': 'Dra. Ana Beatriz Santos',
            'crmvNumber': 'CRMV-SP 67890',
            'clinicName': 'VetLife Clínica Veterinária',
            'clinicCnpj': '12.345.678/0001-90',
            'clinicAddress': {
                'street': 'Av. Paulista', 'number': '1500',
                'neighborhood': 'Bela Vista', 'city': 'São Paulo', 'state': 'SP',
            },
            'status': 'pending',
            'validationDetails': {
                'vetValidation': {
                    'status': 'pending',
                    'validatedAt': None,
                    'validatedBy': '',
                    'validatedByName': '',
                    'validatedByCrmv': '',
                    'notes': '',
                    'rejectionReason': '',
                },
                'tutorValidation': {
                    'status': 'pending',
                    'validatedAt': None,
                    'validatedBy': '',
                    'notes': '',
                    'rejectionReason': '',
                },
            },
            'labelImage': 'https://placehold.co/600x400/ECFDF5/059669?text=FeLV',
            'labelImageMetadata': {
                'name': 'rotulo_felv_mia_20251120.jpg',
                'size': 221184,
                'contentType': 'image/jpeg',
                'timeCreated': ts('2025-11-20'),
                'updated': ts('2025-11-20'),
                'location': {
                    'latitude': -23.5613,
                    'longitude': -46.6566,
                },
            },
            'notes': 'Aguardando revisão do veterinário.',
            'createdAt': ts('2025-11-20'),
            'updatedAt': ts('2025-11-20'),
        },
        'vac_seed_004': {
            'name': 'V8 Polivalente',
            'manufacturer': 'Ourofino',
            'batchNumber': 'OF-2025-D99',
            'expirationDate': ts('2026-08-31'),
            'administrationDate': ts('2025-08-05'),
            'nextDueDate': ts('2026-08-05'),
            'petId': 'pet_seed_003',
            'petName': 'Thor',
            'petSpecies': 'Cachorro',
            'petBreed': 'Bulldog Francês',
            'petWeight': 11.2,
            'ownerId': 'tutor_seed_002',
            'ownerName': 'Roberto Alves Nunes',
            'ownerContact': '(21) 99876-5432',
            'veterinarianId': 'vet_seed_002',
            'veterinarianName': 'Dr. Carlos Eduardo Lima',
            'crmvNumber': 'CRMV-RJ 11223',
            'clinicName': 'PetSaúde Centro Clínico',
            'clinicCnpj': '98.765.432/0001-10',
            'clinicAddress': {
                'street': 'Rua Voluntários da Pátria', 'number': '300',
                'neighborhood': 'Botafogo', 'city': 'Rio de Janeiro', 'state': 'RJ',
            },
            'status': 'vetRejected',
            'validationDetails': {
                'vetValidation': {
                    'status': 'rejected',
                    'validatedAt': ts('2025-08-06'),
                    'validatedBy': 'vet_seed_002',
                    'validatedByName': 'Dr. Carlos Eduardo Lima',
                    'validatedByCrmv': 'CRMV-RJ 11223',
                    'notes': '',
                    'rejectionReason': 'Lote não reconhecido. Solicitar nota fiscal do fabricante.',
                },
                'tutorValidation': {
                    'status': 'pending',
                    'validatedAt': None,
                    'validatedBy': '',
                    'notes': '',
                    'rejectionReason': '',
                },
            },
            'labelImage': 'https://placehold.co/600x400/FFF7ED/EA580C?text=V8+Polivalente',
            'labelImageMetadata': {
                'name': 'rotulo_v8_thor_20250805.jpg',
                'size': 175104,
                'contentType': 'image/jpeg',
                'timeCreated': ts('2025-08-05'),
                'updated': ts('2025-08-06'),
                'location': {
                    'latitude': -22.9416,
                    'longitude': -43.1806,
                },
            },
            'notes': 'Lote questionável — aguardando documentação do fabricante.',
            'createdAt': ts('2025-08-05'),
            'updatedAt': ts('2025-08-06'),
        },
        'vac_seed_005': {
            'name': 'Tríplice Felina (FVRCP)',
            'manufacturer': 'Zoetis',
            'batchNumber': 'ZT-2024-C55',
            'expirationDate': ts('2026-09-30'),
            'administrationDate': ts('2025-09-01'),
            'nextDueDate': ts('2026-09-01'),
            'petId': 'pet_seed_004',
            'petName': 'Cleo',
            'petSpecies': 'Gato',
            'petBreed': 'Maine Coon',
            'petWeight': 6.8,
            'ownerId': 'tutor_seed_002',
            'ownerName': 'Roberto Alves Nunes',
            'ownerContact': '(21) 99876-5432',
            'veterinarianId': 'vet_seed_002',
            'veterinarianName': 'Dr. Carlos Eduardo Lima',
            'crmvNumber': 'CRMV-RJ 11223',
            'clinicName': 'PetSaúde Centro Clínico',
            'clinicCnpj': '98.765.432/0001-10',
            'clinicAddress': {
                'street': 'Rua Voluntários da Pátria', 'number': '300',
                'neighborhood': 'Botafogo', 'city': 'Rio de Janeiro', 'state': 'RJ',
            },
            'status': 'approved',
            'validationDetails': {
                'vetValidation': {
                    'status': 'approved',
                    'validatedAt': ts('2025-09-01'),
                    'validatedBy': 'vet_seed_002',
                    'validatedByName': 'Dr. Carlos Eduardo Lima',
                    'validatedByCrmv': 'CRMV-RJ 11223',
                    'notes': 'Animal idoso — dose ajustada conforme peso e condição.',
                    'rejectionReason': '',
                },
                'tutorValidation': {
                    'status': 'approved',
                    'validatedAt': ts('2025-09-02'),
                    'validatedBy': 'tutor_seed_002',
                    'notes': '',
                    'rejectionReason': '',
                },
            },
            'labelImage': 'https://placehold.co/600x400/F0FDF4/16A34A?text=FVRCP',
            'labelImageMetadata': {
                'name': 'rotulo_fvrcp_cleo_20250901.jpg',
                'size': 264192,
                'contentType': 'image/jpeg',
                'timeCreated': ts('2025-09-01'),
                'updated': ts('2025-09-01'),
                'location': {
                    'latitude': -22.9416,
                    'longitude': -43.1806,
                },
            },
            'notes': 'Reforço anual. Monitorar em 48h.',
            'createdAt': ts('2025-09-01'),
            'updatedAt': ts('2025-09-02'),
        },
        'vac_seed_006': {
            'name': 'Giárdia',
            'manufacturer': 'MSD Saúde Animal',
            'batchNumber': 'MSD-2025-G12',
            'expirationDate': ts('2026-10-31'),
            'administrationDate': ts('2025-10-20'),
            'nextDueDate': ts('2026-04-20'),
            'petId': 'pet_seed_001',
            'petName': 'Rex',
            'petSpecies': 'Cachorro',
            'petBreed': 'Golden Retriever',
            'petWeight': 28.5,
            'ownerId': 'tutor_seed_001',
            'ownerName': 'Maria Fernanda Costa',
            'ownerContact': '(11) 91234-5678',
            'veterinarianId': 'vet_seed_001',
            'veterinarianName': 'Dra. Ana Beatriz Santos',
            'crmvNumber': 'CRMV-SP 67890',
            'clinicName': 'VetLife Clínica Veterinária',
            'clinicCnpj': '12.345.678/0001-90',
            'clinicAddress': {
                'street': 'Av. Paulista', 'number': '1500',
                'neighborhood': 'Bela Vista', 'city': 'São Paulo', 'state': 'SP',
            },
            'status': 'vetApproved',
            'validationDetails': {
                'vetValidation': {
                    'status': 'approved',
                    'validatedAt': ts('2025-10-20'),
                    'validatedBy': 'vet_seed_001',
                    'validatedByName': 'Dra. Ana Beatriz Santos',
                    'validatedByCrmv': 'CRMV-SP 67890',
                    'notes': 'Protocolo semestral aplicado.',
                    'rejectionReason': '',
                },
                'tutorValidation': {
                    'status': 'pending',
                    'validatedAt': None,
                    'validatedBy': '',
                    'notes': '',
                    'rejectionReason': '',
                },
            },
            'labelImage': 'https://placehold.co/600x400/EFF6FF/2563EB?text=Giardia',
            'labelImageMetadata': {
                'name': 'rotulo_giardia_rex_20251020.jpg',
                'size': 209920,
                'contentType': 'image/jpeg',
                'timeCreated': ts('2025-10-20'),
                'updated': ts('2025-10-20'),
                'location': {
                    'latitude': -23.5613,
                    'longitude': -46.6566,
                },
            },
            'notes': '',
            'createdAt': ts('2025-10-20'),
            'updatedAt': ts('2025-10-20'),
        },
    },
    'appointments': {
        'appt_seed_001': {
            'petId': 'pet_seed_001',
            'tutorId': 'tutor_seed_001',
            'veterinarianId': 'vet_seed_001',
            'clinicId': 'clinic_seed_001',
            'date': ts('2025-06-15'),
            'type': 'checkup',
            'status': 'completed',
            'notes': 'Check-up anual. Todos os parâmetros normais. Peso estável.',
            'createdAt': ts('2025-06-10'),
            'updatedAt': ts('2025-06-15'),
        },
        'appt_seed_002': {
            'petId': 'pet_seed_002',
            'tutorId': 'tutor_seed_001',
            'veterinarianId': 'vet_seed_001',
            'clinicId': 'clinic_seed_001',
            'date': ts(days_offset=14),
            'type': 'vaccination',
            'status': 'scheduled',
            'notes': 'Vacinação anual programada — FeLV e V4.',
            'createdAt': ts(days_offset=0),
            'updatedAt': ts(days_offset=0),
        },
        'appt_seed_003': {
            'petId': 'pet_seed_003',
            'tutorId': 'tutor_seed_002',
            'veterinarianId': 'vet_seed_002',
            'clinicId': 'clinic_seed_002',
            'date': ts('2025-07-22'),
            'type': 'emergency',
            'status': 'cancelled',
            'notes': 'Cancelado pelo tutor — animal se recuperou sem necessidade de consulta.',
            'createdAt': ts('2025-07-20'),
            'updatedAt': ts('2025-07-21'),
        },
        'appt_seed_004': {
            'petId': 'pet_seed_004',
            'tutorId': 'tutor_seed_002',
            'veterinarianId': 'vet_seed_002',
            'clinicId': 'clinic_seed_002',
            'date': ts('2025-10-12'),
            'type': 'surgery',
            'status': 'completed',
            'notes': 'Extração dentária. Pós-operatório sem intercorrências.',
            'createdAt': ts('2025-10-05'),
            'updatedAt': ts('2025-10-12'),
        },
    },
    'deworming': {
        'dew_seed_001': {
            'name': 'Milbemax',
            'manufacturer': 'Elanco',
            'dosage': '1 comprimido',
            'administrationDate': ts('2025-06-15'),
            'nextDueDate': ts('2025-12-15'),
            'petId': 'pet_seed_001',
            'petName': 'Rex',
            'petWeight': 28.5,
            'ownerId': 'tutor_seed_001',
            'ownerName': 'Maria Fernanda Costa',
            'veterinarianId': 'vet_seed_001',
            'veterinarianName': 'Dra. Ana Beatriz Santos',
            'crmvNumber': 'CRMV-SP 67890',
            'clinicId': 'clinic_seed_001',
            'clinicName': 'VetLife Clínica Veterinária',
            'clinicAddress': {
                'street': 'Av. Paulista', 'number': '1500',
                'neighborhood': 'Bela Vista', 'city': 'São Paulo', 'state': 'SP',
            },
            'status': 'active',
            'effectivenessNotes': 'Boa resposta ao tratamento.',
            'sideEffects': [],
            'observations': 'Repetir em 6 meses.',
            'createdAt': ts('2025-06-15'),
            'updatedAt': ts('2025-06-15'),
            'createdBy': 'vet_seed_001',
        },
        'dew_seed_002': {
            'name': 'Drontal Plus',
            'manufacturer': 'Bayer',
            'dosage': '0.5 comprimido',
            'administrationDate': ts('2025-04-10'),
            'nextDueDate': ts('2025-10-10'),
            'petId': 'pet_seed_002',
            'petName': 'Mia',
            'petWeight': 4.1,
            'ownerId': 'tutor_seed_001',
            'ownerName': 'Maria Fernanda Costa',
            'veterinarianId': 'vet_seed_001',
            'veterinarianName': 'Dra. Ana Beatriz Santos',
            'crmvNumber': 'CRMV-SP 67890',
            'clinicId': 'clinic_seed_001',
            'clinicName': 'VetLife Clínica Veterinária',
            'clinicAddress': {
                'street': 'Av. Paulista', 'number': '1500',
                'neighborhood': 'Bela Vista', 'city': 'São Paulo', 'state': 'SP',
            },
            'status': 'completed',
            'effectivenessNotes': 'Tratamento concluído com sucesso.',
            'sideEffects': ['Vômito leve nas primeiras 2 horas'],
            'observations': '',
            'createdAt': ts('2025-04-10'),
            'updatedAt': ts('2025-04-10'),
            'createdBy': 'vet_seed_001',
        },
        'dew_seed_003': {
            'name': 'Panacur',
            'manufacturer': 'Intervet',
            'dosage': '1 comprimido',
            'administrationDate': ts('2024-12-01'),
            'nextDueDate': ts('2025-06-01'),
            'petId': 'pet_seed_003',
            'petName': 'Thor',
            'petWeight': 11.2,
            'ownerId': 'tutor_seed_002',
            'ownerName': 'Roberto Alves Nunes',
            'veterinarianId': 'vet_seed_002',
            'veterinarianName': 'Dr. Carlos Eduardo Lima',
            'crmvNumber': 'CRMV-RJ 11223',
            'clinicId': 'clinic_seed_002',
            'clinicName': 'PetSaúde Centro Clínico',
            'clinicAddress': {
                'street': 'Rua Voluntários da Pátria', 'number': '300',
                'neighborhood': 'Botafogo', 'city': 'Rio de Janeiro', 'state': 'RJ',
            },
            'status': 'expired',
            'effectivenessNotes': '',
            'sideEffects': [],
            'observations': 'Reforço vencido. Reagendar o mais breve possível.',
            'createdAt': ts('2024-12-01'),
            'updatedAt': ts('2024-12-01'),
            'createdBy': 'vet_seed_002',
        },
    },
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description='Seed da plataforma Pets.')
    parser.add_argument('--reset', action='store_true',
                        help='Apaga todos os dados seed antes de reinserir.')
    args = parser.parse_args()

    if args.reset:
        print('\n⚡ Resetando dados de seed...')
        for collection in SEED_COLLECTIONS:
            delete_collection(collection)
        for uid in SEED_UIDS:
            delete_auth_user(uid)

    print('\n👤 Criando usuários no Firebase Auth...')
    for u in AUTH_USERS:
        ensure_auth_user(u['uid'], u['email'], u['password'], u['display_name'])

    print('\n📦 Populando coleções do Firestore...')
    for collection, docs in FIRESTORE_DOCS.items():
        print(f'\n  [{collection}]')
        for doc_id, data in docs.items():
            upsert(collection, doc_id, data)

    print('\n✅ Seed concluído!')
    print('\nCredenciais para testes:')
    print('  vet1@petapp.dev    / Vet@12345    (veterinário — CRMV-SP 67890)')
    print('  vet2@petapp.dev    / Vet@12345    (veterinário — CRMV-RJ 11223)')
    print('  tutor1@petapp.dev  / Tutor@12345  (tutor)')
    print('  tutor2@petapp.dev  / Tutor@12345  (tutor)')


if __name__ == '__main__':
    main()
