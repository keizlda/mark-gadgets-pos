import { supabase } from "../lib/supabaseClient";

export async function getExpenses() {
  const { data, error } = await supabase
    .from("expenses")
    .select("id, expense_date, description, amount")
    .order("expense_date", { ascending: false });

  if (error) throw error;

  return data.map((e) => ({
    id: e.id,
    date: e.expense_date,
    description: e.description,
    amount: e.amount,
  }));
}

export async function addExpense({ date, description, amount }) {
  const { error } = await supabase.from("expenses").insert({
    expense_date: date,
    description,
    amount,
  });
  if (error) throw error;
}

export async function deleteExpense(id) {
  const { error } = await supabase.from("expenses").delete().eq("id", id);
  if (error) throw error;
}
