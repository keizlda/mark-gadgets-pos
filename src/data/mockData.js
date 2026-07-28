export const statCards = [
  { label: "Available", value: 182, unit: "Units", color: "green" },
  { label: "Sold Today", value: 8, unit: "Units", color: "blue" },
  { label: "Low Stock", value: 4, unit: "Models", color: "orange" },
  { label: "Supplier Defective", value: 2, unit: "Units", color: "red" },
  { label: "Returned", value: 1, unit: "Unit", color: "purple" },
];

export const salesThisMonth = [
  { month: "Jan", sales: 500000 },
  { month: "Feb", sales: 900000 },
  { month: "Mar", sales: 1100000 },
  { month: "Apr", sales: 1300000 },
  { month: "May", sales: 1550000 },
  { month: "Jun", sales: 1700000 },
  { month: "Jul", sales: 1845600 },
];

export const inventoryByCategory = [
  { name: "iPhones", value: 118, percent: 58.4, color: "#3b82f6" },
  { name: "iPads", value: 28, percent: 13.9, color: "#22c55e" },
  { name: "Apple Watches", value: 20, percent: 9.9, color: "#f97316" },
  { name: "MacBooks", value: 36, percent: 17.8, color: "#a855f7" },
];

export const lowStockAlerts = [
  { name: "iPhone 15 Pro 128GB", variant: "Black Titanium", left: 2 },
  { name: "Apple Watch Series 9", variant: "45mm Midnight", left: 1 },
  { name: "MacBook Air M3", variant: "256GB Silver", left: 2 },
];

export const recentActivity = [
  {
    batchCode: "070926-031",
    device: "iPhone 16 Pro",
    storage: "256GB",
    color: "Natural Titanium",
    status: "Sold",
    customer: "Juan Dela Cruz",
    phone: "0917 123 4567",
    time: "10:15 AM",
  },
  {
    batchCode: "070926-028",
    device: "iPhone 16 Pro Max",
    storage: "512GB",
    color: "Desert Titanium",
    status: "Reserved",
    customer: "Mark Santos",
    phone: "0998 765 4321",
    time: "9:42 AM",
  },
  {
    batchCode: "070926-014",
    device: "MacBook Air M4",
    storage: "512GB",
    color: "Silver",
    status: "Available",
    customer: "",
    phone: "",
    time: "9:18 AM",
  },
  {
    batchCode: "070926-006",
    device: "iPhone 15 Pro",
    storage: "256GB",
    color: "Blue Titanium",
    status: "Customer Returned",
    customer: "Ana Cruz",
    phone: "0921 456 7890",
    time: "Yesterday",
  },
  {
    batchCode: "070926-002",
    device: "iPhone 16",
    storage: "128GB",
    color: "Black",
    status: "Supplier Defective",
    customer: "",
    phone: "",
    time: "Yesterday",
  },
];

export const deviceCategories = ["iPhones", "iPads", "Apple Watches", "MacBooks"];
export const deviceStorages = ["64GB", "128GB", "256GB", "512GB", "1TB"];
export const deviceColors = [
  "Natural Titanium", "Desert Titanium", "Blue Titanium", "Black Titanium",
  "White Titanium", "Black", "Silver", "Space Black", "Space Gray",
  "Midnight", "Pink", "Blue",
];

