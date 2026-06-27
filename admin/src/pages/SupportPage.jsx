import { useEffect, useState } from "react";

import {
  listenFeedback,
  listenFaqs,
  updateFeedbackReply,
  createFaq,
  updateFaq,
  deleteFaq,
} from "../services/supportService";

const emptyFaqForm = {
  question: "",
  answer: "",
  category: "",
  order: 1,
  isActive: true,
};

const faqCategories = [
  "General",
  "Chatbot",
  "Image",
  "Map",
  "Education",
  "Pickup",
  "Privacy",
];

function SupportPage() {
  const [activeTab, setActiveTab] = useState("feedback");

  const [feedbackList, setFeedbackList] = useState([]);
  const [faqList, setFaqList] = useState([]);

  const [selectedFeedback, setSelectedFeedback] = useState(null);
  const [replyText, setReplyText] = useState("");
  const [feedbackStatus, setFeedbackStatus] = useState("Open");

  const [selectedFaq, setSelectedFaq] = useState(null);
  const [faqForm, setFaqForm] = useState(emptyFaqForm);

  const [statusFilter, setStatusFilter] = useState("All");
  const [searchText, setSearchText] = useState("");

  useEffect(() => {
    const unsubscribeFeedback = listenFeedback(setFeedbackList);
    const unsubscribeFaqs = listenFaqs(setFaqList);

    return () => {
      unsubscribeFeedback();
      unsubscribeFaqs();
    };
  }, []);

  function formatDate(value) {
    if (!value) return "-";
    if (value.toDate) return value.toDate().toLocaleString();
    return "-";
  }

  const filteredFeedback = feedbackList.filter((item) => {
    const matchStatus = statusFilter === "All" || item.status === statusFilter;

    const search = searchText.toLowerCase();
    const subject = (item.subject || "").toLowerCase();
    const message = (item.message || "").toLowerCase();
    const category = (item.category || "").toLowerCase();

    const matchSearch =
      search === "" ||
      subject.includes(search) ||
      message.includes(search) ||
      category.includes(search);

    return matchStatus && matchSearch;
  });

  const filteredFaq = faqList.filter((item) => {
    const search = searchText.toLowerCase();
    const question = (item.question || "").toLowerCase();
    const answer = (item.answer || "").toLowerCase();
    const category = (item.category || "").toLowerCase();

    return (
      search === "" ||
      question.includes(search) ||
      answer.includes(search) ||
      category.includes(search)
    );
  });

  function selectFeedback(item) {
    setSelectedFeedback(item);
    setReplyText(item.adminReply || "");
    setFeedbackStatus(item.status || "Open");
  }

  async function handleMarkResolved() {
    if (!selectedFeedback) return;

    if (selectedFeedback.status === "Resolved") {
      return;
    }

    if (replyText.trim() === "") {
      alert("Please write a reply before marking resolved.");
      return;
    }

    await updateFeedbackReply(
      selectedFeedback.id,
      replyText.trim(),
      "Resolved"
    );

    setFeedbackStatus("Resolved");
    alert("Feedback marked as resolved.");
  }

  function startCreateFaq() {
    setSelectedFaq(null);
    setFaqForm(emptyFaqForm);
  }

  function selectFaq(item) {
    setSelectedFaq(item);
    setFaqForm({
      question: item.question || "",
      answer: item.answer || "",
      category: item.category || "General",
      order: item.order || 1,
      isActive: item.isActive === false ? false : true,
    });
  }

  function handleFaqChange(event) {
    const { name, value, type, checked } = event.target;

    setFaqForm((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  }

  async function handleSaveFaq(event) {
    event.preventDefault();

    if (faqForm.question.trim() === "" || faqForm.answer.trim() === "") {
      alert("Please fill in question and answer.");
      return;
    }

    if (selectedFaq) {
      await updateFaq(selectedFaq.id, faqForm);
      alert("FAQ updated.");
    } else {
      await createFaq(faqForm);
      alert("FAQ created.");
    }

    startCreateFaq();
  }

  async function handleDeleteFaq() {
    if (!selectedFaq) return;

    const confirmDelete = confirm("Delete this FAQ?");
    if (!confirmDelete) return;

    await deleteFaq(selectedFaq.id);
    alert("FAQ deleted.");

    startCreateFaq();
  }

  const isFeedbackResolved =
    selectedFeedback && selectedFeedback.status === "Resolved";

  return (
    <div className="support-page">
      <h1>Support</h1>

      <p className="page-subtitle">
        Manage Help Centre feedback and FAQ.
      </p>

      <div className="support-top-row">
        <div className="support-tabs">
          <button
            className={activeTab === "feedback" ? "active" : ""}
            onClick={() => {
              setActiveTab("feedback");
              setSearchText("");
            }}
          >
            Feedback
          </button>

          <button
            className={activeTab === "faq" ? "active" : ""}
            onClick={() => {
              setActiveTab("faq");
              setSearchText("");
            }}
          >
            FAQ
          </button>
        </div>

        <div className="support-toolbar">
          <input
            type="text"
            placeholder="Search..."
            value={searchText}
            onChange={(event) => setSearchText(event.target.value)}
          />

          {activeTab === "feedback" && (
            <select
              value={statusFilter}
              onChange={(event) => setStatusFilter(event.target.value)}
            >
              <option value="All">Status</option>
              <option value="Open">Open</option>
              <option value="Resolved">Resolved</option>
            </select>
          )}

          {activeTab === "faq" && (
            <button className="primary-btn" onClick={startCreateFaq}>
              Create FAQ
            </button>
          )}
        </div>
      </div>

      {activeTab === "feedback" && (
        <div className="support-grid">
          <div className="card support-list-card">
            <h2>Feedback List</h2>

            {filteredFeedback.length === 0 ? (
              <p className="empty-text">No feedback found.</p>
            ) : (
              <div className="support-list">
                {filteredFeedback.map((item) => (
                  <button
                    key={item.id}
                    className={
                      selectedFeedback?.id === item.id
                        ? "support-list-item active"
                        : "support-list-item"
                    }
                    onClick={() => selectFeedback(item)}
                  >
                    <div>
                      <h3>{item.subject || "No Subject"}</h3>
                      <p>
                        {item.category || "No Category"} •{" "}
                        {item.username || "Unknown User"} ({item.userNo || "-"})
                      </p>
                    </div>

                    <span className={`status-badge ${item.status || "Open"}`}>
                      {item.status || "Open"}
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="card support-detail-card">
            <h2>Feedback Details</h2>

            {!selectedFeedback ? (
              <p className="empty-text">Select one feedback to view details.</p>
            ) : (
              <>
                <div className="detail-row">
                  <span>Subject</span>
                  <p>{selectedFeedback.subject || "-"}</p>
                </div>

                <div className="detail-row">
                  <span>Category</span>
                  <p>{selectedFeedback.category || "-"}</p>
                </div>

                <div className="detail-row">
                  <span>User</span>
                  <p>
                    {selectedFeedback.username || "Unknown User"}{" "}
                    ({selectedFeedback.userNo || "-"})
                  </p>
                </div>

                <div className="detail-row">
                  <span>User ID</span>
                  <p>{selectedFeedback.userId || "-"}</p>
                </div>
                <div className="detail-row">
                  <span>Created At</span>
                  <p>{formatDate(selectedFeedback.createdAt)}</p>
                </div>

                <div className="detail-row">
                  <span>Message</span>
                  <p>{selectedFeedback.message || "-"}</p>
                </div>

                <label className="form-label">Status</label>
                <input
                  className="support-input"
                  value={feedbackStatus}
                  disabled
                />

                <label className="form-label">Admin Reply</label>
                <textarea
                  className="support-textarea"
                  value={replyText}
                  onChange={(event) => setReplyText(event.target.value)}
                  placeholder="Write admin reply..."
                  disabled={isFeedbackResolved}
                />

                <div className="button-row">
                  <button
                    className="primary-btn"
                    onClick={handleMarkResolved}
                    disabled={isFeedbackResolved}
                  >
                    Mark Resolved
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      )}

      {activeTab === "faq" && (
        <div className="support-grid">
          <div className="card support-list-card">
            <h2>FAQ List</h2>

            {filteredFaq.length === 0 ? (
              <p className="empty-text">No FAQ found.</p>
            ) : (
              <div className="support-list">
                {filteredFaq.map((item) => (
                  <button
                    key={item.id}
                    className={
                      selectedFaq?.id === item.id
                        ? "support-list-item active"
                        : "support-list-item"
                    }
                    onClick={() => selectFaq(item)}
                  >
                    <div>
                      <h3>{item.question || "No Question"}</h3>
                      <p>{item.category || "General"}</p>
                    </div>

                    <span
                      className={
                        item.isActive === false
                          ? "status-badge inactive"
                          : "status-badge active-faq"
                      }
                    >
                      {item.isActive === false ? "Hidden" : "Active"}
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="card support-detail-card">
            <h2>{selectedFaq ? "Edit FAQ" : "Create FAQ"}</h2>

            <form onSubmit={handleSaveFaq}>
              <label className="form-label">Question</label>
              <input
                className="support-input"
                name="question"
                value={faqForm.question}
                onChange={handleFaqChange}
                placeholder="Enter question"
              />

              <label className="form-label">Answer</label>
              <textarea
                className="support-textarea"
                name="answer"
                value={faqForm.answer}
                onChange={handleFaqChange}
                placeholder="Enter answer"
              />

              <div className="form-two-column">
                <div>
                  <label className="form-label">Category</label>
                  <select
                    className="support-input"
                    name="category"
                    value={faqForm.category}
                    onChange={handleFaqChange}
                  >
                    {faqCategories.map((category) => (
                      <option key={category} value={category}>
                        {category}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="form-label">Order</label>
                  <input
                    className="support-input"
                    type="number"
                    name="order"
                    value={faqForm.order}
                    onChange={handleFaqChange}
                  />
                </div>
              </div>

              <label className="checkbox-row">
                <input
                  type="checkbox"
                  name="isActive"
                  checked={faqForm.isActive}
                  onChange={handleFaqChange}
                />
                Active
              </label>

              <div className="button-row">
                <button className="primary-btn" type="submit">
                  {selectedFaq ? "Update FAQ" : "Create FAQ"}
                </button>

                {selectedFaq && (
                  <button
                    className="danger-btn"
                    type="button"
                    onClick={handleDeleteFaq}
                  >
                    Delete
                  </button>
                )}
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default SupportPage;