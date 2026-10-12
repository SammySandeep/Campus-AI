module ApplicationHelper
  def nav_link(label, path, icon, badge: nil)
    active = current_page?(path)
    link_to path, class: "nav-item #{'active' if active}" do
      safe_join([content_tag(:span, icon, class: "nav-icon"), content_tag(:span, label), (content_tag(:em, badge) if badge.to_i.positive?)].compact)
    end
  end

  def status_badge(status)
    content_tag(:span, status.to_s.humanize, class: "badge status-#{status.to_s.dasherize}")
  end

  def page_header(title, subtitle = nil, &block)
    content_tag(:div, class: "page-header") do
      safe_join([content_tag(:div, safe_join([content_tag(:h1, title), (content_tag(:p, subtitle) if subtitle)].compact)), (capture(&block) if block)].compact)
    end
  end
end
