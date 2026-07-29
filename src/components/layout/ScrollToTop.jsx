import { useEffect } from "react";
import { useLocation } from "react-router-dom";

// React Router doesn't reset scroll position on navigation by default — if
// the previous page was scrolled down, the next page can render already
// scrolled, cutting off its own top content until the user scrolls back up
// manually. Renders nothing; just resets scroll on every route change.
function ScrollToTop() {
  const { pathname } = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);

  return null;
}

export default ScrollToTop;
