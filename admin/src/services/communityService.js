import {
    collection,
    getDocs,
    setDoc,
    updateDoc,
    deleteDoc,
    doc,
    query,
    where,
    serverTimestamp,
} from "firebase/firestore";

import { db, auth } from "../firebase/firebase";

const flashcardSetCollection = "flashcard_sets";
const flashcardCollection = "flashcards";
const quizCollection = "quizzes";
const quizQuestionCollection = "quiz_questions";
const quizOptionCollection = "quiz_options";
const articleCollection = "articles";

function getAdminId() {
    if (auth.currentUser && auth.currentUser.uid) {
        return auth.currentUser.uid;
    }

    return "admin";
}

function cleanLevel(level) {
    return String(level || "Beginner").toLowerCase();
}

function displayLevel(level) {
    const clean = cleanLevel(level);

    if (clean === "beginner") return "Beginner";
    if (clean === "intermediate") return "Intermediate";
    if (clean === "advanced") return "Advanced";

    return "Beginner";
}

function getDifficultyOrder(level) {
    const clean = cleanLevel(level);

    if (clean === "beginner") return 1;
    if (clean === "intermediate") return 2;
    if (clean === "advanced") return 3;

    return 999;
}

function sortByOrderThenTitle(a, b) {
    const orderA = a.difficultyOrder || a.articleOrder || 999;
    const orderB = b.difficultyOrder || b.articleOrder || 999;

    if (orderA !== orderB) {
        return orderA - orderB;
    }

    return (a.title || "").localeCompare(b.title || "");
}

function makeSlug(text, fallback) {
    const slug = String(text || fallback)
        .toLowerCase()
        .trim()
        .replace(/&/g, "and")
        .replace(/[^a-z0-9]+/g, "_")
        .replace(/^_+|_+$/g, "");

    return slug || fallback;
}

function getFlashcardPrefix(level) {
    const clean = cleanLevel(level);

    if (clean === "beginner") return "BF";
    if (clean === "intermediate") return "IF";
    if (clean === "advanced") return "AF";

    return "BF";
}

function getNumberFromSetId(setId) {
    const match = String(setId || "").match(/_set_(\d+)$/);

    if (!match) return 1;

    const number = parseInt(match[1]);
    return isNaN(number) ? 1 : number;
}

function makeFlashcardId(level, setId, order) {
    const prefix = getFlashcardPrefix(level);
    const setNumber = getNumberFromSetId(setId);
    const cardNumber = String(order).padStart(2, "0");

    return prefix + setNumber + cardNumber;
}

function getQuestionNumber(questionId) {
    const match = String(questionId || "").match(/^Q(\d+)$/i);

    if (!match) return 0;

    const number = parseInt(match[1]);
    return isNaN(number) ? 0 : number;
}

function makeQuestionId(number) {
    return "Q" + String(number).padStart(3, "0");
}

async function generateFlashcardSetId(level, title) {
    const snapshot = await getDocs(collection(db, flashcardSetCollection));
    const existingIds = snapshot.docs.map((docItem) => docItem.id);
    const titleSlug = makeSlug(title, "flashcard");

    let biggestNumber = 0;

    snapshot.docs.forEach((docItem) => {
        const data = docItem.data();

        if (cleanLevel(data.level) === level) {
            const number = getNumberFromSetId(docItem.id);

            if (number > biggestNumber) {
                biggestNumber = number;
            }
        }
    });

    let nextNumber = biggestNumber + 1;
    let newId = titleSlug + "_set_" + nextNumber;

    while (existingIds.includes(newId)) {
        nextNumber = nextNumber + 1;
        newId = titleSlug + "_set_" + nextNumber;
    }

    return newId;
}

async function generateQuizId(title) {
    const snapshot = await getDocs(collection(db, quizCollection));
    const existingIds = snapshot.docs.map((docItem) => docItem.id);
    const titleSlug = makeSlug(title, "quiz");

    let baseId = titleSlug.endsWith("_quiz") ? titleSlug : titleSlug + "_quiz";

    if (!existingIds.includes(baseId)) {
        return baseId;
    }

    let number = 2;
    let newId = baseId + "_" + number;

    while (existingIds.includes(newId)) {
        number = number + 1;
        newId = baseId + "_" + number;
    }

    return newId;
}

async function generateNextQuestionNumber() {
    const snapshot = await getDocs(collection(db, quizQuestionCollection));

    let biggestNumber = 0;

    snapshot.docs.forEach((docItem) => {
        const number = getQuestionNumber(docItem.id);

        if (number > biggestNumber) {
            biggestNumber = number;
        }
    });

    return biggestNumber + 1;
}

