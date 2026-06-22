import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import AdminRoute from "./guards/AdminRoute";
import AdminLayout from "./layouts/AdminLayout";

import LoginPage from "./pages/LoginPage";
import DashboardPage from "./pages/DashboardPage";
import CommunityPage from "./pages/CommunityPage";
import MapPage from "./pages/MapPage";
import PickupRequestPage from "./pages/PickupRequestPage";
import SupportPage from "./pages/SupportPage";

import "./styles/admin.css";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />

        <Route element={<AdminRoute />}>
          <Route path="/" element={<AdminLayout />}>
            <Route index element={<Navigate to="/dashboard" />} />

            <Route path="dashboard" element={<DashboardPage />} />
            <Route path="community" element={<CommunityPage />} />
            <Route path="map" element={<MapPage />} />
            <Route path="pickup-request" element={<PickupRequestPage />} />
            <Route path="support" element={<SupportPage />} />

            <Route path="view-data" element={<Navigate to="/dashboard" />} />
            <Route path="view-community" element={<Navigate to="/community" />} />
            <Route path="view-map" element={<Navigate to="/map" />} />
            <Route path="view-request" element={<Navigate to="/pickup-request" />} />
          </Route>
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;