import { useEffect, useState } from "react";
import {
  getCommunityAdminData,
  getFlashcardsBySetId,
  buildFlashcardFormFromData,
  addFlashcardSet,
  updateFlashcardSet,
  deleteFlashcardSet,
  getQuestionsByQuizId,
  buildQuizFormFromData,
  addQuiz,
  updateQuiz,
  deleteQuiz,
  addArticle,
  updateArticle,
  deleteArticle,
} from "../services/communityService";

const emptyFlashcard = {
  frontText: "",
  backExplanation: "",
  imagePath: "",
  category: "",
  sourceNote: "",
};

const emptyQuestion = {
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
};

const emptyFlashcardForm = {
  title: "",
  level: "Beginner",
  description: "",
  isActive: true,
  cards: [{ ...emptyFlashcard }],
};

const emptyQuizForm = {
  title: "",
  level: "Beginner",
  description: "",
  isActive: true,
  questions: [{ ...emptyQuestion }],
};

const emptyArticleForm = {
  title: "",
  summary: "",
  category: "",
  sourceName: "",
  sourceUrl: "",
  imagePath: "",
  content: "",
  articleOrder: 1,
  isActive: true,
};

function CommunityPage() {
  const [activeTab, setActiveTab] = useState("flashcards");
  const [flashcardSets, setFlashcardSets] = useState([]);
  const [quizzes, setQuizzes] = useState([]);
  const [articles, setArticles] = useState([]);

  const [selectedFlashcardSet, setSelectedFlashcardSet] = useState(null);
  const [selectedQuiz, setSelectedQuiz] = useState(null);
  const [selectedArticle, setSelectedArticle] = useState(null);

  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState("");

  const [activeFlashcardCardIndex, setActiveFlashcardCardIndex] = useState(0);
  const [activeQuizQuestionIndex, setActiveQuizQuestionIndex] = useState(0);

  const [flashcardForm, setFlashcardForm] = useState(emptyFlashcardForm);
  const [quizForm, setQuizForm] = useState(emptyQuizForm);
  const [articleForm, setArticleForm] = useState(emptyArticleForm);

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    try {
      setIsLoading(true);
      const data = await getCommunityAdminData();
      setFlashcardSets(data.flashcardSets);
      setQuizzes(data.quizzes);
      setArticles(data.articles);
    } catch (error) {
      setMessage("Failed to load community data: " + error.message);
    } finally {
      setIsLoading(false);
    }
  }

  function showMessage(text) {
    setMessage(text);
  }

  function getStatusText(isActive) {
    return isActive === false ? "Hidden" : "Active";
  }

  function getStatusClass(isActive) {
    return isActive === false
      ? "community-status-badge inactive"
      : "community-status-badge active-faq";
  }

  function changeTab(tabName) {
    setActiveTab(tabName);
    setMessage("");
  }

  // =========================
  // Flashcard form
  // =========================

  function startCreateFlashcard() {
    setSelectedFlashcardSet(null);
    setFlashcardForm({
      ...emptyFlashcardForm,
      cards: [{ ...emptyFlashcard }],
    });
    setActiveFlashcardCardIndex(0);
    setMessage("");
  }

  async function selectFlashcardSet(item) {
    try {
      setSelectedFlashcardSet(item);
      setMessage("Loading selected flashcard set...");
      const cards = await getFlashcardsBySetId(item.id);
      const formData = buildFlashcardFormFromData(item, cards);
      setFlashcardForm(formData);
      setActiveFlashcardCardIndex(0);
      setMessage("");
    } catch (error) {
      showMessage("Failed to load flashcard cards: " + error.message);
    }
  }

  function updateFlashcardCard(index, field, value) {
    const updatedCards = [...flashcardForm.cards];
    updatedCards[index] = {
      ...updatedCards[index],
      [field]: value,
    };

    setFlashcardForm({ ...flashcardForm, cards: updatedCards });
  }

  function addFlashcardRow() {
    const updatedCards = [...flashcardForm.cards, { ...emptyFlashcard }];

    setFlashcardForm({
      ...flashcardForm,
      cards: updatedCards,
    });

    setActiveFlashcardCardIndex(updatedCards.length - 1);
  }

  function removeFlashcardRow(index) {
    if (flashcardForm.cards.length === 1) return;

    const updatedCards = flashcardForm.cards.filter((card, i) => {
      return i !== index;
    });

    let newActiveIndex = activeFlashcardCardIndex;

    if (index === activeFlashcardCardIndex && newActiveIndex > 0) {
      newActiveIndex = newActiveIndex - 1;
    } else if (index < activeFlashcardCardIndex) {
      newActiveIndex = newActiveIndex - 1;
    }

    if (newActiveIndex >= updatedCards.length) {
      newActiveIndex = updatedCards.length - 1;
    }

    setFlashcardForm({ ...flashcardForm, cards: updatedCards });
    setActiveFlashcardCardIndex(newActiveIndex);
  }

  async function handleSaveFlashcardSet() {
    const validCards = flashcardForm.cards.filter((card) => {
      return card.frontText.trim() !== "" && card.backExplanation.trim() !== "";
    });

    if (flashcardForm.title.trim() === "") {
      showMessage("Please enter flashcard set title.");
      return;
    }

    if (validCards.length === 0) {
      showMessage("Please enter at least one flashcard front and back.");
      return;
    }

    try {
      setIsSaving(true);

      if (selectedFlashcardSet) {
        await updateFlashcardSet(selectedFlashcardSet.id, flashcardForm);
        showMessage("Flashcard set updated successfully.");
      } else {
        await addFlashcardSet(flashcardForm);
        showMessage("Flashcard set created successfully.");
      }

      await loadData();
      startCreateFlashcard();
    } catch (error) {
      showMessage("Failed to save flashcard set: " + error.message);
    } finally {
      setIsSaving(false);
    }
  }

  async function handleDeleteFlashcardSet() {
    if (!selectedFlashcardSet) return;

    const confirmDelete = window.confirm(
      "Delete this flashcard set and its cards?"
    );

    if (!confirmDelete) return;

    try {
      setIsSaving(true);
      await deleteFlashcardSet(selectedFlashcardSet.id);
      await loadData();
      startCreateFlashcard();
      showMessage("Flashcard set deleted.");
    } catch (error) {
      showMessage("Failed to delete flashcard set: " + error.message);
    } finally {
      setIsSaving(false);
    }
  }

  // =========================
  // Quiz form
  // =========================

  function startCreateQuiz() {
    setSelectedQuiz(null);
    setQuizForm({
      ...emptyQuizForm,
      questions: [{ ...emptyQuestion }],
    });
    setActiveQuizQuestionIndex(0);
    setMessage("");
  }

  async function selectQuiz(item) {
    try {
      setSelectedQuiz(item);
      setMessage("Loading selected quiz...");
      const questions = await getQuestionsByQuizId(item.id);
      const formData = buildQuizFormFromData(item, questions);
      setQuizForm(formData);
      setActiveQuizQuestionIndex(0);
      setMessage("");
    } catch (error) {
      showMessage("Failed to load quiz questions: " + error.message);
    }
  }

  function updateQuizQuestion(index, field, value) {
    const updatedQuestions = [...quizForm.questions];
    updatedQuestions[index] = {
      ...updatedQuestions[index],
      [field]: value,
    };

    setQuizForm({ ...quizForm, questions: updatedQuestions });
  }

  function addQuestionRow() {
    const updatedQuestions = [...quizForm.questions, { ...emptyQuestion }];

    setQuizForm({
      ...quizForm,
      questions: updatedQuestions,
    });

    setActiveQuizQuestionIndex(updatedQuestions.length - 1);
  }

  function removeQuestionRow(index) {
    if (quizForm.questions.length === 1) return;

    const updatedQuestions = quizForm.questions.filter((question, i) => {
      return i !== index;
    });

    let newActiveIndex = activeQuizQuestionIndex;

    if (index === activeQuizQuestionIndex && newActiveIndex > 0) {
      newActiveIndex = newActiveIndex - 1;
    } else if (index < activeQuizQuestionIndex) {
      newActiveIndex = newActiveIndex - 1;
    }

    if (newActiveIndex >= updatedQuestions.length) {
      newActiveIndex = updatedQuestions.length - 1;
    }

    setQuizForm({ ...quizForm, questions: updatedQuestions });
    setActiveQuizQuestionIndex(newActiveIndex);
  }

  async function handleSaveQuiz() {
    const validQuestions = quizForm.questions.filter((question) => {
      return (
        question.questionText.trim() !== "" &&
        question.optionA.trim() !== "" &&
        question.optionB.trim() !== "" &&
        question.optionC.trim() !== "" &&
        question.optionD.trim() !== ""
      );
    });

    if (quizForm.title.trim() === "") {
      showMessage("Please enter quiz title.");
      return;
    }

    if (validQuestions.length === 0) {
      showMessage("Please enter at least one quiz question with four options.");
      return;
    }

    try {
      setIsSaving(true);

      if (selectedQuiz) {
        await updateQuiz(selectedQuiz.id, quizForm);
        showMessage("Quiz updated successfully.");
      } else {
        await addQuiz(quizForm);
        showMessage("Quiz created successfully.");
      }

      await loadData();
      startCreateQuiz();
    } catch (error) {
      showMessage("Failed to save quiz: " + error.message);
    } finally {
      setIsSaving(false);
    }
  }

  async function handleDeleteQuiz() {
    if (!selectedQuiz) return;

    const confirmDelete = window.confirm(
      "Delete this quiz, questions, and options?"
    );

    if (!confirmDelete) return;

    try {
      setIsSaving(true);
      await deleteQuiz(selectedQuiz.id);
      await loadData();
      startCreateQuiz();
      showMessage("Quiz deleted.");
    } catch (error) {
      showMessage("Failed to delete quiz: " + error.message);
    } finally {
      setIsSaving(false);
    }
  }

  // =========================
  // Article form
  // =========================

  function startCreateArticle() {
    setSelectedArticle(null);
    setArticleForm({ ...emptyArticleForm });
    setMessage("");
  }

  function selectArticle(item) {
    setSelectedArticle(item);
    setArticleForm({
      title: item.title || "",
      summary: item.summary || "",
      category: item.category || "",
      sourceName: item.sourceName || "",
      sourceUrl: item.sourceUrl || "",
      imagePath: item.imagePath || "",
      content: item.content || "",
      articleOrder: item.articleOrder || 1,
      isActive: item.isActive === false ? false : true,
    });
    setMessage("");
  }

  async function handleSaveArticle() {
    if (articleForm.title.trim() === "") {
      showMessage("Please enter article title.");
      return;
    }

    if (articleForm.summary.trim() === "" || articleForm.content.trim() === "") {
      showMessage("Please enter article summary and content.");
      return;
    }

    try {
      setIsSaving(true);

      if (selectedArticle) {
        await updateArticle(selectedArticle.id, articleForm);
        showMessage("Article updated successfully.");
      } else {
        await addArticle(articleForm);
        showMessage("Article created successfully.");
      }

      await loadData();
      startCreateArticle();
    } catch (error) {
      showMessage("Failed to save article: " + error.message);
    } finally {
      setIsSaving(false);
    }
  }

  async function handleDeleteArticle() {
    if (!selectedArticle) return;

    const confirmDelete = window.confirm("Delete this article?");

    if (!confirmDelete) return;

    try {
      setIsSaving(true);
      await deleteArticle(selectedArticle.id);
      await loadData();
      startCreateArticle();
      showMessage("Article deleted.");
    } catch (error) {
      showMessage("Failed to delete article: " + error.message);
    } finally {
      setIsSaving(false);
    }
  }

  const currentFlashcard = flashcardForm.cards[activeFlashcardCardIndex];
  const currentQuestion = quizForm.questions[activeQuizQuestionIndex];

  return (
    <div className="community-page">
      <h1>Community</h1>

      <p className="page-subtitle">
        Create and edit quiz, flashcard, and article content.
      </p>

      {message !== "" && <div className="message-box">{message}</div>}

      <div className="community-tabs">
        <button
          className={activeTab === "flashcards" ? "active-tab" : ""}
          onClick={() => changeTab("flashcards")}
        >
          Flashcards
        </button>

        <button
          className={activeTab === "quiz" ? "active-tab" : ""}
          onClick={() => changeTab("quiz")}
        >
          Quiz
        </button>

        <button
          className={activeTab === "articles" ? "active-tab" : ""}
          onClick={() => changeTab("articles")}
        >
          Articles
        </button>
      </div>

      {isLoading && (
        <div className="card">
          <p className="empty-text">Loading community content...</p>
        </div>
      )}

      {!isLoading && activeTab === "flashcards" && (
        <div className="community-admin-grid">
          <div className="card community-list-card">
            <div className="community-list-header">
              <h2>Flashcard Sets</h2>
              <button className="primary-btn" onClick={startCreateFlashcard}>
                Create Set
              </button>
            </div>

            {flashcardSets.length === 0 ? (
              <p className="empty-text">No flashcard set yet.</p>
            ) : (
              <div className="community-list">
                {flashcardSets.map((item) => (
                  <button
                    key={item.id}
                    className={
                      selectedFlashcardSet?.id === item.id
                        ? "community-list-item active"
                        : "community-list-item"
                    }
                    onClick={() => selectFlashcardSet(item)}
                  >
                    <div>
                      <h3>{item.title || "No Title"}</h3>
                      <p>
                        {(item.totalCards || 0) + " cards"} • {item.level || "-"}
                      </p>
                    </div>

                    <span className={getStatusClass(item.isActive)}>
                      {getStatusText(item.isActive)}
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="card community-detail-card">
            <h2>
              {selectedFlashcardSet
                ? "Edit Flashcard Set"
                : "Create Flashcard Set"}
            </h2>

            <div className="editor-layout">
              <div className="basic-form-panel">
                <h3>Set Info</h3>

                <label>Set Title</label>
                <input
                  type="text"
                  value={flashcardForm.title}
                  onChange={(e) =>
                    setFlashcardForm({ ...flashcardForm, title: e.target.value })
                  }
                  placeholder="e.g. Glass Bottle Recycling"
                />

                <div className="form-two-grid">
                  <div>
                    <label>Level</label>
                    <select
                      value={flashcardForm.level}
                      onChange={(e) =>
                        setFlashcardForm({
                          ...flashcardForm,
                          level: e.target.value,
                        })
                      }
                    >
                      <option>Beginner</option>
                      <option>Intermediate</option>
                      <option>Advanced</option>
                    </select>
                  </div>

                  <div>
                    <label>Status</label>
                    <label className="community-checkbox-row">
                      <input
                        type="checkbox"
                        checked={flashcardForm.isActive}
                        onChange={(e) =>
                          setFlashcardForm({
                            ...flashcardForm,
                            isActive: e.target.checked,
                          })
                        }
                      />
                      Active
                    </label>
                  </div>
                </div>

                <label>Description</label>
                <input
                  type="text"
                  value={flashcardForm.description}
                  onChange={(e) =>
                    setFlashcardForm({
                      ...flashcardForm,
                      description: e.target.value,
                    })
                  }
                  placeholder="Short description for users..."
                />
              </div>

              <div className="item-editor-panel">
                <div className="mini-title-row">
                  <h3>Cards</h3>
                  <button className="small-btn add-btn" onClick={addFlashcardRow}>
                    + Add Card
                  </button>
                </div>

                <div className="item-tab-row">
                  {flashcardForm.cards.map((card, index) => (
                    <button
                      key={index}
                      type="button"
                      className={
                        activeFlashcardCardIndex === index
                          ? "item-tab active-item-tab"
                          : "item-tab"
                      }
                      onClick={() => setActiveFlashcardCardIndex(index)}
                    >
                      Card {index + 1}
                    </button>
                  ))}
                </div>

                {currentFlashcard && (
                  <div className="flashcard-form compact-form">
                    <div className="mini-title-row">
                      <h3>Flashcard {activeFlashcardCardIndex + 1}</h3>
                      {flashcardForm.cards.length > 1 && (
                        <button
                          className="small-btn danger-btn"
                          type="button"
                          onClick={() =>
                            removeFlashcardRow(activeFlashcardCardIndex)
                          }
                        >
                          Remove This Card
                        </button>
                      )}
                    </div>

                    <div className="form-two-grid">
                      <div>
                        <label>Front</label>
                        <input
                          type="text"
                          value={currentFlashcard.frontText}
                          onChange={(e) =>
                            updateFlashcardCard(
                              activeFlashcardCardIndex,
                              "frontText",
                              e.target.value
                            )
                          }
                          placeholder="Question / Term"
                        />
                      </div>

                      <div>
                        <label>Back</label>
                        <input
                          type="text"
                          value={currentFlashcard.backExplanation}
                          onChange={(e) =>
                            updateFlashcardCard(
                              activeFlashcardCardIndex,
                              "backExplanation",
                              e.target.value
                            )
                          }
                          placeholder="Answer / Tip"
                        />
                      </div>
                    </div>

                    <label>Image Path</label>
                    <input
                      type="text"
                      value={currentFlashcard.imagePath}
                      onChange={(e) =>
                        updateFlashcardCard(
                          activeFlashcardCardIndex,
                          "imagePath",
                          e.target.value
                        )
                      }
                      placeholder="assets/images/flashcards/plastic_bottle.png"
                    />

                    <div className="form-two-grid">
                      <div>
                        <label>Category</label>
                        <input
                          type="text"
                          value={currentFlashcard.category}
                          onChange={(e) =>
                            updateFlashcardCard(
                              activeFlashcardCardIndex,
                              "category",
                              e.target.value
                            )
                          }
                          placeholder="e.g. Plastic"
                        />
                      </div>

                      <div>
                        <label>Source Note</label>
                        <input
                          type="text"
                          value={currentFlashcard.sourceNote}
                          onChange={(e) =>
                            updateFlashcardCard(
                              activeFlashcardCardIndex,
                              "sourceNote",
                              e.target.value
                            )
                          }
                          placeholder="e.g. Zero Waste Malaysia"
                        />
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>

            <div className="button-row">
              <button
                className="primary-btn"
                onClick={handleSaveFlashcardSet}
                disabled={isSaving}
              >
                {selectedFlashcardSet ? "Update Set" : "Create Set"}
              </button>

              <button
                className="normal-btn"
                type="button"
                onClick={startCreateFlashcard}
              >
                Clear
              </button>

              {selectedFlashcardSet && (
                <button
                  className="danger-btn"
                  type="button"
                  onClick={handleDeleteFlashcardSet}
                  disabled={isSaving}
                >
                  Delete
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {!isLoading && activeTab === "quiz" && (
        <div className="community-admin-grid">
          <div className="card community-list-card">
            <div className="community-list-header">
              <h2>Quiz List</h2>
              <button className="primary-btn" onClick={startCreateQuiz}>
                Create Quiz
              </button>
            </div>

            {quizzes.length === 0 ? (
              <p className="empty-text">No quiz yet.</p>
            ) : (
              <div className="community-list">
                {quizzes.map((item) => (
                  <button
                    key={item.id}
                    className={
                      selectedQuiz?.id === item.id
                        ? "community-list-item active"
                        : "community-list-item"
                    }
                    onClick={() => selectQuiz(item)}
                  >
                    <div>
                      <h3>{item.title || "No Title"}</h3>
                      <p>
                        {(item.totalQuestions || 0) + " questions"} • {item.level || "-"}
                      </p>
                    </div>

                    <span className={getStatusClass(item.isActive)}>
                      {getStatusText(item.isActive)}
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="card community-detail-card">
            <h2>{selectedQuiz ? "Edit Quiz" : "Create Quiz"}</h2>

            <div className="editor-layout">
              <div className="basic-form-panel">
                <h3>Quiz Info</h3>

                <label>Quiz Title</label>
                <input
                  type="text"
                  value={quizForm.title}
                  onChange={(e) =>
                    setQuizForm({ ...quizForm, title: e.target.value })
                  }
                  placeholder="e.g. Recycling Knowledge Quiz"
                />

                <div className="form-two-grid">
                  <div>
                    <label>Level</label>
                    <select
                      value={quizForm.level}
                      onChange={(e) =>
                        setQuizForm({ ...quizForm, level: e.target.value })
                      }
                    >
                      <option>Beginner</option>
                      <option>Intermediate</option>
                      <option>Advanced</option>
                    </select>
                  </div>

                  <div>
                    <label>Status</label>
                    <label className="community-checkbox-row">
                      <input
                        type="checkbox"
                        checked={quizForm.isActive}
                        onChange={(e) =>
                          setQuizForm({
                            ...quizForm,
                            isActive: e.target.checked,
                          })
                        }
                      />
                      Active
                    </label>
                  </div>
                </div>

                <label>Description</label>
                <input
                  type="text"
                  value={quizForm.description}
                  onChange={(e) =>
                    setQuizForm({ ...quizForm, description: e.target.value })
                  }
                  placeholder="Short description for users..."
                />
              </div>

              <div className="item-editor-panel">
                <div className="mini-title-row">
                  <h3>Questions</h3>
                  <button className="small-btn add-btn" onClick={addQuestionRow}>
                    + Add Question
                  </button>
                </div>

                <div className="item-tab-row">
                  {quizForm.questions.map((question, index) => (
                    <button
                      key={index}
                      type="button"
                      className={
                        activeQuizQuestionIndex === index
                          ? "item-tab active-item-tab"
                          : "item-tab"
                      }
                      onClick={() => setActiveQuizQuestionIndex(index)}
                    >
                      Q{index + 1}
                    </button>
                  ))}
                </div>

                {currentQuestion && (
                  <div className="flashcard-form compact-form">
                    <div className="mini-title-row">
                      <h3>Question {activeQuizQuestionIndex + 1}</h3>
                      {quizForm.questions.length > 1 && (
                        <button
                          className="small-btn danger-btn"
                          type="button"
                          onClick={() =>
                            removeQuestionRow(activeQuizQuestionIndex)
                          }
                        >
                          Remove This Question
                        </button>
                      )}
                    </div>

                    <label>Question</label>
                    <input
                      type="text"
                      value={currentQuestion.questionText}
                      onChange={(e) =>
                        updateQuizQuestion(
                          activeQuizQuestionIndex,
                          "questionText",
                          e.target.value
                        )
                      }
                      placeholder="Enter quiz question..."
                    />

                    <label>Image Path</label>
                    <input
                      type="text"
                      value={currentQuestion.imagePath}
                      onChange={(e) =>
                        updateQuizQuestion(
                          activeQuizQuestionIndex,
                          "imagePath",
                          e.target.value
                        )
                      }
                      placeholder="assets/images/quiz/plastic_bottle.png"
                    />

                    <div className="form-two-grid">
                      <div>
                        <label>Option A</label>
                        <input
                          type="text"
                          value={currentQuestion.optionA}
                          onChange={(e) =>
                            updateQuizQuestion(
                              activeQuizQuestionIndex,
                              "optionA",
                              e.target.value
                            )
                          }
                          placeholder="First option"
                        />
                      </div>

                      <div>
                        <label>Option B</label>
                        <input
                          type="text"
                          value={currentQuestion.optionB}
                          onChange={(e) =>
                            updateQuizQuestion(
                              activeQuizQuestionIndex,
                              "optionB",
                              e.target.value
                            )
                          }
                          placeholder="Second option"
                        />
                      </div>
                    </div>

                    <div className="form-two-grid">
                      <div>
                        <label>Option C</label>
                        <input
                          type="text"
                          value={currentQuestion.optionC}
                          onChange={(e) =>
                            updateQuizQuestion(
                              activeQuizQuestionIndex,
                              "optionC",
                              e.target.value
                            )
                          }
                          placeholder="Third option"
                        />
                      </div>

                      <div>
                        <label>Option D</label>
                        <input
                          type="text"
                          value={currentQuestion.optionD}
                          onChange={(e) =>
                            updateQuizQuestion(
                              activeQuizQuestionIndex,
                              "optionD",
                              e.target.value
                            )
                          }
                          placeholder="Fourth option"
                        />
                      </div>
                    </div>

                    <div className="form-two-grid">
                      <div>
                        <label>Correct Answer</label>
                        <select
                          value={currentQuestion.correctAnswer}
                          onChange={(e) =>
                            updateQuizQuestion(
                              activeQuizQuestionIndex,
                              "correctAnswer",
                              e.target.value
                            )
                          }
                        >
                          <option value="A">Option A</option>
                          <option value="B">Option B</option>
                          <option value="C">Option C</option>
                          <option value="D">Option D</option>
                        </select>
                      </div>

                      <div>
                        <label>Explanation</label>
                        <input
                          type="text"
                          value={currentQuestion.explanation}
                          onChange={(e) =>
                            updateQuizQuestion(
                              activeQuizQuestionIndex,
                              "explanation",
                              e.target.value
                            )
                          }
                          placeholder="Shown after user answers"
                        />
                      </div>
                    </div>

                    <div className="form-two-grid">
                      <div>
                        <label>Source Title</label>
                        <input
                          type="text"
                          value={currentQuestion.sourceTitle}
                          onChange={(e) =>
                            updateQuizQuestion(
                              activeQuizQuestionIndex,
                              "sourceTitle",
                              e.target.value
                            )
                          }
                          placeholder="e.g. SWCorp 3R Guide"
                        />
                      </div>

                      <div>
                        <label>Source URL</label>
                        <input
                          type="text"
                          value={currentQuestion.sourceUrl}
                          onChange={(e) =>
                            updateQuizQuestion(
                              activeQuizQuestionIndex,
                              "sourceUrl",
                              e.target.value
                            )
                          }
                          placeholder="Reference website link"
                        />
                      </div>
                    </div>

                    <label>Source Note</label>
                    <input
                      type="text"
                      value={currentQuestion.sourceNote}
                      onChange={(e) =>
                        updateQuizQuestion(
                          activeQuizQuestionIndex,
                          "sourceNote",
                          e.target.value
                        )
                      }
                      placeholder="Short source note"
                    />
                  </div>
                )}
              </div>
            </div>

            <div className="button-row">
              <button
                className="primary-btn"
                onClick={handleSaveQuiz}
                disabled={isSaving}
              >
                {selectedQuiz ? "Update Quiz" : "Create Quiz"}
              </button>

              <button className="normal-btn" type="button" onClick={startCreateQuiz}>
                Clear
              </button>

              {selectedQuiz && (
                <button
                  className="danger-btn"
                  type="button"
                  onClick={handleDeleteQuiz}
                  disabled={isSaving}
                >
                  Delete
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {!isLoading && activeTab === "articles" && (
        <div className="community-admin-grid">
          <div className="card community-list-card">
            <div className="community-list-header">
              <h2>Article List</h2>
              <button className="primary-btn" onClick={startCreateArticle}>
                Create Article
              </button>
            </div>

            {articles.length === 0 ? (
              <p className="empty-text">No article yet.</p>
            ) : (
              <div className="community-list">
                {articles.map((item) => (
                  <button
                    key={item.id}
                    className={
                      selectedArticle?.id === item.id
                        ? "community-list-item active"
                        : "community-list-item"
                    }
                    onClick={() => selectArticle(item)}
                  >
                    <div>
                      <h3>{item.title || "No Title"}</h3>
                      <p>{item.category || "No Category"}</p>
                    </div>

                    <span className={getStatusClass(item.isActive)}>
                      {getStatusText(item.isActive)}
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="card community-detail-card">
            <h2>{selectedArticle ? "Edit Article" : "Create Article"}</h2>

            <label>Article Title</label>
            <input
              type="text"
              value={articleForm.title}
              onChange={(e) =>
                setArticleForm({ ...articleForm, title: e.target.value })
              }
              placeholder="Enter article title..."
            />

            <label>Summary</label>
            <input
              type="text"
              value={articleForm.summary}
              onChange={(e) =>
                setArticleForm({ ...articleForm, summary: e.target.value })
              }
              placeholder="Short summary for article list..."
            />

            <div className="form-two-grid">
              <div>
                <label>Category</label>
                <input
                  type="text"
                  value={articleForm.category}
                  onChange={(e) =>
                    setArticleForm({ ...articleForm, category: e.target.value })
                  }
                  placeholder="e.g. Recycling Guide"
                />
              </div>

              <div>
                <label>Order</label>
                <input
                  type="number"
                  value={articleForm.articleOrder}
                  onChange={(e) =>
                    setArticleForm({
                      ...articleForm,
                      articleOrder: e.target.value,
                    })
                  }
                />
              </div>
            </div>

            <label>Image Path</label>
            <input
              type="text"
              value={articleForm.imagePath}
              onChange={(e) =>
                setArticleForm({ ...articleForm, imagePath: e.target.value })
              }
              placeholder="assets/images/articles/article1.png"
            />

            <div className="form-two-grid">
              <div>
                <label>Source Name</label>
                <input
                  type="text"
                  value={articleForm.sourceName}
                  onChange={(e) =>
                    setArticleForm({
                      ...articleForm,
                      sourceName: e.target.value,
                    })
                  }
                  placeholder="e.g. Zero Waste Malaysia"
                />
              </div>

              <div>
                <label>Source URL</label>
                <input
                  type="text"
                  value={articleForm.sourceUrl}
                  onChange={(e) =>
                    setArticleForm({ ...articleForm, sourceUrl: e.target.value })
                  }
                  placeholder="Reference website link..."
                />
              </div>
            </div>

            <label>Article Content</label>
            <textarea
              value={articleForm.content}
              onChange={(e) =>
                setArticleForm({ ...articleForm, content: e.target.value })
              }
              placeholder="Write article content here..."
            ></textarea>

            <label className="community-checkbox-row">
              <input
                type="checkbox"
                checked={articleForm.isActive}
                onChange={(e) =>
                  setArticleForm({
                    ...articleForm,
                    isActive: e.target.checked,
                  })
                }
              />
              Active
            </label>

            <p className="form-help">
              Image path must already exist inside Flutter assets. This admin page
              saves the path only.
            </p>

            <div className="button-row">
              <button
                className="primary-btn"
                onClick={handleSaveArticle}
                disabled={isSaving}
              >
                {selectedArticle ? "Update Article" : "Create Article"}
              </button>

              <button
                className="normal-btn"
                type="button"
                onClick={startCreateArticle}
              >
                Clear
              </button>

              {selectedArticle && (
                <button
                  className="danger-btn"
                  type="button"
                  onClick={handleDeleteArticle}
                  disabled={isSaving}
                >
                  Delete
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default CommunityPage;
