import {
  deviceCategories,
  deviceStorages,
  productCatalog,
  paymentMethods,
  posCategories,
  returnReasons,
  returnTypes,
} from "../data/referenceData";
import { supabase } from "../lib/supabaseClient";

export async function getDeviceCategories() {
  return deviceCategories;
}

export async function getDeviceStorages() {
  return deviceStorages;
}

export async function getProductCatalog() {
  return productCatalog;
}

export async function getSuppliers() {
  const { data, error } = await supabase.from("suppliers").select("name").order("name");
  if (error) throw error;
  return data.map((s) => s.name);
}

export async function addSupplier({ name, contactInfo }) {
  const { error } = await supabase.from("suppliers").insert({
    name,
    contact_info: contactInfo || null,
  });
  if (error) throw error;
}

export async function getSalespersons() {
  const { data, error } = await supabase.from("profiles").select("name").order("name");
  if (error) throw error;
  return data.map((p) => p.name);
}

export async function getPaymentMethods() {
  return paymentMethods;
}

export async function getPosCategories() {
  return posCategories;
}

export async function getReturnReasons() {
  return returnReasons;
}

export async function getReturnTypes() {
  return returnTypes;
}
