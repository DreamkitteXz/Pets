const firestoreSchema = {
  users: {
    [userId]: {
      // Basic information for all users
      email: String,
      name: String,
      cpf: String,
      phone: String,
      profileCompleted: Boolean,
      role: ['veterinarian', 'tutor'],
      status: ['active', 'pending', 'suspended'],
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
            // @deprecated (B5) — NÃO é fonte de verdade do vínculo vet↔clínica.
            // A verdade é clinics.veterinarians[] (suporta múltiplas clínicas).
            // Campo removido por migração; não escrever mais.
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

      // Dados clínicos da aplicação (B9)
      route: String,            // via: Subcutânea | Intramuscular | Oral | Intranasal | Tópica | Outra
      applicationSite: String,  // local de aplicação (texto)
      dose: String,             // dose aplicada (vacina). Em deworming usa-se `dosage`.

      // ⚠️ SNAPSHOT (ponto-no-tempo) — NÃO é fonte de verdade do cadastro atual.
      // Os campos pet*/owner*/veterinarian*/clinic* abaixo refletem o estado NO
      // MOMENTO DA APLICAÇÃO e devem permanecer imutáveis (integridade do registro).
      // Para o dado atual do pet/tutor/clínica, consulte as coleções respectivas.
      // NÃO "corrija" estes campos para refletir mudanças posteriores.
      // Pet information (snapshot)
      petId: String,
      petName: String,
      petSpecies: String,
      petBreed: String,
      petWeight: Number,

      // Owner information (snapshot)
      ownerId: String,
      ownerName: String,
      ownerContact: String,

      // Veterinarian information (snapshot)
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

      // ── Status: EIXO ÚNICO ──────────────────────────────────────────────
      // status: 'pending' | 'approved' | 'rejected'
      //   'pending'              = aguardando o veterinário (envio externo do tutor)
      //   'approved' | 'rejected' = decisão do veterinário (autoridade do CRMV)
      //
      // DECISÃO FUNDADORA: o veterinário registra a aplicação que ele mesmo fez.
      // Registro nascido no vet entra JÁ com status 'approved' (auto-validado pelo
      // CRMV de quem aplicou), com o bloco vetValidation preenchido — sem etapa extra.
      // A validação de envios externos do tutor é secundária (status 'pending' → vet decide).
      status: ['pending', 'approved', 'rejected'],

      // CONTRATO ÚNICO de validação — formato ANINHADO (validationDetails.vetValidation.*).
      // NÃO usar campos planos (ex.: validationDetails.validatedAt).
      //   vetValidation.status SEMPRE espelha vaccine.status ('approved' | 'rejected').
      //   Escrito pela Cloud Function `updateVaccineStatus` e no cadastro feito pelo vet.
      validationDetails: {
        vetValidation: {
          status: String,            // 'approved' | 'rejected' (espelha vaccine.status)
          validatedAt: Timestamp,
          validatedBy: String,       // uid do veterinário
          validatedByName: String,
          validatedByCrmv: String,
          notes: String,
          rejectionReason: String
        }
        // tutorValidation: REMOVIDO. A confirmação do tutor virou campo de CIÊNCIA
        // (tutorAcknowledged) — nunca um segundo eixo de status. Ver abaixo.
      },

      // Ciência do tutor (substitui o antigo tutorValidation/tutorApproved/tutorRejected).
      // É apenas um aceite de leitura; NÃO interfere no status.
      tutorAcknowledged: Boolean,
      tutorAcknowledgedAt: Timestamp, // null enquanto não confirmado

      // Additional information
      labelImage: String, // URL to Firebase Storage
      labelImageMetadata: {
        name: String,
        size: Number,
        contentType: String,
        timeCreated: Timestamp,
        updated: Timestamp,
        location: {
          latitude: Number,
          longitude: Number
        }
      },
      notes: String,

      // ── Trilha de auditoria (B4) ─────────────────────────────────────────
      // Convenção para TODOS os registros clínicos (vaccines, deworming, e as
      // subcoleções pets/{id}/consultas e pets/{id}/pesos):
      //   createdBy / updatedBy : uid de quem criou / alterou por último
      //   createdAt / updatedAt : serverTimestamp()
      // Exclusão é lógica: active:false + deletedAt + deletedBy.
      // O bloco validationDetails.vetValidation é IMUTÁVEL após a validação
      // (garantido pelas Firestore rules e pela Cloud Function).
      createdBy: String,
      updatedBy: String,
      active: Boolean,        // ausente = ativo; false = arquivado (soft-delete)
      deletedBy: String,
      deletedAt: Timestamp,
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
      
      // Owner information — FONTE DE VERDADE do vínculo tutor↔pet (B5).
      ownerId: String,
      ownerName: String,

      // @deprecated (B5) — array stale, não atualizado ao criar vacina.
      // A verdade do vínculo vacina↔pet é vaccines.petId. Removido por migração.
      vaccines: [], // Array of vaccineIds

      veterinarians: [], // Array of veterinarianIds — verdade do vínculo vet↔pet

      status: 'active' | 'inactive',
      createdAt: Timestamp,
      updatedAt: Timestamp,
      createdBy: String, // veterinarianId

      // @deprecated (B5) — duplica ownerId. Use ownerId. Removido por migração.
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
  },

  deworming: {
    [dewormingId]: {
      // Basic information
      id: String,
      name: String,
      manufacturer: String,
      dosage: String,
      weight: Number,
      administrationDate: Timestamp,
      nextDueDate: Timestamp,
      isReinforcementNeeded: Boolean,
      reinforcementDate: Timestamp,

      // Pet information
      petId: String,
      petName: String,
      petWeight: Number,

      // Owner information
      ownerId: String,
      ownerName: String,

      // Veterinarian information
      veterinarianId: String,
      veterinarianName: String,
      crmvNumber: String,

      // Clinical information
      clinicId: String,
      clinicName: String,
      clinicAddress: {
        street: String,
        number: String,
        neighborhood: String,
        city: String,
        state: String
      },

      // Status — MESMO eixo único da vacina: 'pending' | 'approved' | 'rejected'.
      // (Legado: registros antigos podem ter 'active'/'completed'/'expired'; a UI
      //  tolera ambos via normalizeStatus + mapa de exibição.)
      status: ['pending', 'approved', 'rejected'],
      effectivenessNotes: String,
      sideEffects: [String],
      observations: String,

      // Metadata + auditoria (mesma convenção da vacina: createdBy/updatedBy,
      // active/deletedAt/deletedBy para soft-delete, validationDetails.vetValidation).
      createdAt: Timestamp,
      updatedAt: Timestamp,
      createdBy: String
    }
  },

  // ── Catálogo controlado (B8) ───────────────────────────────────────────────
  // Vocabulário canônico para padronizar nome/fabricante e pré-preencher a próxima
  // dose (administrationDate + reforcoDias). Leitura por autenticados; escrita só
  // via Admin SDK (seed). Seed: scripts/migrations/seedCatalog.js
  vaccineCatalog: {
    [itemId]: {
      name: String,            // nome canônico (ex.: 'V10 Polivalente')
      manufacturer: String,
      species: [String],       // espécies-alvo (ex.: ['Cachorro']) ou ['all']
      reforcoDias: Number      // intervalo padrão de reforço, em dias
    }
  },
  dewormerCatalog: {
    [itemId]: {
      name: String,
      manufacturer: String,
      species: [String],
      reforcoDias: Number
    }
  }
};
