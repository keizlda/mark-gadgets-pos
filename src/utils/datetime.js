// Local (not UTC) today as YYYY-MM-DD, for defaulting date inputs. Using
// Date#toISOString() here would report yesterday's date for several hours
// every night in Manila (UTC+8) once local time passes midnight but UTC
// hasn't yet — the exact bug that made Add Device's date default stick to
// the previous day into the early morning.
export function todayLocalDateString() {
  const d = new Date();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${d.getFullYear()}-${mm}-${dd}`;
}

export function formatDate(isoString) {
  return new Date(isoString).toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

export function formatTime(isoString) {
  return new Date(isoString).toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
}
