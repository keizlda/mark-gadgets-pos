import { useState, useEffect } from "react";
import { Navigate } from "react-router-dom";
import { getCurrentProfile } from "../../services/authService";

// The first admin-only route in the app — bounces non-admins back to the
// dashboard rather than letting them see supplier payment amounts.
function RequireAdmin({ children }) {
  const [profile, setProfile] = useState(undefined); // undefined = still checking

  useEffect(() => {
    getCurrentProfile().then(setProfile);
  }, []);

  if (profile === undefined) {
    return null;
  }

  if (profile?.role !== "admin") {
    return <Navigate to="/dashboard" replace />;
  }

  return children;
}

export default RequireAdmin;
