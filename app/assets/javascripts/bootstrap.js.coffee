jQuery ->
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()

$(".dropdown-toggle").click (e) ->
  e.preventDefault()
  setTimeout $.proxy(->
    $(this).siblings(".dropdown-backdrop").off().remove()  if "ontouchstart" of document.documentElement
    return
  , this), 0
  return
