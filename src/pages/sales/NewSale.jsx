import { useState, useMemo } from "react";
import { Search, Filter, Plus, Minus, X, ChevronLeft, ChevronRight, ShoppingCart, Wallet, CreditCard, Smartphone, Landmark, Tablet, Laptop, Watch, Headphones } from "lucide-react";
import { posCategories, posProducts } from "../../data/mockData";

const paymentOptions = [
  { id: "Cash", label: "Cash", icon: Wallet },
  { id: "Card", label: "Card", icon: CreditCard },
  { id: "GCash", label: "GCash", icon: Smartphone },
  { id: "Bank Transfer", label: "Bank Transfer", icon: Landmark },
];

const categoryIcon = {
  iPhones: Smartphone,
  iPads: Tablet,
  MacBooks: Laptop,
  "Apple Watches": Watch,
  Accessories: Headphones,
};

const categoryColor = {
  iPhones: "bg-gray-100 text-gray-600",
  iPads: "bg-blue-50 text-blue-500",
  MacBooks: "bg-gray-100 text-gray-600",
  "Apple Watches": "bg-red-50 text-red-500",
  Accessories: "bg-purple-50 text-purple-500",
};

function NewSale() {
  const [customerSearch, setCustomerSearch] = useState("");
  const [productSearch, setProductSearch] = useState("");
  const [activeCategory, setActiveCategory] = useState("All Categories");
  const [cart, setCart] = useState([]);
  const [discount, setDiscount] = useState("");
  const [payment, setPayment] = useState("Cash");
  const [notes, setNotes] = useState("");

  const filteredProducts = useMemo(() => {
    return posProducts.filter((p) => {
      const matchesCategory = activeCategory === "All Categories" || p.category === activeCategory;
      const matchesSearch =
        !productSearch ||
        p.product.toLowerCase().includes(productSearch.toLowerCase()) ||
        p.batchCode.toLowerCase().includes(productSearch.toLowerCase());
      return matchesCategory && matchesSearch;
    });
  }, [activeCategory, productSearch]);

  const addToCart = (product) => {
    setCart((prev) => {
      const existing = prev.find((c) => c.batchCode === product.batchCode);
      if (existing) {
        return prev.map((c) =>
          c.batchCode === product.batchCode ? { ...c, qty: c.qty + 1 } : c
        );
      }
      return [...prev, { ...product, qty: 1 }];
    });
  };

  const updateQty = (batchCode, delta) => {
    setCart((prev) =>
      prev
        .map((c) => (c.batchCode === batchCode ? { ...c, qty: c.qty + delta } : c))
        .filter((c) => c.qty > 0)
    );
  };

  const removeFromCart = (batchCode) => {
    setCart((prev) => prev.filter((c) => c.batchCode !== batchCode));
  };

  const clearCart = () => setCart([]);

  const subtotal = cart.reduce((sum, c) => sum + c.price * c.qty, 0);
  const discountAmount = Number(discount) || 0;
  const taxable = Math.max(0, subtotal - discountAmount);
  const tax = taxable * 0.12;
  const total = taxable + tax;

  const handleProcessSale = () => {
    if (cart.length === 0) return;
    console.log("Sale:", { cart, discount, payment, notes, total });
    alert("Sale processed (mock — no backend connected yet).");
    clearCart();
    setDiscount("");
    setNotes("");
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
      {/* Left + Middle columns */}
      <div className="lg:col-span-2 space-y-4">
        {/* Step 1: Customer */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <div className="flex items-center gap-2 mb-3">
            <span className="w-5 h-5 rounded-full bg-blue-600 text-white text-xs flex items-center justify-center font-semibold">1</span>
            <p className="text-sm font-semibold text-gray-700">Select Customer (Optional)</p>
          </div>
          <div className="flex gap-3">
            <div className="relative flex-1">
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                value={customerSearch}
                onChange={(e) => setCustomerSearch(e.target.value)}
                placeholder="Search by name or phone number..."
                className="w-full pl-8 pr-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <button className="flex items-center gap-1.5 px-4 py-2 text-sm text-blue-600 border border-blue-200 rounded-lg hover:bg-blue-50 whitespace-nowrap">
              <Plus size={14} />
              New Customer
            </button>
          </div>
        </div>

        {/* Step 2: Products */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <div className="flex items-center gap-2 mb-3">
            <span className="w-5 h-5 rounded-full bg-blue-600 text-white text-xs flex items-center justify-center font-semibold">2</span>
            <p className="text-sm font-semibold text-gray-700">Select Products</p>
          </div>

          <div className="flex gap-3 mb-4">
            <div className="relative flex-1">
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                value={productSearch}
                onChange={(e) => setProductSearch(e.target.value)}
                placeholder="Search by name, model, serial number or IMEI..."
                className="w-full pl-8 pr-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <button className="flex items-center gap-1.5 px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50 whitespace-nowrap">
              <Filter size={14} />
              Filters
            </button>
          </div>

          <div className="flex gap-4">
            {/* Category sidebar */}
            <div className="w-36 flex-shrink-0 space-y-1">
              <p className="text-xs text-gray-400 font-medium mb-1">Categories</p>
              {posCategories.map((cat) => (
                <button
                  key={cat}
                  onClick={() => setActiveCategory(cat)}
                  className={`block w-full text-left px-3 py-2 rounded-lg text-sm ${
                    activeCategory === cat
                      ? "bg-blue-50 text-blue-600 font-medium"
                      : "text-gray-500 hover:bg-gray-50"
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>

            {/* Product table */}
            <div className="flex-1 overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="text-left text-gray-400 border-b border-gray-100">
                    <th className="pb-2 font-medium">Product</th>
                    <th className="pb-2 font-medium">Storage</th>
                    <th className="pb-2 font-medium">Color</th>
                    <th className="pb-2 font-medium">Available</th>
                    <th className="pb-2 font-medium">Price</th>
                    <th className="pb-2 font-medium"></th>
                  </tr>
                </thead>
                <tbody>
                  {filteredProducts.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="py-8 text-center text-gray-400">
                        No products found.
                      </td>
                    </tr>
                  ) : (
                    filteredProducts.map((p, i) => {
                      const Icon = categoryIcon[p.category] || Smartphone;
                      return (
                        <tr key={i} className="border-b border-gray-50 hover:bg-gray-50">
                          <td className="py-2.5">
                            <div className="flex items-center gap-2.5">
                              <div className={`w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ${categoryColor[p.category] || "bg-gray-100 text-gray-600"}`}>
                                <Icon size={15} />
                              </div>
                              <div>
                                <p className="text-gray-800 font-medium">{p.product}</p>
                                <p className="text-xs text-gray-400">{p.batchCode}</p>
                              </div>
                            </div>
                          </td>
                          <td className="py-2.5 text-gray-600">{p.storage}</td>
                          <td className="py-2.5 text-gray-600">{p.color}</td>
                          <td className="py-2.5 text-green-600 font-medium">{p.available}</td>
                          <td className="py-2.5 text-gray-700">₱{p.price.toLocaleString()}</td>
                          <td className="py-2.5 text-right">
                            <button
                              onClick={() => addToCart(p)}
                              className="p-1.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                            >
                              <Plus size={14} />
                            </button>
                          </td>
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </table>

              <div className="flex items-center justify-between mt-4 flex-wrap gap-3">
                <p className="text-xs text-gray-500">
                  Showing 1 to {filteredProducts.length} of {filteredProducts.length} products
                </p>
                <div className="flex items-center gap-3">
                  <select className="border border-gray-200 rounded-lg text-xs px-2 py-1.5">
                    <option>10 per page</option>
                    <option>20 per page</option>
                  </select>
                  <div className="flex items-center gap-1">
                    <button className="p-1.5 border border-gray-200 rounded-lg text-gray-400">
                      <ChevronLeft size={14} />
                    </button>
                    <button className="w-7 h-7 text-xs rounded-lg bg-blue-600 text-white">1</button>
                    <button className="p-1.5 border border-gray-200 rounded-lg text-gray-400">
                      <ChevronRight size={14} />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Right: Cart / Order Summary */}
      <div className="bg-white rounded-xl border border-gray-200 p-5 h-fit sticky top-20">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <span className="w-5 h-5 rounded-full bg-blue-600 text-white text-xs flex items-center justify-center font-semibold">3</span>
            <p className="text-sm font-semibold text-gray-700">Cart / Order Summary</p>
          </div>
          {cart.length > 0 && (
            <button onClick={clearCart} className="text-xs text-red-500 hover:underline">
              Clear Cart
            </button>
          )}
        </div>

        {cart.length === 0 ? (
          <div className="text-center py-10">
            <ShoppingCart size={28} className="text-gray-200 mx-auto mb-2" />
            <p className="text-sm text-gray-400">Cart is empty</p>
          </div>
        ) : (
          <div className="space-y-3 mb-4 max-h-64 overflow-y-auto pr-1">
            {cart.map((c, i) => {
              const Icon = categoryIcon[c.category] || Smartphone;
              return (
                <div key={i} className="flex items-center justify-between">
                  <div className="flex items-center gap-2 flex-1 min-w-0">
                    <div className={`w-7 h-7 rounded-lg flex items-center justify-center flex-shrink-0 ${categoryColor[c.category] || "bg-gray-100 text-gray-600"}`}>
                      <Icon size={13} />
                    </div>
                    <div className="min-w-0">
                      <p className="text-sm text-gray-800 font-medium truncate">{c.product}</p>
                      <p className="text-xs text-gray-400">{c.storage} · {c.color}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-1 border border-gray-200 rounded-lg px-1 mx-2">
                    <button onClick={() => updateQty(c.batchCode, -1)} className="p-1 text-gray-500 hover:text-gray-800">
                      <Minus size={11} />
                    </button>
                    <span className="text-xs w-4 text-center">{c.qty}</span>
                    <button onClick={() => updateQty(c.batchCode, 1)} className="p-1 text-gray-500 hover:text-gray-800">
                      <Plus size={11} />
                    </button>
                  </div>
                  <span className="text-sm font-medium text-gray-700 w-16 text-right">
                    ₱{(c.price * c.qty).toLocaleString()}
                  </span>
                  <button onClick={() => removeFromCart(c.batchCode)} className="text-red-400 hover:text-red-600 ml-2">
                    <X size={14} />
                  </button>
                </div>
              );
            })}
          </div>
        )}

        <div className="space-y-2 text-sm border-t border-gray-100 pt-3">
          <div className="flex justify-between text-gray-500">
            <span>Subtotal ({cart.length} item{cart.length === 1 ? "" : "s"})</span>
            <span>₱{subtotal.toLocaleString()}</span>
          </div>
          <div className="flex justify-between items-center text-gray-500">
            <span>Discount</span>
            <input
              type="number"
              value={discount}
              onChange={(e) => setDiscount(e.target.value)}
              placeholder="Enter amount"
              className="w-28 text-right border border-gray-200 rounded-lg px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div className="flex justify-between text-gray-500">
            <span>Tax (VAT 12%)</span>
            <span>₱{tax.toLocaleString(undefined, { maximumFractionDigits: 2 })}</span>
          </div>
          <div className="flex justify-between font-semibold text-gray-800 pt-2 border-t border-gray-100 text-base">
            <span>Total</span>
            <span>₱{total.toLocaleString(undefined, { maximumFractionDigits: 2 })}</span>
          </div>
        </div>

        {/* Payment Method */}
        <div className="mt-4">
          <p className="text-xs font-medium text-gray-600 mb-2">Payment Method</p>
          <div className="grid grid-cols-2 gap-2">
            {paymentOptions.map((opt) => {
              const Icon = opt.icon;
              const active = payment === opt.id;
              return (
                <button
                  key={opt.id}
                  onClick={() => setPayment(opt.id)}
                  className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm border ${
                    active
                      ? "border-blue-500 bg-blue-50 text-blue-600"
                      : "border-gray-200 text-gray-600 hover:bg-gray-50"
                  }`}
                >
                  <Icon size={14} />
                  {opt.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Notes */}
        <div className="mt-4">
          <p className="text-xs font-medium text-gray-600 mb-1.5">Reference / Notes (Optional)</p>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            rows={2}
            placeholder="Add reference or notes..."
            className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
          />
        </div>

        <button
          onClick={handleProcessSale}
          disabled={cart.length === 0}
          className="w-full mt-4 flex items-center justify-center gap-2 bg-blue-600 text-white py-2.5 rounded-lg text-sm font-medium hover:bg-blue-700 disabled:opacity-40 disabled:cursor-not-allowed"
        >
          <ShoppingCart size={15} />
          Process Sale
        </button>
      </div>
    </div>
  );
}

export default NewSale;