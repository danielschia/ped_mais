module ApplicationHelper
  def nav_link_classes(path)
    base_classes =
      "rounded-md px-3 py-2 text-sm font-medium transition"

    active_classes =
      "bg-gray-900 text-white shadow-md"

    inactive_classes =
      "text-gray-300 hover:bg-white/5 hover:text-white"

    "#{base_classes} #{current_page?(path) ? active_classes : inactive_classes}"
  end

  def logout_button_classes
    "bg-red-500 hover:bg-red-600 text-white rounded-md px-3 py-2 text-sm font-medium transition shadow-md"
  end
end
