// Everything date/time in the app is pinned to the store's own time zone,
// never the viewing device's. Dates used to follow each device's clock
// setting, so the owner opening the app on a laptop set to another time
// zone saw evening sales land on the wrong day and the Daily report cover
// the wrong hours. The Philippines has no DST, so a fixed +08:00 is exact.
export const STORE_TIME_ZONE = "Asia/Manila";
const STORE_UTC_OFFSET = "+08:00";

// { year, month, day, hour, minute } of an instant, as seen in Manila.
function storeParts(date) {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: STORE_TIME_ZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);
  const get = (type) => Number(parts.find((p) => p.type === type).value);
  return { year: get("year"), month: get("month"), day: get("day"), hour: get("hour"), minute: get("minute") };
}

const pad = (n) => String(n).padStart(2, "0");

// Manila "YYYY-MM-DD" for an instant (defaults to now).
export function toStoreDateString(date = new Date()) {
  const p = storeParts(date);
  return `${p.year}-${pad(p.month)}-${pad(p.day)}`;
}

// Today in Manila as YYYY-MM-DD, for defaulting date inputs.
export function todayLocalDateString() {
  return toStoreDateString();
}

// Today's Manila calendar date as a plain local-midnight Date — for code
// that does calendar arithmetic ("6 days ago", "first of the month") and
// then reads it back with getFullYear/getMonth/getDate. The arithmetic is
// calendar-only, so it doesn't matter that the Date sits at the device's
// midnight; what matters is that it starts from Manila's date.
export function storeToday() {
  const p = storeParts(new Date());
  return new Date(p.year, p.month - 1, p.day);
}

// MMDDYY- prefix for batch codes, from Manila's date.
export function batchCodeDatePrefix() {
  const p = storeParts(new Date());
  return `${pad(p.month)}${pad(p.day)}${String(p.year).slice(-2)}-`;
}

// "YYYY-MM-DD" or "YYYY-MM-DDTHH:mm" typed into a date/datetime-local
// input, read as Manila wall-clock time — never the device's.
export function fromStoreDateTime(value) {
  const withTime = value.includes("T") ? value : `${value}T00:00`;
  return new Date(`${withTime.length === 16 ? withTime + ":00" : withTime}${STORE_UTC_OFFSET}`);
}

export function formatDate(isoString) {
  return new Date(isoString).toLocaleDateString("en-US", {
    timeZone: STORE_TIME_ZONE,
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

// Manila "YYYY-MM-DDTHH:mm" for prefilling <input type="datetime-local">.
export function toDatetimeLocalString(isoString) {
  const p = storeParts(new Date(isoString));
  return `${p.year}-${pad(p.month)}-${pad(p.day)}T${pad(p.hour)}:${pad(p.minute)}`;
}

export function formatTime(isoString) {
  return new Date(isoString).toLocaleTimeString("en-US", {
    timeZone: STORE_TIME_ZONE,
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
}
