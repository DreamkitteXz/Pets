import { collection, getDocs } from "firebase/firestore";
import { db } from "../config/firebase";

const vetCrmv = "asdf";

export async function readData() {
  const vacList = [];
  try {
    const querySnapshot = await getDocs(collection(db, "Vacinas_Pendentes"));
    querySnapshot.forEach((doc) => {
      if (doc.get("crmv") == vetCrmv) {
        vacList.push({ id: doc.id, ...doc.data() });
      }
    });
  } catch (error) {
    console.error("Error fetching documents: ", error);
  }
  return vacList;
}