async function generateArticleId() {
    const snapshot = await getDocs(collection(db, articleCollection));
    const existingIds = snapshot.docs.map((docItem) => docItem.id);

    let biggestNumber = 0;

    existingIds.forEach((articleId) => {
        const match = String(articleId).match(/^article_(\d+)$/i);

        if (match) {
            const number = parseInt(match[1]);

            if (!isNaN(number) && number > biggestNumber) {
                biggestNumber = number;
            }
        }
    });

    let nextNumber = biggestNumber + 1;
    let newId = "article_" + nextNumber;

    while (existingIds.includes(newId)) {
        nextNumber = nextNumber + 1;
        newId = "article_" + nextNumber;
    }

    return newId;
}

// =========================
// Read data for admin lists
// =========================

export async function getAllFlashcardSets() {
    const snapshot = await getDocs(collection(db, flashcardSetCollection));

    const sets = snapshot.docs.map((docItem) => {
        return {
            id: docItem.id,
            ...docItem.data(),
        };
    });

    sets.sort(sortByOrderThenTitle);
    return sets;
}

export async function getAllQuizzes() {
    const snapshot = await getDocs(collection(db, quizCollection));

    const quizzes = snapshot.docs.map((docItem) => {
        return {
            id: docItem.id,
            ...docItem.data(),
        };
    });

    quizzes.sort(sortByOrderThenTitle);
    return quizzes;
}

export async function getAllArticles() {
    const snapshot = await getDocs(collection(db, articleCollection));

    const articles = snapshot.docs.map((docItem) => {
        return {
            id: docItem.id,
            ...docItem.data(),
        };
    });

    articles.sort(sortByOrderThenTitle);
    return articles;
}

export async function getCommunityAdminData() {
    const flashcardSets = await getAllFlashcardSets();
    const quizzes = await getAllQuizzes();
    const articles = await getAllArticles();

    return {
        flashcardSets,
        quizzes,
        articles,
    };
}

// =========================
// Flashcards
// =========================

export async function getFlashcardsBySetId(setId) {
    const cardQuery = query(
        collection(db, flashcardCollection),
        where("setId", "==", setId)
    );

    const snapshot = await getDocs(cardQuery);

    const cards = snapshot.docs.map((docItem) => {
        return {
            id: docItem.id,
            ...docItem.data(),
        };
    });

    cards.sort((a, b) => {
        return (a.cardOrder || 999) - (b.cardOrder || 999);
    });

    return cards;
}

function cleanFlashcards(cards) {
    return cards.filter((card) => {
        return card.frontText.trim() !== "" && card.backExplanation.trim() !== "";
    });
}

async function addCardsToSet(setId, level, cards) {
    const validCards = cleanFlashcards(cards);

    for (let i = 0; i < validCards.length; i++) {
        const card = validCards[i];
        const cardId = card.id || makeFlashcardId(level, setId, i + 1);

        await setDoc(doc(db, flashcardCollection, cardId), {
            setId: setId,
            level: level,
            cardOrder: i + 1,
            frontText: card.frontText.trim(),
            backExplanation: card.backExplanation.trim(),
            imagePath: card.imagePath.trim(),
            category: card.category.trim(),
            sourceNote: card.sourceNote.trim(),
            isActive: true,
            createdAt: serverTimestamp(),
            updatedAt: serverTimestamp(),
        });
    }

    return validCards.length;
}

async function deleteCardsBySetId(setId) {
    const cardQuery = query(
        collection(db, flashcardCollection),
        where("setId", "==", setId)
    );

    const cardSnapshot = await getDocs(cardQuery);

    for (const cardDoc of cardSnapshot.docs) {
        await deleteDoc(doc(db, flashcardCollection, cardDoc.id));
    }
}

export async function addFlashcardSet(formData) {
    const level = cleanLevel(formData.level);
    const validCards = cleanFlashcards(formData.cards);
    const setId = await generateFlashcardSetId(level, formData.title);

    await setDoc(doc(db, flashcardSetCollection, setId), {
        title: formData.title.trim(),
        description: formData.description.trim(),
        level: level,
        difficultyOrder: getDifficultyOrder(level),
        totalCards: validCards.length,
        isActive: formData.isActive === false ? false : true,
        createdByAdminId: getAdminId(),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
    });

    await addCardsToSet(setId, level, validCards);
}

export async function updateFlashcardSet(setId, formData) {
    const level = cleanLevel(formData.level);
    const validCards = cleanFlashcards(formData.cards);

    await updateDoc(doc(db, flashcardSetCollection, setId), {
        title: formData.title.trim(),
        description: formData.description.trim(),
        level: level,
        difficultyOrder: getDifficultyOrder(level),
        totalCards: validCards.length,
        isActive: formData.isActive === false ? false : true,
        updatedAt: serverTimestamp(),
    });

    await deleteCardsBySetId(setId);
    await addCardsToSet(setId, level, validCards);
}

