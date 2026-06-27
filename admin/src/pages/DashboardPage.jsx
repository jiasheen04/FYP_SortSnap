import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { collection, getDocs } from "firebase/firestore";

import { db } from "../firebase/firebase";

function DashboardPage() {
  const [pickupRequests, setPickupRequests] = useState([]);
  const [feedbackList, setFeedbackList] = useState([]);
  const [locationReports, setLocationReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");

  useEffect(() => {
    loadDashboard();
  }, []);

  async function getCollectionList(collectionName) {
    const snapshot = await getDocs(collection(db, collectionName));

    return snapshot.docs.map((docItem) => {
      return {
        id: docItem.id,
        ...docItem.data(),
      };
    });
  }

  async function loadDashboard() {
    setLoading(true);
    setMessage("");

    try {
      const pickupData = await getCollectionList("pickup_requests");
      const feedbackData = await getCollectionList("feedback");
      const reportData = await getCollectionList("location_reports");

      setPickupRequests(pickupData);
      setFeedbackList(feedbackData);
      setLocationReports(reportData);
    } catch (error) {
      console.error(error);
      setMessage("Failed to load dashboard data.");
    }

    setLoading(false);
  }

  function getStatus(item) {
    return String(item.status || "Pending");
  }

  function countStatus(list, statusName) {
    return list.filter((item) => {
      return getStatus(item).toLowerCase() === statusName.toLowerCase();
    }).length;
  }

  function countOpenItems(list) {
    return list.filter((item) => {
      const status = getStatus(item).toLowerCase();

      return (
        status !== "completed" &&
        status !== "resolved" &&
        status !== "closed" &&
        status !== "rejected"
      );
    }).length;
  }

  const pendingPickup = countStatus(pickupRequests, "Pending");
  const openFeedback = countOpenItems(feedbackList);
  const openReports = countOpenItems(locationReports);

  if (loading) {
    return (
      <div>
        <h1>Dashboard</h1>
        <p className="page-subtitle">Loading dashboard...</p>

        <div className="card">
          <p className="empty-text">Please wait...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="dashboard-page">
      <div className="dashboard-header-row">
        <div>
          <h1>Dashboard</h1>
          <p className="page-subtitle">
            Overview of requests, reports and feedback.
          </p>
        </div>

        <button className="normal-btn" onClick={loadDashboard}>
          Refresh
        </button>
      </div>

      {message && <div className="message-box">{message}</div>}

      <div className="dashboard-grid">
        <div className="stat-card">
          <h3>Pending Pickup Requests</h3>
          <p>{pendingPickup}</p>
        </div>

        <div className="stat-card">
          <h3>Open Feedback</h3>
          <p>{openFeedback}</p>
        </div>

        <div className="stat-card">
          <h3>Open Location Reports</h3>
          <p>{openReports}</p>
        </div>
      </div>

      <div className="dashboard-section-grid">
        <div className="card dashboard-summary-card">
          <div className="dashboard-title-row">
            <h2>Pickup Request</h2>
            <Link className="dashboard-link" to="/pickup-request">
              View
            </Link>
          </div>

          <div className="summary-row">
            <span>Pending</span>
            <b>{countStatus(pickupRequests, "Pending")}</b>
          </div>

          <div className="summary-row">
            <span>Forwarded</span>
            <b>{countStatus(pickupRequests, "Forwarded")}</b>
          </div>

          <div className="summary-row">
            <span>Completed</span>
            <b>{countStatus(pickupRequests, "Completed")}</b>
          </div>

          <div className="summary-row total-summary-row">
            <span>Total</span>
            <b>{pickupRequests.length}</b>
          </div>
        </div>

        <div className="card dashboard-summary-card">
          <div className="dashboard-title-row">
            <h2>Feedback</h2>
            <Link className="dashboard-link" to="/support">
              View
            </Link>
          </div>

          <div className="summary-row">
            <span>Open</span>
            <b>{openFeedback}</b>
          </div>

          <div className="summary-row">
            <span>Resolved</span>
            <b>{countStatus(feedbackList, "Resolved")}</b>
          </div>

          <div className="summary-row total-summary-row">
            <span>Total</span>
            <b>{feedbackList.length}</b>
          </div>
        </div>

        <div className="card dashboard-summary-card">
          <div className="dashboard-title-row">
            <h2>Location Report</h2>
            <Link className="dashboard-link" to="/map">
              View
            </Link>
          </div>

          <div className="summary-row">
            <span>Open</span>
            <b>{openReports}</b>
          </div>

          <div className="summary-row">
            <span>Resolved</span>
            <b>{countStatus(locationReports, "Resolved")}</b>
          </div>

          <div className="summary-row total-summary-row">
            <span>Total</span>
            <b>{locationReports.length}</b>
          </div>
        </div>
      </div>
    </div>
  );
}

export default DashboardPage;