#frozen_string_literal: true

module ExplorerHelper
  def display_sol_difference(sol_change, round = 2)
    if [sol_change].flatten.compact.count == 2
      tags = html_escape('')
      tags << content_tag(
        :span,
        number_with_delimiter(lamports_to_sol([sol_change].flatten.first.to_i).round(round))
      )
      tags << content_tag(:i, "", class: "fa-solid fa-right-long px-2")
      tags << content_tag(
        :span,
        number_with_delimiter(lamports_to_sol([sol_change].flatten.last.to_i).round(round))
      )
      if sol_change.first < sol_change.last
        tags << content_tag(:i, "", class: "fa-solid fa-up-long text-success ms-2")
      else
        tags << content_tag(:i, "", class: "fa-solid fa-down-long text-danger ms-2")
      end
      tags
    elsif sol_change
      content_tag(
        :span,
        number_with_delimiter(lamports_to_sol([sol_change].flatten.last.to_i).round(round))
      )
    else
      content_tag(:span, "no changes")
    end
  end
end
