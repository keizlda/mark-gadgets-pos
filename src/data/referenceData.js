// Static reference constants — mirror fixed schema CHECK constraints and
// UI-only lookup lists rather than dynamic business data, so they don't come
// from Supabase. Business records live in the database; see src/services/.

export const deviceCategories = ["iPhones", "iPads", "Apple Watches", "MacBooks"];
export const deviceStorages = ["64GB", "128GB", "256GB", "512GB", "1TB"];

// Colors are keyed per model (not per category) since each generation/tier
// ships its own real Apple color lineup — e.g. iPhone 15 Pro only comes in
// titanium finishes while iPhone 15 comes in gloss colors.
const iPhoneModelColors = {
  "iPhone XR": ["Black", "White", "Blue", "Coral", "Yellow", "(Product)Red"],
  "iPhone 11": ["Black", "Green", "Yellow", "Purple", "White", "(Product)Red"],
  "iPhone 11 Pro": ["Midnight Green", "Space Gray", "Silver", "Gold"],
  "iPhone 11 Pro Max": ["Midnight Green", "Space Gray", "Silver", "Gold"],
  "iPhone 12 mini": ["Black", "White", "(Product)Red", "Green", "Blue", "Purple"],
  "iPhone 12": ["Black", "White", "(Product)Red", "Green", "Blue", "Purple"],
  "iPhone 12 Pro": ["Graphite", "Silver", "Gold", "Pacific Blue"],
  "iPhone 12 Pro Max": ["Graphite", "Silver", "Gold", "Pacific Blue"],
  "iPhone 13 mini": ["Pink", "Blue", "Midnight", "Starlight", "(Product)Red", "Green"],
  "iPhone 13": ["Pink", "Blue", "Midnight", "Starlight", "(Product)Red", "Green"],
  "iPhone 13 Pro": ["Graphite", "Gold", "Silver", "Sierra Blue", "Alpine Green"],
  "iPhone 13 Pro Max": ["Graphite", "Gold", "Silver", "Sierra Blue", "Alpine Green"],
  "iPhone 14": ["Midnight", "Starlight", "(Product)Red", "Blue", "Purple", "Yellow"],
  "iPhone 14 Plus": ["Midnight", "Starlight", "(Product)Red", "Blue", "Purple", "Yellow"],
  "iPhone 14 Pro": ["Space Black", "Silver", "Gold", "Deep Purple"],
  "iPhone 14 Pro Max": ["Space Black", "Silver", "Gold", "Deep Purple"],
  "iPhone 15": ["Black", "Blue", "Green", "Yellow", "Pink"],
  "iPhone 15 Plus": ["Black", "Blue", "Green", "Yellow", "Pink"],
  "iPhone 15 Pro": ["Black Titanium", "White Titanium", "Blue Titanium", "Natural Titanium"],
  "iPhone 15 Pro Max": ["Black Titanium", "White Titanium", "Blue Titanium", "Natural Titanium"],
  "iPhone 16": ["Black", "White", "Pink", "Teal", "Ultramarine"],
  "iPhone 16 Plus": ["Black", "White", "Pink", "Teal", "Ultramarine"],
  "iPhone 16 Pro": ["Black Titanium", "White Titanium", "Natural Titanium", "Desert Titanium"],
  "iPhone 16 Pro Max": ["Black Titanium", "White Titanium", "Natural Titanium", "Desert Titanium"],
  "iPhone 16e": ["Black", "White"],
  "iPhone 17": ["Black", "White", "Lavender", "Sage", "Mist Blue"],
  "iPhone Air": ["Space Black", "Cloud White", "Sky Blue", "Light Gold"],
  "iPhone 17 Pro": ["Silver", "Cosmic Orange", "Deep Blue"],
  "iPhone 17 Pro Max": ["Silver", "Cosmic Orange", "Deep Blue"],
};

const iPadModelColors = {
  "iPad Pro M4": ["Space Black", "Silver"],
  "iPad Air 6": ["Space Gray", "Blue", "Purple", "Starlight"],
  "iPad 10th Gen": ["Blue", "Pink", "Yellow", "Silver"],
};

const appleWatchModelColors = {
  "Apple Watch Series 9": ["Midnight", "Starlight", "Silver", "Pink", "(Product)Red"],
  "Apple Watch Ultra 2": ["Natural Titanium"],
  "Apple Watch SE": ["Midnight", "Starlight", "Silver"],
};

const macBookModelColors = {
  "MacBook Air M4": ["Sky Blue", "Silver", "Starlight", "Midnight"],
  "MacBook Air M3": ["Midnight", "Starlight", "Space Gray", "Silver"],
  'MacBook Pro 14" M4': ["Space Black", "Silver"],
  'MacBook Pro 16" M4': ["Space Black", "Silver"],
};

export const productCatalog = {
  iPhone: {
    brand: "Apple",
    models: Object.keys(iPhoneModelColors),
    modelColors: iPhoneModelColors,
    storages: ["128GB", "256GB", "512GB", "1TB"],
  },
  iPad: {
    brand: "Apple",
    models: Object.keys(iPadModelColors),
    modelColors: iPadModelColors,
    storages: ["64GB", "128GB", "256GB", "512GB"],
  },
  "Apple Watch": {
    brand: "Apple",
    models: Object.keys(appleWatchModelColors),
    modelColors: appleWatchModelColors,
    storages: ["-"],
  },
  MacBook: {
    brand: "Apple",
    models: Object.keys(macBookModelColors),
    modelColors: macBookModelColors,
    storages: ["256GB", "512GB", "1TB", "2TB"],
  },
};

export const posCategories = ["All Categories", "iPhones", "iPads", "MacBooks", "Apple Watches", "Accessories"];

export const paymentMethods = ["Cash", "GCash", "Credit Card", "Bank Transfer", "Check"];

export const returnReasons = [
  "Defective Unit",
  "Changed Mind",
  "Not as Described",
  "Not Compatible",
  "Wrong Item Ordered",
];

export const returnTypes = [
  "Defective Unit",
  "Changed Mind",
  "Not as Described",
  "Not Compatible",
];