export const allDevices = [
  { batchCode: "070926-031", device: "iPhone 16 Pro", category: "iPhones", storage: "256GB", color: "Natural Titanium", serial: "F7T93X2L7J", status: "Sold", dateAdded: "Jul 9, 2026", time: "10:15 AM" },
  { batchCode: "070926-028", device: "iPhone 16 Pro Max", category: "iPhones", storage: "512GB", color: "Desert Titanium", serial: "G6VJ89K2PQ", status: "Reserved", dateAdded: "Jul 9, 2026", time: "9:42 AM" },
  { batchCode: "070926-014", device: "MacBook Air M4", category: "MacBooks", storage: "512GB", color: "Silver", serial: "C02XK0YH7L2", status: "Available", dateAdded: "Jul 9, 2026", time: "9:18 AM" },
  { batchCode: "070926-006", device: "iPhone 15 Pro", category: "iPhones", storage: "256GB", color: "Blue Titanium", serial: "DNPXJ6F72K", status: "Customer Returned", dateAdded: "Jul 8, 2026", time: "4:30 PM" },
  { batchCode: "070926-002", device: "iPhone 16", category: "iPhones", storage: "128GB", color: "Black", serial: "K2L9M8N6PP", status: "Supplier Defective", dateAdded: "Jul 8, 2026", time: "2:11 PM" },
  { batchCode: "070926-025", device: "iPad Air 6", category: "iPads", storage: "256GB", color: "Space Gray", serial: "F9G3TJ2KLM", status: "Available", dateAdded: "Jul 8, 2026", time: "11:05 AM" },
  { batchCode: "070926-022", device: "Apple Watch Series 9 45mm", category: "Apple Watches", storage: "-", color: "Midnight", serial: "RX1Y2Y324A", status: "Available", dateAdded: "Jul 7, 2026", time: "5:20 PM" },
  { batchCode: "070926-019", device: 'MacBook Pro 14" M4', category: "MacBooks", storage: "1TB", color: "Space Black", serial: "C02XK0YH8FP", status: "Available", dateAdded: "Jul 7, 2026", time: "3:45 PM" },
  { batchCode: "070926-015", device: "iPhone 15", category: "iPhones", storage: "128GB", color: "Pink", serial: "G8T Y8YK9Q2", status: "Available", dateAdded: "Jul 6, 2026", time: "10:22 AM" },
  { batchCode: "070926-009", device: "iPad 10th Gen", category: "iPads", storage: "64GB", color: "Blue", serial: "K8L2M1N3PQ", status: "Returned", dateAdded: "Jul 6, 2026", time: "9:10 AM" },
  { batchCode: "070926-041", device: "iPad Pro M4", category: "iPads", storage: "256GB", color: "Space Black", serial: "F5H2K9L1MN", status: "Available", dateAdded: "Jul 5, 2026", time: "1:00 PM" },
  { batchCode: "070926-042", device: "Apple Watch Series 9 45mm", category: "Apple Watches", storage: "-", color: "Midnight", serial: "RX2Y3Y425B", status: "Available", dateAdded: "Jul 5, 2026", time: "12:20 PM" },
  { batchCode: "070926-043", device: "MacBook Air M3", category: "MacBooks", storage: "256GB", color: "Silver", serial: "C03XK1YH9L3", status: "Available", dateAdded: "Jul 4, 2026", time: "9:55 AM" },
  { batchCode: "070926-044", device: "iPhone 15 Pro", category: "iPhones", storage: "128GB", color: "Black Titanium", serial: "DNQXJ7F83L", status: "Supplier Defective", dateAdded: "Jul 4, 2026", time: "8:40 AM" },
  { batchCode: "070926-045", device: "iPhone 16 Pro", category: "iPhones", storage: "256GB", color: "White Titanium", serial: "F8T04X3M8K", status: "Reserved", dateAdded: "Jul 3, 2026", time: "4:15 PM" },
  { batchCode: "070926-046", device: "iPhone 16", category: "iPhones", storage: "256GB", color: "Black", serial: "K3L0M9O7QQ", status: "Sold", dateAdded: "Jul 3, 2026", time: "2:30 PM" },
  { batchCode: "070926-047", device: "MacBook Air M4", category: "MacBooks", storage: "256GB", color: "Silver", serial: "C04XK2YI0M4", status: "Available", dateAdded: "Jul 2, 2026", time: "11:15 AM" },
  { batchCode: "070926-048", device: "iPad Air 6", category: "iPads", storage: "128GB", color: "Blue", serial: "F0G4TK3MNO", status: "Available", dateAdded: "Jul 2, 2026", time: "10:00 AM" },
  { batchCode: "070926-049", device: "iPhone 15", category: "iPhones", storage: "256GB", color: "Pink", serial: "G9UZ9ZL0R3", status: "Sold", dateAdded: "Jul 1, 2026", time: "3:20 PM" },
  { batchCode: "070926-050", device: "Apple Watch Series 9 45mm", category: "Apple Watches", storage: "-", color: "Midnight", serial: "RY3Z4Z536C", status: "Available", dateAdded: "Jul 1, 2026", time: "1:45 PM" },
];

