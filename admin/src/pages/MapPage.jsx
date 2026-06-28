import { useEffect, useState } from "react";
import {
  collection,
  doc,
  getDocs,
  serverTimestamp,
  updateDoc,
} from "firebase/firestore";

import { db } from "../firebase/firebase";

import {
  addRecyclingPoint,
  deleteRecyclingPoint,
  getAllRecyclingPoints,
  updateRecyclingPoint,
} from "../services/recyclingPointService";

const acceptedTypeOptions = [
  "Plastic",
  "Metal",
  "Paper",
  "Cardboard",
  "Glass",
  "E-waste",
  "Battery",
  "Textile",
];

const dayKeys = [
  "sunday",
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday",
];

function getTodayKey(now) {
  return dayKeys[now.getDay()];
}

function convertToTodayTime(timeText, now) {
  const match = timeText.trim().match(/^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)$/i);

  if (!match) {
    return null;
  }

  let hour = Number(match[1]);
  const minute = Number(match[2] || "0");
  const period = match[3].toUpperCase();

  if (period === "PM" && hour !== 12) {
    hour += 12;
  }

  if (period === "AM" && hour === 12) {
    hour = 0;
  }

  const date = new Date(now);
  date.setHours(hour, minute, 0, 0);

  return date;
}

function isCurrentTimeInside(hoursText, now) {
  const timeRanges = hoursText.split(",");

  for (const range of timeRanges) {
    const times = range.split("-");

    if (times.length !== 2) {
      continue;
    }

    const startTime = convertToTodayTime(times[0].trim(), now);
    let endTime = convertToTodayTime(times[1].trim(), now);

    if (!startTime || !endTime) {
      continue;
    }

    if (endTime < startTime) {
      endTime.setDate(endTime.getDate() + 1);
    }

    if (now >= startTime && now <= endTime) {
      return true;
    }
  }

  return false;
}

function getTodayHours(point, now) {
  const openingHours = point.openingHours || {};
  const todayKey = getTodayKey(now);

  return (openingHours[todayKey] || "").toString();
}

function getCurrentPointStatus(point, now) {
  const firebaseStatus = point.status || "Unknown";
  const firebaseIsOpen = point.isOpen === true;
  const openingHours = point.openingHours || {};

  if (firebaseStatus === "Closed") {
    return "Closed";
  }

  if (Object.keys(openingHours).length === 0) {
    return firebaseIsOpen ? "Open" : "Closed";
  }

  const todayHours = getTodayHours(point, now);

  if (todayHours.trim() === "") {
    return firebaseIsOpen ? "Open" : "Closed";
  }

  if (todayHours.toLowerCase().includes("closed")) {
    return "Closed";
  }

  return isCurrentTimeInside(todayHours, now) ? "Open" : "Closed";
}

const emptyForm = {
  pointCode: "",
  name: "",
  address: "",
  latitude: "",
  longitude: "",
  contact: "",
  area: "",
  status: "Open",
  recyclingStatus: "Accepting Items",
  hours: "",
  types: [],
  monday: "",
  tuesday: "",
  wednesday: "",
  thursday: "",
  friday: "",
  saturday: "",
  sunday: "",
};

