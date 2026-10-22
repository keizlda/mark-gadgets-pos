import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";
import { useServiceData } from "../../hooks/useServiceData";
import { getSalesThisMonth } from "../../services/salesService";
import { toStoreDateString } from "../../utils/datetime";

function SalesChart() {
  const salesThisMonth = useServiceData(getSalesThisMonth, []);
  // The view has one row per month that ever had a sale — picking the last
  // one assumed that was always the current month, which broke the moment
  // a new month started with zero sales yet (it kept showing the prior
  // month's total under "This Month"). Match on the actual calendar month
  // instead, so a monthless gap correctly reads ₱0.
  // Compared as Manila "YYYY-MM" — month_start is Manila midnight on the 1st.
  const thisMonth = toStoreDateString().slice(0, 7);
  const currentMonth = salesThisMonth.find((m) => toStoreDateString(new Date(m.monthStart)).slice(0, 7) === thisMonth);
  const total = currentMonth ? currentMonth.sales : 0;

  return (
    <div className="bg-white rounded-xl border border-gray-200 p-5 flex-1">
      <p className="text-sm text-gray-500">Sales This Month</p>
      <p className="text-2xl font-bold text-gray-800">
        ₱{total.toLocaleString()}
      </p>
      <p className="text-xs text-gray-400 mb-4">Total Sales</p>

      <ResponsiveContainer width="100%" height={220}>
        <LineChart data={salesThisMonth}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f0f0f0" />
          <XAxis dataKey="month" tick={{ fontSize: 12, fill: "#9ca3af" }} axisLine={false} tickLine={false} />
          <YAxis
            tickFormatter={(v) => `₱${v / 1000000}M`}
            tick={{ fontSize: 12, fill: "#9ca3af" }}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip formatter={(v) => `₱${v.toLocaleString()}`} />
          <Line type="monotone" dataKey="sales" stroke="#3b82f6" strokeWidth={2} dot={{ r: 4, fill: "#3b82f6" }} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}

export default SalesChart;