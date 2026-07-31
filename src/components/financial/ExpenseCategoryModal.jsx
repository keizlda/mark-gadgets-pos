import { X, Trash2 } from "lucide-react";

const peso = (n) => "₱" + Number(n || 0).toLocaleString("en-PH", { maximumFractionDigits: 2 });

// Line-item breakdown behind one of Financial's Expenses/Cargo/Prulife
// summary cards — mirrors UnsoldUnitsModal's click-a-card-to-drill-in pattern.
function ExpenseCategoryModal({ category, entries, isAdmin, onRemove, onClose }) {
  const total = entries.reduce((sum, e) => sum + e.amount, 0);

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-2xl shadow-xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100">
          <div>
            <p className="font-semibold text-gray-800">{category}</p>
            <p className="text-xs text-gray-400">Every {category.toLowerCase()} entry for the selected period</p>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-4 max-h-[60vh] overflow-y-auto">
          {entries.length === 0 ? (
            <p className="text-sm text-gray-400 text-center py-6">No {category.toLowerCase()} entries for this period.</p>
          ) : (
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-gray-400 border-b border-gray-100">
                  <th className="pb-2 font-medium">Date</th>
                  <th className="pb-2 font-medium">Description</th>
                  <th className="pb-2 font-medium text-right">Amount</th>
                  {isAdmin && <th className="pb-2 font-medium text-right">Remove</th>}
                </tr>
              </thead>
              <tbody>
                {entries.map((e) => (
                  <tr key={e.id} className="border-b border-gray-50">
                    <td className="py-2.5 text-gray-700 whitespace-nowrap">{e.date}</td>
                    <td className="py-2.5 text-gray-700">
                      {e.description}
                      {e.adminOnly && <span className="ml-2 text-xs text-gray-300">(Admin Only)</span>}
                    </td>
                    <td className="py-2.5 text-right text-red-500">-{peso(e.amount)}</td>
                    {isAdmin && (
                      <td className="py-2.5 text-right">
                        <button onClick={() => onRemove(e.id)} className="text-gray-400 hover:text-red-500 p-1">
                          <Trash2 size={14} />
                        </button>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        <div className="px-5 py-4 border-t border-gray-100 flex justify-between items-center">
          <p className="text-sm font-semibold text-gray-800">
            Total {category} <span className="text-red-500">-{peso(total)}</span>
          </p>
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}

export default ExpenseCategoryModal;
