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

	def html_title
		'<font color=ff00ff>M</font><font color=ff00cc>a</font><font color=ff0099>g</font><font color=ff0066>i</font><font color=ff0033>c</font><font color=ff0000>G</font><font color=ff3300>r</font><font color=ff6600>a</font><font color=ff9900>d</font><font color=ffcc00>e</font><font color=ffff00>r</font>'
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

	def link_to_add_fields name, f, association, options
		new_object = f.object.send(association).klass.new
		id = new_object.object_id
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			builder.options[:depth] = f.options[:depth] + 1
			render 'subpart_fields', f: builder
		end
		if options[:class]
			options[:class] += " add_fields"
		end
		options[:data] = { id: id, fields: fields.gsub("\n","") }
		link_to name, '#', options
	end

	def pluralize_phrase count, noun, singular_verb, plural_verb
		"#{count} " + ((count == 1) ? "#{noun} #{singular_verb}" : "#{noun.pluralize} plural_verb")
	end

	def plural_without_count count, noun
		count == 1 ? noun : noun.pluralize
	end

end
