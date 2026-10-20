// Supabase's API caps every response at 1000 rows by default, and it does
// so silently — no error, just a short result. Any query that loads a whole
// growing table (devices, sale_items, ...) has to page through it, or the
// app quietly drops whatever's past row 1000 (this is how ~100 newly added
// iPhone 13s went "missing" from All Devices once inventory passed 1000).
//
// buildQuery must return a FRESH query builder each call — builders are
// single-use. "id" is appended as the last sort key so pages are stable:
// without a deterministic order, rows can repeat or be skipped between pages.
const PAGE_SIZE = 1000;

export async function fetchAll(buildQuery) {
  const rows = [];
  for (let from = 0; ; from += PAGE_SIZE) {
    const { data, error } = await buildQuery()
      .order("id")
      .range(from, from + PAGE_SIZE - 1);
    if (error) throw error;
    rows.push(...data);
    if (data.length < PAGE_SIZE) return rows;
  }
}
