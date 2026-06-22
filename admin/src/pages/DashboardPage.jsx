function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      <p className="page-subtitle">Overview of SortSnap admin portal.</p>

      <div className="dashboard-grid">
        <div className="stat-card">
          <h3>Total Users</h3>
          <p>0</p>
        </div>

        <div className="stat-card">
          <h3>Pickup Requests</h3>
          <p>0</p>
        </div>

        <div className="stat-card">
          <h3>Recycling Points</h3>
          <p>0</p>
        </div>

        <div className="stat-card">
          <h3>Location Reports</h3>
          <p>0</p>
        </div>
      </div>

      <div className="card">
        <h2>Admin Notes</h2>
        <p>
          This admin portal will be connected to the same Firebase Firestore used
          by the Flutter mobile app.
        </p>
      </div>
    </div>
  );
}

export default DashboardPage;