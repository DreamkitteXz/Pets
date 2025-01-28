import { collection, getDocs } from "firebase/firestore";
import { db } from "../config/firebase";

const vetCrmv = "asdf";

//import { auth } from "../../../config/firebase"; 
// import { onAuthStateChanged } from "firebase/auth";

// // Initialize a variable to store the user UUID
// let userUUID = null;

// // Listen for authentication state changes
// onAuthStateChanged(auth, (user) => {
//   if (user) {
//     // User is signed in, store the UUID
//     userUUID = user.uid;
//     console.log("User UUID: ", userUUID);
//   } else {
//     // No user is signed in, clear the UUID
//     userUUID = null;
//     console.log("No user signed in");
//   }
// });

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
