import { useState } from "react";
import { useNavigate } from "react-router-dom";

import { loginAdmin } from "../services/authService";

function LoginPage() {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleLogin(event) {
    event.preventDefault();

    if (!email || !password) {
      setMessage("Please enter email and password.");
      return;
    }

    try {
      setLoading(true);
      setMessage("");

      await loginAdmin(email, password);

      navigate("/dashboard");
    } catch (error) {
      console.log(error);
      setMessage("Login failed: " + error.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="login-page">
      <form className="login-card" onSubmit={handleLogin}>
        <h1>SortSnap</h1>
        <p>Admin Portal Login</p>

        {message && <div className="message-box">{message}</div>}

        <label>Email</label>
        <input
          type="email"
          placeholder="Enter admin email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
        />

        <label>Password</label>
        <input
          type="password"
          placeholder="Enter admin password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
        />

        <button className="primary-btn login-btn" type="submit">
          {loading ? "Logging in..." : "Login"}
        </button>
      </form>
    </div>
  );
}

export default LoginPage;