export const productCatalog = {
  iPhone: {
    brand: "Apple",
    models: ["iPhone 16 Pro", "iPhone 16 Pro Max", "iPhone 16", "iPhone 15 Pro", "iPhone 15"],
    colors: ["Natural Titanium", "Desert Titanium", "Blue Titanium", "Black Titanium", "White Titanium", "Black", "Pink"],
    storages: ["128 GB", "256 GB", "512 GB", "1 TB"],
  },
  iPad: {
    brand: "Apple",
    models: ["iPad Pro M4", "iPad Air 6", "iPad 10th Gen"],
    colors: ["Space Black", "Space Gray", "Silver", "Blue"],
    storages: ["64 GB", "128 GB", "256 GB", "512 GB"],
  },
  "Apple Watch": {
    brand: "Apple",
    models: ["Apple Watch Series 9", "Apple Watch Ultra 2", "Apple Watch SE"],
    colors: ["Midnight", "Starlight", "Silver"],
    storages: ["-"],
  },
  MacBook: {
    brand: "Apple",
    models: ['MacBook Air M4', 'MacBook Air M3', 'MacBook Pro 14" M4', 'MacBook Pro 16" M4'],
    colors: ["Silver", "Space Black", "Space Gray", "Midnight"],
    storages: ["256 GB", "512 GB", "1 TB", "2 TB"],
  },
};

export const suppliers = ["AJT Gadget", "PowerMac Center", "iStudio Philippines", "Beyond the Box"];

export const supplierDefectiveRecords = [
  {
    batchCode: "070926-002",
    device: "iPhone 16",
    storage: "128GB",
    color: "Black",
    serial: "K2L9M8N6PP",
    supplier: "Apple Authorized Distributor PH",
    dateDetected: "Jul 8, 2026",
    time: "2:11 PM",
    issue: "Volume button not working",
    status: "Pending Return",
    actionTaken: "-",
  },
  {
    batchCode: "070926-021",
    device: "Apple Watch Series 9",
    storage: "45mm",
    color: "Midnight",
    serial: "RX1X2Y3Z4A",
    supplier: "Apple Authorized Distributor PH",
    dateDetected: "Jul 7, 2026",
    time: "4:35 PM",
    issue: "Touch screen unresponsive",
    status: "Returned to Supplier",
    actionTaken: "Returned on Jul 8, 2026",
  },
  {
    batchCode: "070926-017",
    device: 'MacBook Pro 14" M4',
    storage: "1TB",
    color: "Space Black",
    serial: "C02XK0YJH8P",
    supplier: "Beyond the Box Solutions Inc.",
    dateDetected: "Jul 6, 2026",
    time: "11:20 AM",
    issue: "Keyboard backlight not working",
    status: "Resolved",
    actionTaken: "Replaced unit Jul 7, 2026",
  },
];

export const salespersons = ["Admin", "Jane Reyes", "Mark Cruz"];

