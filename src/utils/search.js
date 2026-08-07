// Shorthand resellers actually type for phone model suffixes, expanded to
// the words that appear in the real model name before matching.
const ABBREVIATIONS = {
  pm: "pro max",
  promax: "pro max",
};

// Expands staff shorthand into the words it stands for, so "15pm",
// "15 pm", and "15promax" all resolve to the same "15 pro max" that
// matches "iPhone 15 Pro Max". Also splits glued number/letter runs like
// "iphone12" into "iphone 12" so an un-spaced search still matches, and
// turns "14+" into "14 plus".
function expandAbbreviations(query) {
  return query
    .replace(/\+/g, " plus ")
    .replace(/(\d)([a-z])/gi, "$1 $2")
    .replace(/([a-z])(\d)/gi, "$1 $2")
    .split(/\s+/)
    .filter(Boolean)
    .map((word) => ABBREVIATIONS[word] || word)
    .join(" ");
}

// Matches when every whitespace-separated word in the query appears
// somewhere in the text — order-independent, so "12 iphone" and
// "iphone 12" match the same things. Also means a trailing/extra space
// while still typing (e.g. "iphone 12 ") doesn't accidentally exclude a
// shorter match like plain "iPhone 12" just because "iPhone 12 Pro Max"
// also matches — a plain substring check would treat that trailing space
// as a literal character the shorter name doesn't contain.
export function matchesQuery(text, query) {
  if (!query || !query.trim()) return true;
  const expanded = expandAbbreviations(query.trim().toLowerCase());
  const words = expanded.split(/\s+/).filter(Boolean);
  const haystack = (text || "").toLowerCase();
  return words.every((word) => haystack.includes(word));
}
