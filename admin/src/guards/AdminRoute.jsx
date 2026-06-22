import { useEffect, useState } from "react";
import { Navigate, Outlet } from "react-router-dom";
import { onAuthStateChanged } from "firebase/auth";

import { auth } from "../firebase/firebase";

function AdminRoute() {
  const [currentUser, setCurrentUser] = useState(null);
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setCurrentUser(user);
      setChecking(false);
    });

    return () => unsubscribe();
  }, []);

  if (checking) {
    return (
      <div className="login-page">
        <div className="login-card">
          <h2>Checking login...</h2>
        </div>
      </div>
    );
  }

  if (!currentUser) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}

export default AdminRoute;