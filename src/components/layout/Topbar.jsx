import { Menu, Calendar, Bell, User } from "lucide-react";

function Topbar() {
  const today = new Date().toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });

  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6 fixed top-0 left-64 right-0 z-10">
      <div className="flex items-center gap-4">
        <Menu size={20} className="text-gray-500 cursor-pointer" />
        <h2 className="font-semibold text-gray-800">Dashboard</h2>
      </div>

      <div className="flex items-center gap-6">
        <div className="flex items-center gap-2 text-sm text-gray-500">
          <Calendar size={16} />
          {today}
        </div>

        <div className="relative">
          <Bell size={20} className="text-gray-500 cursor-pointer" />
          <span className="absolute -top-1.5 -right-1.5 bg-red-500 text-white text-[10px] rounded-full w-4 h-4 flex items-center justify-center">
            3
          </span>
        </div>

        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center">
            <User size={16} className="text-gray-500" />
          </div>
          <div className="text-sm">
            <p className="font-medium text-gray-800 leading-none">Admin</p>
            <p className="text-gray-400 text-xs">Administrator</p>
          </div>
        </div>
      </div>
    </header>
  );
}

export default Topbar;