export const reservedDevices = [
  { reservationId: "RES-2026-0716-0008", dateReserved: "Jul 16, 2026", time: "10:30 AM", customer: "Juan Dela Cruz", phone: "0917 123 4567", salesperson: "Admin", device: "iPhone 16 Pro", storage: "256GB", color: "Natural Titanium", serial: "F7T93X2L7J", reservedUntil: "Jul 23, 2026", daysLeft: 7, status: "Active", totalPrice: 68990 },
  { reservationId: "RES-2026-0716-0007", dateReserved: "Jul 16, 2026", time: "9:15 AM", customer: "Mark Santos", phone: "0998 765 4321", salesperson: "Admin", device: "iPhone 16 Pro Max", storage: "512GB", color: "Desert Titanium", serial: "G6VJ81K2PQ", reservedUntil: "Jul 20, 2026", daysLeft: 4, status: "Active", totalPrice: 78990 },
  { reservationId: "RES-2026-0715-0006", dateReserved: "Jul 15, 2026", time: "6:45 PM", customer: "Ana Cruz", phone: "0921 456 7890", salesperson: "Jane Reyes", device: "MacBook Air M4", storage: "512GB", color: "Silver", serial: "C02XK0YH7L2", reservedUntil: "Jul 22, 2026", daysLeft: 6, status: "Active", totalPrice: 64000 },
  { reservationId: "RES-2026-0715-0005", dateReserved: "Jul 15, 2026", time: "3:20 PM", customer: "Michael Lim", phone: "0915 234 5678", salesperson: "Admin", device: "iPhone 15 Pro", storage: "256GB", color: "Blue Titanium", serial: "DNPXJ6F72K", reservedUntil: "Jul 18, 2026", daysLeft: 2, status: "Expiring Soon", totalPrice: 58990 },
  { reservationId: "RES-2026-0714-0004", dateReserved: "Jul 14, 2026", time: "11:05 AM", customer: "Patricia Gomez", phone: "0906 789 1234", salesperson: "Jane Reyes", device: "Apple Watch Series 9", storage: "45mm", color: "Midnight", serial: "RX1X2Y3Z4A", reservedUntil: "Jul 17, 2026", daysLeft: 1, status: "Expiring Soon", totalPrice: 25990 },
  { reservationId: "RES-2026-0713-0003", dateReserved: "Jul 13, 2026", time: "4:30 PM", customer: "Roberto Tan", phone: "0918 123 2222", salesperson: "Admin", device: "iPhone 16", storage: "128GB", color: "Black", serial: "K2L9M8N6PP", reservedUntil: "Jul 16, 2026", daysLeft: 0, status: "Expiring Soon", totalPrice: 48990 },
  { reservationId: "RES-2026-0709-0002", dateReserved: "Jul 9, 2026", time: "2:10 PM", customer: "Kimberly Yu", phone: "0916 555 8888", salesperson: "Admin", device: "iPad Air 6", storage: "256GB", color: "Space Gray", serial: "F9G3TJ2KLM", reservedUntil: "Jul 12, 2026", daysLeft: -4, status: "Expired", totalPrice: 33990 },
  { reservationId: "RES-2026-0708-0001", dateReserved: "Jul 8, 2026", time: "10:45 AM", customer: "David Chen", phone: "0927 777 3333", salesperson: "Jane Reyes", device: 'MacBook Pro 14" M4', storage: "1TB", color: "Space Black", serial: "C02XK0YJH8P", reservedUntil: "Jul 11, 2026", daysLeft: -5, status: "Expired", totalPrice: 112800 },
];

export const lowStockItems = [
  { device: "iPhone 15 Pro 128GB", variant: "Black Titanium", category: "iPhones", storage: "256GB", available: 2, reorderLevel: 5, estimatedValue: 111980, lastUpdated: "Jul 16, 2026", time: "10:15 AM" },
  { device: "Apple Watch Series 9 45mm", variant: "Midnight", category: "Apple Watches", storage: "-", available: 1, reorderLevel: 3, estimatedValue: 25990, lastUpdated: "Jul 16, 2026", time: "9:42 AM" },
  { device: "MacBook Air M3", variant: "256GB Silver", category: "MacBooks", storage: "256GB", available: 2, reorderLevel: 4, estimatedValue: 98000, lastUpdated: "Jul 16, 2026", time: "9:18 AM" },
  { device: "iPad 10th Gen", variant: "Wi-Fi 64GB Blue", category: "iPads", storage: "64GB", available: 18, reorderLevel: 20, estimatedValue: 18530, lastUpdated: "Jul 16, 2026", time: "8:55 AM" },
];

