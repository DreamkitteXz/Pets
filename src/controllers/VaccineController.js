import { vaccineService } from '../services/firebase/vaccineService';
import { notificationService } from '../services/firebase/notificationService';

export class VaccineController {
  async createVaccineRecord(vaccineData) {
    try {
      // Format the data according to the new schema
      const formattedData = {
        petId: vaccineData.petId,
        ownerId: vaccineData.ownerId,
        name: vaccineData.vacina,
        manufacturer: vaccineData.farmaceutica,
        batchNumber: vaccineData.lote,
        expirationDate: new Date(vaccineData.dataValidade),
        administrationDate: new Date(vaccineData.dataAplicacao),
        nextDueDate: new Date(vaccineData.proximaAplicacao),
        petWeight: parseFloat(vaccineData.pesoAplicacao),
        clinic: {
          name: vaccineData.clinica,
          cnpj: vaccineData.cnpj,
          address: {
            street: vaccineData.rua,
            neighborhood: vaccineData.bairro,
            number: vaccineData.numero,
            city: vaccineData.cidade
          }
        },
        veterinarian: {
          name: vaccineData.nomeVet,
          crmv: vaccineData.crmv
        },
        labelImage: vaccineData.imagemRotulo,
        notes: vaccineData.observacoes
      };

      // Create vaccine record
      const vaccineId = await vaccineService.createVaccine(formattedData);
      
      return vaccineId;
    } catch (error) {
      throw new Error('Error creating vaccine record: ' + error.message);
    }
  }

  async validateVaccine(vaccineId, validationData, validatorId) {
    try {
      await vaccineService.validateVaccine(vaccineId, validationData, validatorId);
      
      // Get vaccine details to get owner ID
      const vaccineDoc = await getDoc(doc(db, 'vaccines', vaccineId));
      const vaccineData = vaccineDoc.data();
      
      // Send notification to owner
      await notificationService.sendVaccineValidationNotification(
        vaccineData.ownerId,
        vaccineId,
        validationData.status
      );
    } catch (error) {
      throw new Error('Error validating vaccine: ' + error.message);
    }
  }
}
