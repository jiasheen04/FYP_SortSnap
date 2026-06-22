import {
  collection,
  query,
  orderBy,
  onSnapshot,
  addDoc,
  doc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
} from "firebase/firestore";

import { db } from "../firebase/firebase";

export function listenFeedback(callback) {
  const feedbackQuery = query(
    collection(db, "feedback"),
    orderBy("createdAt", "desc")
  );

  return onSnapshot(feedbackQuery, (snapshot) => {
    const feedbackList = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    callback(feedbackList);
  });
}

export function listenFaqs(callback) {
  const faqQuery = query(collection(db, "faqs"), orderBy("order", "asc"));

  return onSnapshot(faqQuery, (snapshot) => {
    const faqList = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    callback(faqList);
  });
}

export async function updateFeedbackReply(feedbackId, reply, status) {
  await updateDoc(doc(db, "feedback", feedbackId), {
    adminReply: reply,
    status: status,
    updatedAt: serverTimestamp(),
  });
}

export async function updateFeedbackStatus(feedbackId, status) {
  await updateDoc(doc(db, "feedback", feedbackId), {
    status: status,
    updatedAt: serverTimestamp(),
  });
}

export async function createFaq(faqData) {
  await addDoc(collection(db, "faqs"), {
    question: faqData.question,
    answer: faqData.answer,
    category: faqData.category,
    order: Number(faqData.order),
    isActive: faqData.isActive,
    createdByAdminId: "admin",
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
}

export async function updateFaq(faqId, faqData) {
  await updateDoc(doc(db, "faqs", faqId), {
    question: faqData.question,
    answer: faqData.answer,
    category: faqData.category,
    order: Number(faqData.order),
    isActive: faqData.isActive,
    updatedAt: serverTimestamp(),
  });
}

export async function deleteFaq(faqId) {
  await deleteDoc(doc(db, "faqs", faqId));
}