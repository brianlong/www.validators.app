#frozen_string_literal: true

module ExplorerHelper
  def display_sol_difference(sol_change, round = 2)
    if [sol_change].flatten.count == 2
      content_tag(:small, class: "text-muted") do
        "(" + lamports_to_sol(sol_change[1] - sol_change[0]).round(round).to_s + ")"
      end
    end
  end
end
