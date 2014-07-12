module ApplicationHelper

  # Returns the full title on a per-page basis
  def full_title(page_title="")
    base_title = "MagicGrader"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def instructor_or_more
    status_or_more Statuses::INSTRUCTOR
  end

  def TA_or_more
    status_or_more Statuses::TA
  end

  def status_or_more(status)
    has_permission = (@enrollment and @enrollment.status >= status)
    unless has_permission
      redirect_to root_url, notice: "You ain't allowed to access this part of the course ಠ_ಠ"
    end
  end

end
