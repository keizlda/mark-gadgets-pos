// Matches when every whitespace-separated word in the query appears
// somewhere in the text — order-independent, so "12 iphone" and
// "iphone 12" match the same things. Also means a trailing/extra space
// while still typing (e.g. "iphone 12 ") doesn't accidentally exclude a
// shorter match like plain "iPhone 12" just because "iPhone 12 Pro Max"
// also matches — a plain substring check would treat that trailing space
// as a literal character the shorter name doesn't contain.
export function matchesQuery(text, query) {
  if (!query || !query.trim()) return true;
  const words = query.trim().toLowerCase().split(/\s+/);
  const haystack = (text || "").toLowerCase();
  return words.every((word) => haystack.includes(word));
}
