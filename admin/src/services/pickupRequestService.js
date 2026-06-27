import {
  collection,
  getDocs,
  doc,
  getDoc,
  updateDoc,
  serverTimestamp,
} from "firebase/firestore";

import { db, auth } from "../firebase/firebase";
import PickupRequestModel from "../models/PickupRequestModel";

const pickupCollection = "pickup_requests";

export async function getAllPickupRequests() {
  const snapshot = await getDocs(collection(db, pickupCollection));

  const requestList = snapshot.docs.map((docItem) => {
    return new PickupRequestModel(docItem.id, docItem.data());
  });

  requestList.sort((a, b) => {
    const aDate = a.createdAt ? a.createdAt.toDate() : new Date(2000, 0, 1);
    const bDate = b.createdAt ? b.createdAt.toDate() : new Date(2000, 0, 1);
    return bDate - aDate;
  });

  return requestList;
}

async function getCurrentAdminInfo() {
  const currentUser = auth.currentUser;

  if (!currentUser) {
    throw new Error("No admin is logged in.");
  }

  const adminRef = doc(db, "users", currentUser.uid);
  const adminSnap = await getDoc(adminRef);

  let adminData = {};

  if (adminSnap.exists()) {
    adminData = adminSnap.data();
  }

  return {
    adminId: currentUser.uid,
    adminUsername: adminData.username || "",
    adminUserNo: adminData.userNo || "",
  };
}

export async function updatePickupStatus(pickupId, newStatus) {
  const admin = await getCurrentAdminInfo();
  const pickupRef = doc(db, pickupCollection, pickupId);

  const updateData = {
    status: newStatus,
    updatedAt: serverTimestamp(),
    updatedByAdminId: admin.adminId,
    updatedByAdminUsername: admin.adminUsername,
    updatedByAdminUserNo: admin.adminUserNo,
  };

  if (newStatus === "Completed") {
    updateData.completedAt = serverTimestamp();
    updateData.completedByAdminId = admin.adminId;
    updateData.completedByAdminUsername = admin.adminUsername;
    updateData.completedByAdminUserNo = admin.adminUserNo;
  }

  await updateDoc(pickupRef, updateData);
}

export async function forwardPickupRequest(
  pickupId,
  recyclingPointId,
  recyclingPointName
) {
  const admin = await getCurrentAdminInfo();
  const pickupRef = doc(db, pickupCollection, pickupId);

  await updateDoc(pickupRef, {
    status: "Forwarded",
    forwardedToPointId: recyclingPointId,
    forwardedToPointName: recyclingPointName,
    forwardedAt: serverTimestamp(),
    forwardedByAdminId: admin.adminId,
    forwardedByAdminUsername: admin.adminUsername,
    forwardedByAdminUserNo: admin.adminUserNo,
    updatedAt: serverTimestamp(),
    updatedByAdminId: admin.adminId,
    updatedByAdminUsername: admin.adminUsername,
    updatedByAdminUserNo: admin.adminUserNo,
  });
}