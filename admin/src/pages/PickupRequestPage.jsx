import { useEffect, useState } from "react";

import {
  getAllPickupRequests,
  updatePickupStatus,
  forwardPickupRequest,
} from "../services/pickupRequestService";

import { getAllRecyclingPoints } from "../services/recyclingPointService";

function ViewRequestPage() {
  const [pickupRequests, setPickupRequests] = useState([]);
  const [recyclingPoints, setRecyclingPoints] = useState([]);
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [selectedPointId, setSelectedPointId] = useState("");
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");

  useEffect(() => {
    loadPageData();
  }, []);

  async function loadPageData() {
    try {
      setLoading(true);
      setMessage("");

      const requestData = await getAllPickupRequests();
      const pointData = await getAllRecyclingPoints();

      setPickupRequests(requestData);
      setRecyclingPoints(pointData);

      if (requestData.length > 0) {
        const firstRequest = requestData[0];

        setSelectedRequest(firstRequest);
        setSelectedPointId(firstRequest.forwardedToPointId || "");
      } else {
        setSelectedRequest(null);
        setSelectedPointId("");
      }
    } catch (error) {
      console.log(error);
      setMessage("Failed to load pickup request data.");
    } finally {
      setLoading(false);
    }
  }

  function handleSelectRequest(request) {
    setSelectedRequest(request);
    setSelectedPointId(request.forwardedToPointId || "");
    setMessage("");
  }

  async function handleUpdateStatus(newStatus) {
    if (!selectedRequest) {
      return;
    }

    try {
      await updatePickupStatus(selectedRequest.id, newStatus);
      setMessage("Status updated successfully.");
      await loadPageData();
    } catch (error) {
      console.log(error);
      setMessage("Failed to update status.");
    }
  }

  async function handleForwardRequest() {
    if (!selectedRequest) {
      return;
    }

    if (!selectedPointId) {
      setMessage("Please select a recycling point first.");
      return;
    }

    try {
      await forwardPickupRequest(selectedRequest.id, selectedPointId);
      setMessage("Pickup request forwarded successfully.");
      await loadPageData();
    } catch (error) {
      console.log(error);
      setMessage("Failed to forward pickup request.");
    }
  }

  return (
    <div className="request-page">
      <h1>View Request</h1>

      <p className="page-subtitle">
        Manage pickup requests submitted from the Flutter mobile app.
      </p>

      {message && <p className="message-box">{message}</p>}

      {loading ? (
        <div className="card">
          <p>Loading pickup requests...</p>
        </div>
      ) : (
        <div className="two-column">
          <div className="card">
            <h2>Pickup Request List</h2>

            {pickupRequests.length === 0 ? (
              <p className="empty-text">No pickup requests found.</p>
            ) : (
              <table>
                <thead>
                  <tr>
                    <th>Pickup ID</th>
                    <th>User</th>
                    <th>Status</th>
                    <th>Created</th>
                  </tr>
                </thead>

                <tbody>
                  {pickupRequests.map((request) => (
                    <tr
                      key={request.id}
                      onClick={() => handleSelectRequest(request)}
                      className={
                        selectedRequest && selectedRequest.id === request.id
                          ? "selected-row"
                          : ""
                      }
                    >
                      <td>{request.pickupId}</td>
                      <td>{request.username}</td>
                      <td>
                        <span className="status-blue">{request.status}</span>
                      </td>
                      <td>{request.getCreatedDateText()}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}

            <button className="normal-btn" onClick={loadPageData}>
              Refresh
            </button>
          </div>

          <div className="card">
            <h2>Request Details</h2>

            {!selectedRequest ? (
              <p className="empty-text">Select a pickup request to view.</p>
            ) : (
              <>
                <div className="detail-row">
                  <b>Pickup ID</b>
                  <span>{selectedRequest.pickupId}</span>
                </div>

                <div className="detail-row">
                  <b>User</b>
                  <span>
                    {selectedRequest.username}{" "}
                    {selectedRequest.userNo
                      ? "(" + selectedRequest.userNo + ")"
                      : ""}
                  </span>
                </div>

                <div className="detail-row">
                  <b>User ID</b>
                  <span>{selectedRequest.userId || "-"}</span>
                </div>

                <div className="detail-row">
                  <b>Address</b>
                  <span>{selectedRequest.pickupAddress}</span>
                </div>

                <div className="detail-row">
                  <b>Unit No</b>
                  <span>{selectedRequest.unitNo || "-"}</span>
                </div>

                <div className="detail-row">
                  <b>Postal Code</b>
                  <span>{selectedRequest.postalCode || "-"}</span>
                </div>

                <div className="detail-row">
                  <b>Items</b>
                  <span>{selectedRequest.getItemsText()}</span>
                </div>

                <div className="detail-row">
                  <b>Remarks</b>
                  <span>{selectedRequest.remarks || "-"}</span>
                </div>

                <div className="detail-row">
                  <b>Status</b>
                  <span className="status-blue">{selectedRequest.status}</span>
                </div>

                <hr />

                <label>Forward To Recycling Point</label>

                <select
                  value={selectedPointId}
                  onChange={(e) => setSelectedPointId(e.target.value)}
                >
                  <option value="">Select recycling point</option>

                  {recyclingPoints.map((point) => (
                    <option key={point.id} value={point.id}>
                      {point.getDisplayName()}
                    </option>
                  ))}
                </select>

                <div className="button-row">
                  <button className="primary-btn" onClick={handleForwardRequest}>
                    Forward Request
                  </button>

                  <button
                    className="normal-btn"
                    onClick={() => handleUpdateStatus("Completed")}
                  >
                    Mark Completed
                  </button>

                  <button
                    className="normal-btn"
                    onClick={() => handleUpdateStatus("Rejected")}
                  >
                    Reject
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

export default ViewRequestPage; 