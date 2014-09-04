window.onload = ->
	a = document.getElementById("page_assigner")
	if a
		a.onclick = ->
			total_pages = if gon then gon.total_pages else 0
			if total_pages == 0
				return false
			else
				checkboxes = []
				inputs = document.getElementsByTagName("input")
				i = 0
				n = inputs.length
				while i < inputs.length
					if inputs[i].type == "checkbox"
						checkboxes.push(inputs[i])
					i++
				i = 0
				offset = 0
				new_ind = 0
				n = checkboxes.length
				while i < n
					checkboxes[new_ind].checked = true
					i+= total_pages
					offset = if offset+1>=total_pages then total_pages-1 else offset+1
					old_ind = new_ind
					new_ind = i + offset
					j = old_ind + 1
					while j < new_ind and j < n
						checkboxes[j].checked = false
						j++
				return false
		return