function MapPage() {
  const [points, setPoints] = useState([]);
  const [reports, setReports] = useState([]);

  const [form, setForm] = useState(emptyForm);
  const [selectedPoint, setSelectedPoint] = useState(null);

  const [loading, setLoading] = useState(true);
  const [reportLoading, setReportLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [now, setNow] = useState(new Date());

  useEffect(() => {
    loadPoints();
    loadLocationReports();
  }, []);

  useEffect(() => {
    const timer = setInterval(() => {
      setNow(new Date());
    }, 60000);

    return () => clearInterval(timer);
  }, []);

  async function loadPoints() {
    try {
      setLoading(true);
      const pointList = await getAllRecyclingPoints();
      setPoints(pointList);
    } catch (error) {
      console.error("Error loading recycling points:", error);
      alert("Failed to load recycling points.");
    } finally {
      setLoading(false);
    }
  }

  async function loadLocationReports() {
    try {
      setReportLoading(true);

      const userSnapshot = await getDocs(collection(db, "users"));
      const userMap = {};

      userSnapshot.docs.forEach((docItem) => {
        const data = docItem.data();

        const userInfo = {
          username:
            data.username ||
            data.userName ||
            data.name ||
            data.fullName ||
            data.displayName ||
            "",
          userNo: data.userNo || "",
        };

        userMap[docItem.id] = userInfo;

        if (data.userId) {
          userMap[data.userId] = userInfo;
        }

        if (data.uid) {
          userMap[data.uid] = userInfo;
        }

        if (data.userNo) {
          userMap[data.userNo] = userInfo;
        }
      });

      const snapshot = await getDocs(collection(db, "location_reports"));

      const reportList = snapshot.docs.map((docItem) => {
        const data = docItem.data();

        const userData =
          userMap[data.userId] || userMap[data.userNo] || {};

        return {
          id: docItem.id,
          reportCode: data.reportCode || "",
          userId: data.userId || "",
          userNo: userData.userNo || data.userNo || "",
          username: userData.username || data.username || data.userName || "",
          userName: userData.username || data.userName || data.username || "",
          recyclingPointId: data.recyclingPointId || "",
          recyclingPointCode: data.recyclingPointCode || "",
          recyclingPointName: data.recyclingPointName || "",
          issueType: data.issueType || "",
          description: data.description || "",
          status: data.status || "Open",
          createdAt: data.createdAt || null,
          resolvedAt: data.resolvedAt || null,
          resolvedByAdminId: data.resolvedByAdminId || null,
        };
      });

      reportList.sort((a, b) => {
        const dateA = a.createdAt?.seconds || 0;
        const dateB = b.createdAt?.seconds || 0;
        return dateB - dateA;
      });

      setReports(reportList);
    } catch (error) {
      console.error("Error loading location reports:", error);
      alert("Failed to load location reports.");
    } finally {
      setReportLoading(false);
    }
  }

  function handleChange(event) {
    const { name, value } = event.target;

    setForm({
      ...form,
      [name]: value,
    });
  }

  function handleTypeChange(event) {
    const { value, checked } = event.target;

    let updatedTypes = [...form.types];

    if (checked) {
      updatedTypes.push(value);
    } else {
      updatedTypes = updatedTypes.filter((type) => type !== value);
    }

    setForm({
      ...form,
      types: updatedTypes,
    });
  }

  function resetForm() {
    setForm(emptyForm);
    setSelectedPoint(null);
  }

  function handleEdit(point) {
    setSelectedPoint(point);

    setForm({
      pointCode: point.pointCode,
      name: point.name,
      address: point.address,
      latitude: point.latitude,
      longitude: point.longitude,
      contact: point.contact,
      area: point.area,
      status: point.status,
      recyclingStatus: point.recyclingStatus || "Accepting Items",
      hours: point.hours,
      types: point.types || [],
      monday: point.openingHours.monday || "",
      tuesday: point.openingHours.tuesday || "",
      wednesday: point.openingHours.wednesday || "",
      thursday: point.openingHours.thursday || "",
      friday: point.openingHours.friday || "",
      saturday: point.openingHours.saturday || "",
      sunday: point.openingHours.sunday || "",
    });
  }

  function buildPointData() {
    return {
      pointCode: selectedPoint ? form.pointCode : getNextPointCodePreview(),
      name: form.name.trim(),
      address: form.address.trim(),
      latitude: Number(form.latitude),
      longitude: Number(form.longitude),
      contact: form.contact.trim(),
      area: form.area.trim(),
      status: form.status,
      recyclingStatus: form.recyclingStatus,
      hours: form.hours.trim(),
      types: form.types,
      opening_hours: {
        monday: form.monday.trim(),
        tuesday: form.tuesday.trim(),
        wednesday: form.wednesday.trim(),
        thursday: form.thursday.trim(),
        friday: form.friday.trim(),
        saturday: form.saturday.trim(),
        sunday: form.sunday.trim(),
      },
    };
  }

  async function handleSubmit(event) {
    event.preventDefault();

    if (!form.name || !form.address || !form.latitude || !form.longitude) {
      alert("Please fill in name, address, latitude and longitude.");
      return;
    }

    if (isNaN(Number(form.latitude)) || isNaN(Number(form.longitude))) {
      alert("Latitude and longitude must be numbers.");
      return;
    }

    if (form.types.length === 0) {
      alert("Please select at least one accepted type.");
      return;
    }

    try {
      setSaving(true);

      const pointData = buildPointData();

      if (selectedPoint) {
        await updateRecyclingPoint(selectedPoint.id, pointData);
        alert("Recycling point updated.");
      } else {
        await addRecyclingPoint(pointData);
        alert("Recycling point added.");
      }

      resetForm();
      await loadPoints();
    } catch (error) {
      console.error("Error saving recycling point:", error);
      alert("Failed to save recycling point.");
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete(point) {
    const confirmDelete = confirm(
      "Are you sure you want to delete " + point.name + "?"
    );

    if (!confirmDelete) {
      return;
    }

    try {
      await deleteRecyclingPoint(point.id);
      alert("Recycling point deleted.");

      if (selectedPoint && selectedPoint.id === point.id) {
        resetForm();
      }

      await loadPoints();
    } catch (error) {
      console.error("Error deleting recycling point:", error);
      alert("Failed to delete recycling point.");
    }
  }

  async function handleResolveReport(report) {
    const confirmResolve = confirm(
      "Mark report " + report.reportCode + " as resolved?"
    );

    if (!confirmResolve) {
      return;
    }

    try {
      const reportRef = doc(db, "location_reports", report.id);

      await updateDoc(reportRef, {
        status: "Resolved",
        resolvedAt: serverTimestamp(),
      });

      alert("Location report resolved.");
      await loadLocationReports();
    } catch (error) {
      console.error("Error resolving location report:", error);
      alert("Failed to resolve location report.");
    }
  }

  function getStatusClass(status) {
    if (status === "Open") {
      return "map-status-open";
    }

    if (status === "Closed") {
      return "map-status-closed";
    }

    if (status === "Resolved") {
      return "map-status-open";
    }

    return "map-status-unknown";
  }

  function getRecyclingStatusClass(status) {
    if (status === "Not Accepting Items") {
      return "map-status-closed";
    }

    return "map-status-open";
  }

  function getNextPointCodePreview() {
    let biggestNumber = 0;

    points.forEach((point) => {
      const code = point.pointCode || "";
      const numberOnly = code.replace("RP", "");
      const number = parseInt(numberOnly);

      if (!isNaN(number) && number > biggestNumber) {
        biggestNumber = number;
      }
    });

    const nextNumber = biggestNumber + 1;
    return "RP" + String(nextNumber).padStart(2, "0");
  }

  function formatDate(timestamp) {
    if (!timestamp) {
      return "-";
    }

    const date = timestamp.toDate();
    return date.toLocaleString();
  }

  const totalPoints = points.length;
  const openPoints = points.filter((point) => getCurrentPointStatus(point, now) === "Open").length;
  const closedPoints = points.filter((point) => getCurrentPointStatus(point, now) === "Closed").length;
  const cyberjayaPoints = points.filter(
    (point) => point.area.toLowerCase() === "cyberjaya"
  ).length;

  const openReports = reports.filter((report) => report.status === "Open").length;
  const resolvedReports = reports.filter(
    (report) => report.status === "Resolved"
  ).length;

  return (
    <div className="map-page">
      <h1>Map</h1>
      <p className="page-subtitle">
        Manage recycling points and user location reports.
      </p>

      <div className="map-report-grid small-report-grid">
        <div className="map-report-card">
          <p>Total Points</p>
          <h2>{totalPoints}</h2>
        </div>

        <div className="map-report-card">
          <p>Open Points</p>
          <h2>{openPoints}</h2>
        </div>

        <div className="map-report-card">
          <p>Closed Points</p>
          <h2>{closedPoints}</h2>
        </div>

        <div className="map-report-divider"></div>

        <div className="map-report-card">
          <p>Total Reports</p>
          <h2>{reports.length}</h2>
        </div>

        <div className="map-report-card">
          <p>Open Reports</p>
          <h2>{openReports}</h2>
        </div>

        <div className="map-report-card">
          <p>Resolved</p>
          <h2>{resolvedReports}</h2>
        </div>
      </div>

      <div className="map-two-column">
        <div className="map-card">
          <h2>
            {selectedPoint ? "Edit Recycling Point" : "Add Recycling Point"}
          </h2>

          <form onSubmit={handleSubmit}>

            <div className="map-form-group">
              <label>Name</label>
              <input
                type="text"
                name="name"
                value={form.name}
                onChange={handleChange}
              />
            </div>

            <div className="map-form-group">
              <label>Address</label>
              <textarea
                name="address"
                value={form.address}
                onChange={handleChange}
                rows="3"
              />
            </div>

            <div className="map-form-row">
              <div className="map-form-group">
                <label>Latitude</label>
                <input
                  type="number"
                  step="any"
                  name="latitude"
                  value={form.latitude}
                  onChange={handleChange}
                />
              </div>

              <div className="map-form-group">
                <label>Longitude</label>
                <input
                  type="number"
                  step="any"
                  name="longitude"
                  value={form.longitude}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div className="map-form-row">
              <div className="map-form-group">
                <label>Contact</label>
                <input
                  type="text"
                  name="contact"
                  value={form.contact}
                  onChange={handleChange}
                />
              </div>

              <div className="map-form-group">
                <label>Area</label>
                <input
                  type="text"
                  name="area"
                  value={form.area}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div className="map-form-group">
              <label>Recycling Status</label>
              <select
                name="recyclingStatus"
                value={form.recyclingStatus}
                onChange={handleChange}
              >
                <option value="Accepting Items">Accepting Items</option>
                <option value="Not Accepting Items">Not Accepting Items</option>
              </select>
            </div>

            <div className="map-form-group">
              <label>Display Hours</label>
              <textarea
                name="hours"
                value={form.hours}
                onChange={handleChange}
                rows="3"
              />
            </div>

            <div className="map-form-group">
              <label>Accepted Types</label>

              <div className="map-checkbox-grid">
                {acceptedTypeOptions.map((type) => (
                  <label className="map-checkbox-item" key={type}>
                    <input
                      type="checkbox"
                      value={type}
                      checked={form.types.includes(type)}
                      onChange={handleTypeChange}
                    />
                    <span>{type}</span>
                  </label>
                ))}
              </div>
            </div>

            <h3 className="map-section-title">Opening Hours</h3>

            <div className="map-form-row">
              <div className="map-form-group">
                <input
                  type="text"
                  name="monday"
                  value={form.monday}
                  onChange={handleChange}
                  placeholder="Monday"
                />
              </div>

              <div className="map-form-group">
                <input
                  type="text"
                  name="tuesday"
                  value={form.tuesday}
                  onChange={handleChange}
                  placeholder="Tuesday"
                />
              </div>
            </div>

            <div className="map-form-row">
              <div className="map-form-group">
                <input
                  type="text"
                  name="wednesday"
                  value={form.wednesday}
                  onChange={handleChange}
                  placeholder="Wednesday"
                />
              </div>

              <div className="map-form-group">
                <input
                  type="text"
                  name="thursday"
                  value={form.thursday}
                  onChange={handleChange}
                  placeholder="Thursday"
                />
              </div>
            </div>

            <div className="map-form-row">
              <div className="map-form-group">
                <input
                  type="text"
                  name="friday"
                  value={form.friday}
                  onChange={handleChange}
                  placeholder="Friday"
                />
              </div>

              <div className="map-form-group">
                <input
                  type="text"
                  name="saturday"
                  value={form.saturday}
                  onChange={handleChange}
                  placeholder="Saturday"
                />
              </div>
            </div>

            <div className="map-form-group">
              <input
                type="text"
                name="sunday"
                value={form.sunday}
                onChange={handleChange}
                placeholder="Sunday"
              />
            </div>

            <div className="map-button-row">
              <button className="map-primary-btn" type="submit" disabled={saving}>
                {saving
                  ? "Saving..."
                  : selectedPoint
                    ? "Update Point"
                    : "+ Add Point"}
              </button>
            </div>
          </form>
        </div>

        <div>
          <div className="map-card">
            <div className="map-list-title-row">
              <h2>Recycling Points</h2>

              <button
                className="map-primary-btn"
                type="button"
                onClick={resetForm}
              >
                Create New Point
              </button>
            </div>

            {loading ? (
              <p>Loading recycling points...</p>
            ) : (
              <div className="map-table-scroll">
                <table className="map-table">
                  <thead>
                    <tr>
                      <th>Point</th>
                      <th>Status</th>
                      <th>Area</th>
                      <th>Action</th>
                    </tr>
                  </thead>

                  <tbody>
                    {points.length === 0 ? (
                      <tr>
                        <td colSpan="4">No recycling point found.</td>
                      </tr>
                    ) : (
                      points.map((point) => {
                        const currentStatus = getCurrentPointStatus(point, now);

                        return (
                          <tr key={point.id}>
                            <td>
                              <strong>{point.getDisplayName()}</strong>
                              <br />
                              <small>{point.address}</small>
                              <br />
                              <small>Types: {point.getTypeText()}</small>
                            </td>

                            <td>
                              <span className={getStatusClass(currentStatus)}>
                                {currentStatus}
                              </span>

                              <br />
                              <br />

                              <span className={getRecyclingStatusClass(point.recyclingStatus)}>
                                {point.recyclingStatus || "Accepting Items"}
                              </span>
                            </td>

                            <td>{point.area}</td>

                            <td>
                              <div className="map-action-buttons">
                                <button
                                  className="map-edit-btn"
                                  type="button"
                                  onClick={() => handleEdit(point)}
                                >
                                  Edit
                                </button>

                                <button
                                  className="map-delete-btn"
                                  type="button"
                                  onClick={() => handleDelete(point)}
                                >
                                  Delete
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          <div className="map-card" style={{ marginTop: "24px" }}>
            <h2>User Location Reports</h2>

            {reportLoading ? (
              <p>Loading location reports...</p>
            ) : (
              <div className="map-table-scroll">
                <table className="map-table">
                  <thead>
                    <tr>
                      <th>Report</th>
                      <th>User</th>
                      <th>Point</th>
                      <th>Issue</th>
                      <th>Status</th>
                      <th>Action</th>
                    </tr>
                  </thead>

                  <tbody>
                    {reports.length === 0 ? (
                      <tr>
                        <td colSpan="6">No location report found.</td>
                      </tr>
                    ) : (
                      reports.map((report) => (
                        <tr key={report.id}>
                          <td>
                            <strong>{report.reportCode}</strong>
                            <br />
                            <small>{formatDate(report.createdAt)}</small>
                          </td>

                          <td>
                            <strong>{report.userName || report.username}</strong>
                            <br />
                            <small>{report.userNo}</small>
                          </td>

                          <td>
                            <strong>
                              {report.recyclingPointCode} -{" "}
                              {report.recyclingPointName}
                            </strong>
                          </td>

                          <td>
                            <strong>{report.issueType}</strong>
                            <br />
                            <small>{report.description}</small>
                          </td>

                          <td>
                            <span className={getStatusClass(report.status)}>
                              {report.status}
                            </span>
                          </td>

                          <td>
                            {report.status === "Resolved" ? (
                              <span>-</span>
                            ) : (
                              <button
                                className="map-edit-btn"
                                type="button"
                                onClick={() => handleResolveReport(report)}
                              >
                                Resolve
                              </button>
                            )}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default MapPage;