export async function deleteFlashcardSet(setId) {
    await deleteCardsBySetId(setId);
    await deleteDoc(doc(db, flashcardSetCollection, setId));
}

export function buildFlashcardFormFromData(setData, cards) {
    return {
        title: setData.title || "",
        level: displayLevel(setData.level),
        description: setData.description || "",
        isActive: setData.isActive === false ? false : true,
        cards:
            cards.length === 0
                ? [
                    {
                        frontText: "",
                        backExplanation: "",
                        imagePath: "",
                        category: "",
                        sourceNote: "",
                    },
                ]
                : cards.map((card) => ({
                    id: card.id || "",
                    frontText: card.frontText || "",
                    backExplanation: card.backExplanation || "",
                    imagePath: card.imagePath || "",
                    category: card.category || "",
                    sourceNote: card.sourceNote || "",
                })),
    };
}

// =========================
// Quizzes
// =========================

export async function getQuestionsByQuizId(quizId) {
    const questionQuery = query(
        collection(db, quizQuestionCollection),
        where("quizId", "==", quizId)
    );

    const questionSnapshot = await getDocs(questionQuery);

    const questions = [];

    for (const questionDoc of questionSnapshot.docs) {
        const questionData = questionDoc.data();

        const optionQuery = query(
            collection(db, quizOptionCollection),
            where("questionId", "==", questionDoc.id)
        );

        const optionSnapshot = await getDocs(optionQuery);

        const options = optionSnapshot.docs.map((optionDoc) => {
            return {
                id: optionDoc.id,
                ...optionDoc.data(),
            };
        });

        options.sort((a, b) => {
            return (a.optionOrder || 999) - (b.optionOrder || 999);
        });

        questions.push({
            id: questionDoc.id,
            ...questionData,
            options: options,
        });
    }

    questions.sort((a, b) => {
        return (a.questionOrder || 999) - (b.questionOrder || 999);
    });

    return questions;
}

function cleanQuestions(questions) {
    return questions.filter((question) => {
        return (
            question.questionText.trim() !== "" &&
            question.optionA.trim() !== "" &&
            question.optionB.trim() !== "" &&
            question.optionC.trim() !== "" &&
            question.optionD.trim() !== ""
        );
    });
}

async function addQuestionsToQuiz(quizId, questions) {
    const validQuestions = cleanQuestions(questions);
    let nextQuestionNumber = await generateNextQuestionNumber();

    validQuestions.forEach((question) => {
        const existingNumber = getQuestionNumber(question.id);

        if (existingNumber >= nextQuestionNumber) {
            nextQuestionNumber = existingNumber + 1;
        }
    });

    for (let i = 0; i < validQuestions.length; i++) {
        const question = validQuestions[i];
        let questionId = question.id || "";

        if (questionId.trim() === "") {
            questionId = makeQuestionId(nextQuestionNumber);
            nextQuestionNumber = nextQuestionNumber + 1;
        }

        await setDoc(doc(db, quizQuestionCollection, questionId), {
            quizId: quizId,
            questionText: question.questionText.trim(),
            questionType: question.imagePath.trim() === "" ? "text" : "image",
            imagePath: question.imagePath.trim(),
            explanation: question.explanation.trim(),
            sourceTitle: question.sourceTitle.trim(),
            sourceUrl: question.sourceUrl.trim(),
            sourceNote: question.sourceNote.trim(),
            questionOrder: i + 1,
            isActive: true,
            createdByAdminId: getAdminId(),
            createdAt: serverTimestamp(),
            updatedAt: serverTimestamp(),
        });

        const optionList = [
            { label: "A", text: question.optionA.trim(), order: 1 },
            { label: "B", text: question.optionB.trim(), order: 2 },
            { label: "C", text: question.optionC.trim(), order: 3 },
            { label: "D", text: question.optionD.trim(), order: 4 },
        ];

        for (const option of optionList) {
            const optionId = questionId + "_" + option.order;

            await setDoc(doc(db, quizOptionCollection, optionId), {
                questionId: questionId,
                optionText: option.text,
                isCorrect: question.correctAnswer === option.label,
                optionOrder: option.order,
                createdByAdminId: getAdminId(),
                createdAt: serverTimestamp(),
                updatedAt: serverTimestamp(),
            });
        }
    }

    return validQuestions.length;
}