export const posCategories = ["All Categories", "iPhones", "iPads", "MacBooks", "Apple Watches", "Accessories"];

export const posProducts = [
  { batchCode: "F7T93X2L7J", product: "iPhone 16 Pro", category: "iPhones", storage: "256GB", color: "Natural Titanium", available: 5, price: 68990 },
  { batchCode: "G6VJ81K2PQ", product: "iPhone 16 Pro Max", category: "iPhones", storage: "512GB", color: "Desert Titanium", available: 3, price: 78990 },
  { batchCode: "DNPXJ6F72K", product: "iPhone 15 Pro", category: "iPhones", storage: "256GB", color: "Blue Titanium", available: 4, price: 58990 },
  { batchCode: "K2L9M8N6PP", product: "iPhone 16", category: "iPhones", storage: "128GB", color: "Black", available: 7, price: 48990 },
  { batchCode: "K8L2M1N3PQ", product: "iPad 10th Gen Wi-Fi", category: "iPads", storage: "64GB", color: "Blue", available: 6, price: 18990 },
  { batchCode: "C02XK0YH7L2", product: "MacBook Air M4", category: "MacBooks", storage: "512GB", color: "Silver", available: 2, price: 64000 },
  { batchCode: "RX1X2Y3Z4A", product: "Apple Watch Series 9 45mm", category: "Apple Watches", storage: "-", color: "Midnight", available: 4, price: 25990 },
  { batchCode: "AP2GEN-USBC", product: "AirPods Pro 2nd Gen", category: "Accessories", storage: "-", color: "White", available: 8, price: 12990 },
];

export const paymentMethods = ["Cash", "GCash", "Credit Card", "Bank Transfer"];

export const salesHistory = [
  { orderId: "ORD-2026-0716-0021", date: "Jul 16, 2026", time: "10:15 AM", customer: "Juan Dela Cruz", phone: "0917 123 4567", device: "iPhone 16 Pro", storage: "256GB", color: "Natural Titanium", salesperson: "Admin", payment: "GCash", total: 78990, status: "Completed" },
  { orderId: "ORD-2026-0716-0020", date: "Jul 16, 2026", time: "9:42 AM", customer: "Mark Santos", phone: "0998 765 4321", device: "iPhone 15", storage: "128GB", color: "Pink", salesperson: "Admin", payment: "Cash", total: 48990, status: "Completed" },
  { orderId: "ORD-2026-0715-0019", date: "Jul 15, 2026", time: "4:30 PM", customer: "Ana Cruz", phone: "0921 456 7890", device: "MacBook Air M4", storage: "512GB", color: "Silver", salesperson: "Jane Reyes", payment: "Credit Card", total: 74990, status: "Completed" },
  { orderId: "ORD-2026-0715-0018", date: "Jul 15, 2026", time: "2:10 PM", customer: "Kimberly Yu", phone: "0916 555 8888", device: "iPad Air 6", storage: "256GB", color: "Space Gray", salesperson: "Admin", payment: "GCash", total: 33990, status: "Refunded" },
  { orderId: "ORD-2026-0714-0017", date: "Jul 14, 2026", time: "11:05 AM", customer: "Patricia Gomez", phone: "0906 789 1234", device: "Apple Watch Series 9", storage: "45mm", color: "Midnight", salesperson: "Jane Reyes", payment: "Bank Transfer", total: 25990, status: "Completed" },
];