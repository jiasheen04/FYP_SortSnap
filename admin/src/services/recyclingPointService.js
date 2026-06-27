import {
  collection,
  getDocs,
  addDoc,
  updateDoc,
  deleteDoc,
  doc,
  serverTimestamp,
} from "firebase/firestore";

import { db } from "../firebase/firebase";
import RecyclingPointModel from "../models/RecyclingPointModel";

const recyclingPointCollection = "recycling_points";

export async function getAllRecyclingPoints() {
  const snapshot = await getDocs(collection(db, recyclingPointCollection));

  const pointList = snapshot.docs.map((docItem) => {
    return new RecyclingPointModel(docItem.id, docItem.data());
  });

  pointList.sort((a, b) => {
    return a.pointCode.localeCompare(b.pointCode);
  });

  return pointList;
}

async function generateNextPointCode() {
  const snapshot = await getDocs(collection(db, recyclingPointCollection));

  const usedNumbers = [];

  snapshot.docs.forEach((docItem) => {
    const data = docItem.data();
    const code = data.pointCode || "";

    const numberOnly = code.replace("RP", "");
    const number = parseInt(numberOnly);

    if (!isNaN(number)) {
      usedNumbers.push(number);
    }
  });

  let nextNumber = 1;

  while (usedNumbers.includes(nextNumber)) {
    nextNumber++;
  }

  return "RP" + String(nextNumber).padStart(2, "0");
}

function cleanPointData(pointData) {
  return {
    pointCode: pointData.pointCode,
    name: pointData.name,
    address: pointData.address,
    latitude: Number(pointData.latitude),
    longitude: Number(pointData.longitude),
    hours: pointData.hours,
    status: pointData.status,
    is_open: pointData.status === "Open",
    contact: pointData.contact,
    area: pointData.area,
    opening_hours: pointData.opening_hours,
    types: pointData.types,
    updatedAt: serverTimestamp(),
  };
}

export async function addRecyclingPoint(pointData) {
  const pointCode = await generateNextPointCode();

  const newPoint = {
    ...cleanPointData({
      ...pointData,
      pointCode: pointCode,
    }),
    createdAt: serverTimestamp(),
  };

  await addDoc(collection(db, recyclingPointCollection), newPoint);
}

export async function updateRecyclingPoint(pointId, pointData) {
  const pointRef = doc(db, recyclingPointCollection, pointId);

  await updateDoc(pointRef, cleanPointData(pointData));
}

export async function deleteRecyclingPoint(pointId) {
  const pointRef = doc(db, recyclingPointCollection, pointId);

  await deleteDoc(pointRef);
}