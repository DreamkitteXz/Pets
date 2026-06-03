import { httpsCallable } from 'firebase/functions';
import { functions } from '../config/firebase';
import { vaccineService } from '../services/firebase/vaccineService';

const createVaccineRecordFn = httpsCallable(functions, 'createVaccineRecord', { timeout: 20000 });

export class VaccineController {
  async createVaccineRecord(vaccineData, labelImage) {
    try {
      // Upload image first (client-side Storage write) to get URL, then send
      // data to Cloud Function for server-side CPF/CRMV validation and Firestore write.
      let imageUrl = null;
      if (labelImage) {
        // EXIF stripping + upload is handled inside vaccineService.uploadLabelImage
        imageUrl = await vaccineService.uploadLabelImage(labelImage);
      }

      const formattedData = {
        petId:              vaccineData.petId,
        ownerId:            vaccineData.ownerId,
        name:               vaccineData.vacina,
        manufacturer:       vaccineData.farmaceutica,
        batchNumber:        vaccineData.lote,
        expirationDate:     vaccineData.dataValidade,
        administrationDate: vaccineData.dataAplicacao,
        nextDueDate:        vaccineData.proximaAplicacao,
        petWeight:          parseFloat(vaccineData.pesoAplicacao),
        cpf:                vaccineData.cpf       || '',
        crmv:               vaccineData.crmv      || '',
        clinic: {
          name:    vaccineData.clinica,
          cnpj:    vaccineData.cnpj,
          address: {
            street:       vaccineData.rua,
            neighborhood: vaccineData.bairro,
            number:       vaccineData.numero,
            city:         vaccineData.cidade,
          },
        },
        veterinarian: {
          name: vaccineData.nomeVet,
          crmv: vaccineData.crmv,
        },
        labelImage: imageUrl,
        notes:      vaccineData.observacoes || '',
      };

      const { data } = await createVaccineRecordFn({ vaccineData: formattedData });
      return data.id;
    } catch (error) {
      throw new Error('Erro ao criar registro de vacina: ' + (error.message || error));
    }
  }
}
