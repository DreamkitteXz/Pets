const firestoreSchema = {
  users: {
    [userId]: {
      // Basic information for all users
      email: String,
      name: String,
      cpf: String,
      phone: String,
      profileCompleted: Boolean,
      role: 'veterinarian' | 'tutor',
      status: 'active' | 'pending' | 'suspended',
      createdAt: Timestamp,
      updatedAt: Timestamp,

      // Shared address information
      address: {
        street: String,
        number: String,
        complement: String,
        neighborhood: String,
        city: String,
        state: String,
        zipCode: String
      },

      // Veterinarian specific information
      ...(function(role) {
        if (role === 'veterinarian') {
          return {
            crmv: String,
            specialties: [String],
            yearsOfExperience: Number,
            clinicId: String
          };
        }
        return {};
      })(this.role),

      // Tutor specific information
      ...(function(role) {
        if (role === 'tutor') {
          return {
            pets: [String], // Array of petIds
            preferredVetId: String, // Reference to preferred veterinarian
            emergencyContact: {
              name: String,
              phone: String,
              relationship: String
            }
          };
        }
        return {};
      })(this.role)
    }
  },

  vaccines: {
    [vaccineId]: {
      // Basic vaccine information
      name: String,
      manufacturer: String,
      batchNumber: String,
      expirationDate: Timestamp,
      administrationDate: Timestamp,
      nextDueDate: Timestamp,

      // Pet information
      petId: String,
      petName: String,
      petSpecies: String,
      petBreed: String,
      petWeight: Number,

      // Owner information
      ownerId: String,
      ownerName: String,
      ownerContact: String,

      // Veterinarian information
      veterinarianId: String,
      veterinarianName: String,
      crmvNumber: String,
      clinicName: String,
      clinicCnpj: String,

      // Clinic address
      clinicAddress: {
        street: String,
        number: String,
        neighborhood: String,
        city: String,
        state: String
      },

      // Validation status
      status: 'pending' | 'approved' | 'rejected',
      validationDetails: {
        validatedAt: Timestamp,
        validatedBy: String, // validating vet's userId
        notes: String,
        rejectionReason: String
      },

      // Additional information
      labelImage: String, // URL to Firebase Storage
      notes: String,
      createdAt: Timestamp,
      updatedAt: Timestamp
    }
  },

  pets: {
    [petId]: {
      name: String,
      species: String,
      breed: String,
      birthDate: Timestamp,
      color: String,
      gender: String,
      weight: Number,
      isNeutered: Boolean,
      chipNumber: String,
      
      // Owner information
      ownerId: String,
      ownerName: String,
      
      // Vaccination history
      vaccines: [], // Array of vaccineIds

      veterinarians: [], // Array of vaccineIds

      status: 'active' | 'inactive',
      createdAt: Timestamp,
      updatedAt: Timestamp,
      createdBy: String, // veterinarianId

      // Enhanced owner information
      tutorId: String, // Reference to users collection
      emergencyContacts: [{
        name: String,
        phone: String,
        relationship: String
      }],
      
      // Medical history
      medicalNotes: String,
      allergies: Array,
      chronicConditions: String
    }
  },

  clinics: {
    [clinicId]: {
      name: String,
      cnpj: String,
      phone: String,
      email: String,
      
      address: {
        street: String,
        number: String,
        complement: String,
        neighborhood: String,
        city: String,
        state: String,
        zipCode: String
      },
      
      veterinarians: Array, // Array of veterinarianIds
      status: 'active' | 'inactive',
      createdAt: Timestamp,
      updatedAt: Timestamp
    }
  },

  appointments: {
    [appointmentId]: {
      petId: String,
      tutorId: String,
      veterinarianId: String,
      clinicId: String,
      date: Timestamp,
      type: 'checkup' | 'vaccination' | 'emergency' | 'surgery',
      status: 'scheduled' | 'completed' | 'cancelled',
      notes: String,
      createdAt: Timestamp,
      updatedAt: Timestamp
    }
  }
};
