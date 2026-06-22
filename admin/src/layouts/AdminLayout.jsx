import { NavLink, Outlet, useNavigate } from "react-router-dom";

import { logoutAdmin } from "../services/authService";

function AdminLayout() {
  const navigate = useNavigate();

  async function handleLogout() {
    await logoutAdmin();
    navigate("/login");
  }

  return (
    <div className="admin-container">
      <aside className="sidebar">
        <div className="logo-box">
          <h2>SortSnap</h2>
          <p>Admin Portal</p>
        </div>

        <nav className="side-menu">
          <NavLink
            to="/dashboard"
            className={({ isActive }) =>
              isActive ? "menu-link active" : "menu-link"
            }
          >
            <span>▦</span>

            <div>
              <p>Dashboard</p>
            </div>
          </NavLink>

          <NavLink
            to="/community"
            className={({ isActive }) =>
              isActive ? "menu-link active" : "menu-link"
            }
          >
            <span>◎</span>

            <div>
              <p>Community</p>
            </div>
          </NavLink>

          <NavLink
            to="/map"
            className={({ isActive }) =>
              isActive ? "menu-link active" : "menu-link"
            }
          >
            <span>⌖</span>

            <div>
              <p>Map</p>
            </div>
          </NavLink>

          <NavLink
            to="/pickup-request"
            className={({ isActive }) =>
              isActive ? "menu-link active" : "menu-link"
            }
          >
            <span>⇄</span>

            <div>
              <p>Pickup Request</p>
            </div>
          </NavLink>

          <NavLink
            to="/support"
            className={({ isActive }) =>
              isActive ? "menu-link active" : "menu-link"
            }
          >
            <span>?</span>

            <div>
              <p>Support</p>
            </div>
          </NavLink>
        </nav>

        <div className="logout-box">
          <button onClick={handleLogout}>Logout</button>
        </div>
      </aside>

      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
}

export default AdminLayout;