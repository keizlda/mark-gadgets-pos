import { supabase, setRememberMe } from "../lib/supabaseClient";

export async function signIn(email, password, remember = true) {
  setRememberMe(remember);
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) throw error;
  return data;
}

export async function signOut() {
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
}

export async function getSession() {
  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;
  return data.session;
}

// Calls `callback(session)` immediately and on every future auth change.
// Returns an unsubscribe function for effect cleanup.
export function onAuthStateChange(callback) {
  const {
    data: { subscription },
  } = supabase.auth.onAuthStateChange((_event, session) => {
    callback(session);
  });
  return () => subscription.unsubscribe();
}
