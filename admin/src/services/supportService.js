import {
  collection,
  query,
  orderBy,
  onSnapshot,
  addDoc,
  doc,
  updateDoc,
  deleteDoc,
  getDocs,
  writeBatch,
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
  const faqRef = collection(db, "faqs");
  const snapshot = await getDocs(faqRef);
  const batch = writeBatch(db);

  let newOrder = Number(faqData.order);

  if (!newOrder || newOrder < 1) {
    newOrder = 1;
  }

  snapshot.docs.forEach((docItem) => {
    const data = docItem.data();
    const currentOrder = Number(data.order);

    if (currentOrder >= newOrder) {
      batch.update(doc(db, "faqs", docItem.id), {
        order: currentOrder + 1,
        updatedAt: serverTimestamp(),
      });
    }
  });

  const newFaqRef = doc(collection(db, "faqs"));

  batch.set(newFaqRef, {
    question: faqData.question,
    answer: faqData.answer,
    category: faqData.category,
    order: newOrder,
    isActive: faqData.isActive,
    createdByAdminId: "admin",
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  await batch.commit();
}

export async function updateFaq(faqId, faqData) {
  const faqRef = collection(db, "faqs");
  const snapshot = await getDocs(faqRef);
  const batch = writeBatch(db);

  let newOrder = Number(faqData.order);

  if (!newOrder || newOrder < 1) {
    newOrder = 1;
  }

  const currentFaq = snapshot.docs.find((docItem) => {
    return docItem.id === faqId;
  });

  let oldOrder = newOrder;

  if (currentFaq) {
    oldOrder = Number(currentFaq.data().order);
  }

  snapshot.docs.forEach((docItem) => {
    if (docItem.id === faqId) {
      return;
    }

    const data = docItem.data();
    const currentOrder = Number(data.order);

    if (newOrder < oldOrder) {
      if (currentOrder >= newOrder && currentOrder < oldOrder) {
        batch.update(doc(db, "faqs", docItem.id), {
          order: currentOrder + 1,
          updatedAt: serverTimestamp(),
        });
      }
    }

    if (newOrder > oldOrder) {
      if (currentOrder <= newOrder && currentOrder > oldOrder) {
        batch.update(doc(db, "faqs", docItem.id), {
          order: currentOrder - 1,
          updatedAt: serverTimestamp(),
        });
      }
    }
  });

  batch.update(doc(db, "faqs", faqId), {
    question: faqData.question,
    answer: faqData.answer,
    category: faqData.category,
    order: newOrder,
    isActive: faqData.isActive,
    updatedAt: serverTimestamp(),
  });

  await batch.commit();
}

export async function deleteFaq(faqId) {
  const faqRef = collection(db, "faqs");
  const snapshot = await getDocs(faqRef);
  const batch = writeBatch(db);

  const deletedFaq = snapshot.docs.find((docItem) => {
    return docItem.id === faqId;
  });

  if (!deletedFaq) {
    return;
  }

  const deletedOrder = Number(deletedFaq.data().order);

  snapshot.docs.forEach((docItem) => {
    if (docItem.id === faqId) {
      return;
    }

    const data = docItem.data();
    const currentOrder = Number(data.order);

    if (currentOrder > deletedOrder) {
      batch.update(doc(db, "faqs", docItem.id), {
        order: currentOrder - 1,
        updatedAt: serverTimestamp(),
      });
    }
  });

  batch.delete(doc(db, "faqs", faqId));

  await batch.commit();
}