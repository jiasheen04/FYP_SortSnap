import { useState } from "react";

function CommunityPage() {
  const [activeTab, setActiveTab] = useState("flashcards");

  return (
    <div className="community-page">
      <h1>Community</h1>

      <p className="page-subtitle">
        Create and manage quiz, flashcard, and article content for the mobile app.
      </p>

      <div className="community-tabs">
        <button
          className={activeTab === "flashcards" ? "active-tab" : ""}
          onClick={() => setActiveTab("flashcards")}
        >
          Flashcards
        </button>

        <button
          className={activeTab === "quiz" ? "active-tab" : ""}
          onClick={() => setActiveTab("quiz")}
        >
          Quiz
        </button>

        <button
          className={activeTab === "articles" ? "active-tab" : ""}
          onClick={() => setActiveTab("articles")}
        >
          Articles
        </button>
      </div>

      {activeTab === "flashcards" && (
        <div className="two-column">
          <div className="card">
            <h2>Flashcard Sets</h2>

            <div className="list-box">
              <b>Paper & Cardboard Basics</b>
              <p>Set size: 5 cards · Level: Beginner</p>
              <span className="status-green">Active</span>
            </div>

            <div className="list-box">
              <b>Plastic Bottles Basics</b>
              <p>Set size: 5 cards · Level: Intermediate</p>
              <span className="status-blue">Draft</span>
            </div>

            <div className="button-row">
              <button className="normal-btn">Edit Selected</button>
              <button className="normal-btn">Disable</button>
              <button className="normal-btn">Delete</button>
            </div>
          </div>

          <div className="card">
            <h2>Create Flashcard Set</h2>

            <label>Set Title</label>
            <input type="text" placeholder="e.g. Glass Bottle Recycling" />

            <label>Level</label>
            <select>
              <option>Beginner</option>
              <option>Intermediate</option>
              <option>Advanced</option>
            </select>

            <label>Description</label>
            <input type="text" placeholder="Short description for users..." />

            <div className="flashcard-form">
              <h3>Flashcard 1</h3>

              <label>Front</label>
              <input type="text" placeholder="Question / Term" />

              <label>Back</label>
              <input type="text" placeholder="Answer / Tip" />
            </div>

            <div className="button-row">
              <button className="primary-btn">Save Set</button>
            </div>
          </div>
        </div>
      )}

      {activeTab === "quiz" && (
        <div className="two-column">
          <div className="card">
            <h2>Quiz List</h2>

            <div className="list-box">
              <b>Recycling Basics Quiz</b>
              <p>10 questions · Beginner</p>
              <span className="status-green">Active</span>
            </div>

            <div className="list-box">
              <b>Plastic Recycling Quiz</b>
              <p>8 questions · Intermediate</p>
              <span className="status-blue">Draft</span>
            </div>

            <div className="button-row">
              <button className="normal-btn">Edit Selected</button>
              <button className="normal-btn">Disable</button>
              <button className="normal-btn">Delete</button>
            </div>
          </div>

          <div className="card">
            <h2>Create Quiz</h2>

            <label>Quiz Title</label>
            <input type="text" placeholder="e.g. Recycling Knowledge Quiz" />

            <label>Level</label>
            <select>
              <option>Beginner</option>
              <option>Intermediate</option>
              <option>Advanced</option>
            </select>

            <label>Question</label>
            <input type="text" placeholder="Enter quiz question..." />

            <label>Option A</label>
            <input type="text" placeholder="First option" />

            <label>Option B</label>
            <input type="text" placeholder="Second option" />

            <label>Correct Answer</label>
            <select>
              <option>Option A</option>
              <option>Option B</option>
            </select>

            <div className="button-row">
              <button className="primary-btn">Save Quiz</button>
            </div>
          </div>
        </div>
      )}

      {activeTab === "articles" && (
        <div className="two-column">
          <div className="card">
            <h2>Article List</h2>

            <div className="list-box">
              <b>How to Recycle at Home</b>
              <p>Category: Recycling Guide</p>
              <span className="status-green">Published</span>
            </div>

            <div className="list-box">
              <b>Why Recycling Matters</b>
              <p>Category: Awareness</p>
              <span className="status-blue">Draft</span>
            </div>

            <div className="button-row">
              <button className="normal-btn">Edit Selected</button>
              <button className="normal-btn">Unpublish</button>
              <button className="normal-btn">Delete</button>
            </div>
          </div>

          <div className="card">
            <h2>Create Article</h2>

            <label>Article Title</label>
            <input type="text" placeholder="Enter article title..." />

            <label>Category</label>
            <input type="text" placeholder="e.g. Recycling Guide" />

            <label>Source URL</label>
            <input type="text" placeholder="Reference website link..." />

            <label>Article Content</label>
            <textarea placeholder="Write article content here..."></textarea>

            <div className="button-row">
              <button className="primary-btn">Save Article</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default CommunityPage;