async function deleteQuestionsByQuizId(quizId) {
    const questionQuery = query(
        collection(db, quizQuestionCollection),
        where("quizId", "==", quizId)
    );

    const questionSnapshot = await getDocs(questionQuery);

    for (const questionDoc of questionSnapshot.docs) {
        const optionQuery = query(
            collection(db, quizOptionCollection),
            where("questionId", "==", questionDoc.id)
        );

        const optionSnapshot = await getDocs(optionQuery);

        for (const optionDoc of optionSnapshot.docs) {
            await deleteDoc(doc(db, quizOptionCollection, optionDoc.id));
        }

        await deleteDoc(doc(db, quizQuestionCollection, questionDoc.id));
    }
}

export async function addQuiz(formData) {
    const level = cleanLevel(formData.level);
    const validQuestions = cleanQuestions(formData.questions);
    const quizId = await generateQuizId(formData.title);

    await setDoc(doc(db, quizCollection, quizId), {
        title: formData.title.trim(),
        description: formData.description.trim(),
        level: level,
        difficultyOrder: getDifficultyOrder(level),
        totalQuestions: validQuestions.length,
        isActive: formData.isActive === false ? false : true,
        createdByAdminId: getAdminId(),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
    });

    await addQuestionsToQuiz(quizId, validQuestions);
}

export async function updateQuiz(quizId, formData) {
    const level = cleanLevel(formData.level);
    const validQuestions = cleanQuestions(formData.questions);

    await updateDoc(doc(db, quizCollection, quizId), {
        title: formData.title.trim(),
        description: formData.description.trim(),
        level: level,
        difficultyOrder: getDifficultyOrder(level),
        totalQuestions: validQuestions.length,
        isActive: formData.isActive === false ? false : true,
        updatedAt: serverTimestamp(),
    });

    await deleteQuestionsByQuizId(quizId);
    await addQuestionsToQuiz(quizId, validQuestions);
}

export async function deleteQuiz(quizId) {
    await deleteQuestionsByQuizId(quizId);
    await deleteDoc(doc(db, quizCollection, quizId));
}

export function buildQuizFormFromData(quizData, questions) {
    return {
        title: quizData.title || "",
        level: displayLevel(quizData.level),
        description: quizData.description || "",
        isActive: quizData.isActive === false ? false : true,
        questions:
            questions.length === 0
                ? [
                    {
                        questionText: "",
                        imagePath: "",
                        optionA: "",
                        optionB: "",
                        optionC: "",
                        optionD: "",
                        correctAnswer: "A",
                        explanation: "",
                        sourceTitle: "",
                        sourceUrl: "",
                        sourceNote: "",
                    },
                ]
                : questions.map((question) => {
                    const optionA = question.options[0] || {};
                    const optionB = question.options[1] || {};
                    const optionC = question.options[2] || {};
                    const optionD = question.options[3] || {};

                    let correctAnswer = "A";
                    if (optionB.isCorrect === true) correctAnswer = "B";
                    if (optionC.isCorrect === true) correctAnswer = "C";
                    if (optionD.isCorrect === true) correctAnswer = "D";

                    return {
                        id: question.id || "",
                        questionText: question.questionText || "",
                        imagePath: question.imagePath || "",
                        optionA: optionA.optionText || "",
                        optionB: optionB.optionText || "",
                        optionC: optionC.optionText || "",
                        optionD: optionD.optionText || "",
                        correctAnswer: correctAnswer,
                        explanation: question.explanation || "",
                        sourceTitle: question.sourceTitle || "",
                        sourceUrl: question.sourceUrl || "",
                        sourceNote: question.sourceNote || "",
                    };
                }),
    };
}

// =========================
// Articles
// =========================

export async function addArticle(formData) {
    const currentArticles = await getAllArticles();
    const articleId = await generateArticleId();

    await setDoc(doc(db, articleCollection, articleId), {
        title: formData.title.trim(),
        summary: formData.summary.trim(),
        content: formData.content.trim(),
        category: formData.category.trim(),
        sourceName: formData.sourceName.trim(),
        sourceUrl: formData.sourceUrl.trim(),
        imagePath: formData.imagePath.trim(),
        articleOrder: Number(formData.articleOrder || currentArticles.length + 1),
        isActive: formData.isActive === false ? false : true,
        createdByAdminId: getAdminId(),
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
    });
}

export async function updateArticle(articleId, formData) {
    await updateDoc(doc(db, articleCollection, articleId), {
        title: formData.title.trim(),
        summary: formData.summary.trim(),
        content: formData.content.trim(),
        category: formData.category.trim(),
        sourceName: formData.sourceName.trim(),
        sourceUrl: formData.sourceUrl.trim(),
        imagePath: formData.imagePath.trim(),
        articleOrder: Number(formData.articleOrder || 1),
        isActive: formData.isActive === false ? false : true,
        updatedAt: serverTimestamp(),
    });
}

export async function deleteArticle(articleId) {
    await deleteDoc(doc(db, articleCollection, articleId));
}
