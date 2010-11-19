;(function($) {

function commandReference() {
  var $groups = $("#commands nav a")

  $groups.click(function() {
    window.location.hash = this.getAttribute("href").substring(1)

    filterCommandReference()

    return false
  })
}

function filterCommandReference() {
  var $commands = $("#commands ul")

  var group = window.location.hash.substring(1)

  if (group.length == 0) {
    $commands.children().show()
    $commands.css("height", "auto")
  }
  else {
    $commands.find("li[data-group='" + group + "']").show()
    $commands.find("li[data-group!='" + group + "']").hide()
  }

  adjustCommandReference()

  var $groups = $("#commands nav a")

  $groups.removeClass("current")

  $groups.filter("[href='#" + group + "']").addClass("current")
}

function adjustCommandReference() {
  // Firefox can deal with CSS3 columns
  // without breaking boxes.
  if (window.location.hash.length == 0 && $.browser.mozilla) return

  var $commands = $("#commands ul")

  $commands.css("height", "auto")

  var $command = $commands.find("> *:first")

  var commandHeight = $command.outerHeight(true)

  var containerHeight = $commands.innerHeight()

  $commands.css("height", Math.ceil(containerHeight / commandHeight) * commandHeight)
}

$(document).ready(function() {
  commandReference()

  $(window).resize(adjustCommandReference)

  filterCommandReference()
})

})(jQuery);
