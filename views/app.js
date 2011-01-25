;(function($) {

var cssPrefix = null;

if ($.browser.mozilla) cssPrefix = "moz";
  else if ($.browser.webkit) cssPrefix = "webkit";
  else if ($.browser.opera) cssPrefix = "o";

$.cssHooks["columnCount"] = {
  get: function(element, computed) {
    var browserSpecificName = "-" + cssPrefix + "-column-count";

    if (computed) {
      return $.css(element, browserSpecificName);
    }
    else {
      return element.style[browserSpecificName];
    }
  }
}

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
  var $commands = $("#commands ul")

  $commands.css("height", "auto")

  var $command = $commands.find("> *:first")

  var commandHeight = $command.outerHeight(true)

  var containerHeight = $commands.innerHeight()

  var factor = Math.floor(containerHeight / commandHeight)

  if ((factor * $commands.css("column-count")) < $commands.children(":visible").length) factor++;

  $commands.css("height", factor * commandHeight)
}

function autolink(text) {
  return text.replace(/(https?:\/\/[-\w\.]+:?\/[\w\/_\-\.]*(\?\S+)?)/, "<a href='$1'>$1</a>");
}

function massageTweet(text) {
  text = text.replace(/^.* @\w+: /, "");

  return autolink(text);
}

function legitimate(text) {
  return !text.match(/le redis|redis le/i);
}

function buzz() {
  var $buzz = $("#buzz");

  if ($buzz.length == 0) return;

  var $ul = $buzz.find("ul");
  var count = 0;
  var limit = parseInt($buzz.attr("data-limit"));
  var page = $buzz.attr("data-page") || 1;
  var users = {};

  $.getJSON("http://search.twitter.com/search?q=redis+-RT&lang=en&rpp=30&format=json&page=" + page + "&callback=?", function(response) {
    $.each(response.results, function() {

      // Skip if the tweet is not Redis related.
      if (!legitimate(this.text)) { return; }

      // Don't show the same user multiple time
      if (users[this.from_user]) { return true; }

      // Stop when reaching the hardcoded limit.
      if (count++ == limit) { return false; }

      // Remember this user
      users[this.from_user] = true;

      $ul.append(
        "<li>" +
        "<a href='http://twitter.com/" + this.from_user + "/statuses/" + this.id_str + "' title='" + this.from_user + "'>" +
        "<img src='" + this.profile_image_url + "' alt='" + this.from_user + "' />" +
        "</a> " +
        massageTweet(this.text) +
        "</li>"
      );
    });
  });

  $buzz.find("> a.paging").click(function() {
    var $buzz = $(this).parent();
    $buzz.attr("data-page", parseInt($buzz.attr("data-page")) + 1);
    buzz();
    return false;
  });
}

// Easily set caret position in input field
$.fn.setSelection = function(start, end) {
  var i, size = this.size();

  // Only set caret by default
  if (end === undefined) end = start;

  for (i = 0; i < size; i++) {
    var element = this.get(i);
    if (element.createTextRange) { // IE
      var range = element.createTextRange();
      range.collapse(true);
      range.moveEnd('character', end);
      range.moveStart('character', start);
      range.select();
    } else if (element.setSelectionRange) { // Other browsers
      element.setSelectionRange(start, end);
    }
  }
}

function examples() {
  $('div.example').each(function() {
    var $example = $(this);
    var $form = $example.find("form");
    var $input = $form.find("input");

    $input.keydown(function(event) {
      var count = $example.find(".command").size();
      var index = $input.data("index");
      if (index == undefined) index = count;

      if (event.keyCode == 38) {
        index--; // up
      } else if (event.keyCode == 40) {
        index++; // down
      } else {
        return;
      }

      // Out of range at the positive side of the range makes sure
      // we can get back to an empty value.
      if (index >= 0 && index <= count) {
        $input.data("index", index);
        $input.val($example.find(".command").eq(index).text());
        $input.setSelection($input.val().length);
      }

      return false;
    });

    $form.submit(function(event) {
      if ($input.val().length == 0)
        return false;

      // Append command to execute
      var ps1 = $("<span></span>")
        .addClass("monospace")
        .addClass("prompt")
        .html("redis&gt;&nbsp;");
      var cmd = $("<span></span>")
        .addClass("monospace")
        .addClass("command")
        .text($input.val());
      $form.before(ps1);
      $form.before(cmd);

      // Hide form
      $form.hide();

      // POST command to app
      $.ajax({
        type: "post",
        url: "/session/" + $example.attr("data-session"),
        data: $form.serialize(),
        complete: function(xhr, textStatus) {
          var data = xhr.responseText;
          var pre = $("<pre></pre>").text(data);
          $form.before(pre);

          // Reset input field and show form
          $input.val("");
          $input.removeData("index");
          $form.show();
        }
      });

      return false;
    });
  });

  // Only focus field when it is visible
  var $first = $('div.example:first :text');
  if ($first.size() > 0) {
    var windowTop = $(window).scrollTop();
    var windowBottom = windowTop + $(window).height();
    var elemTop = $first.offset().top;
    var elemBottom = elemTop + $first.height();
    if (elemTop >= windowTop && elemBottom < windowBottom) {
      $first.focus();
    }
  }
}

$(document).ready(function() {
  commandReference()

  $(window).resize(adjustCommandReference)

  filterCommandReference()

  buzz();

  examples();
})

})(jQuery);
