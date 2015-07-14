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

  var filter = document.querySelector('.command-reference-filter');

  filter.addEventListener('change', function(e) {
    window.location.hash = e.target.value;
  });

  window.onhashchange = function() {
    filterCommandReference();
  }
}

function filterCommandReference() {
  var $commands = $("#commands ul")

  var group = window.location.hash.substring(1)

  if (group.length == 0) {
    $commands.children().show()
    // $commands.css("height", "auto")
  }
  else {
    $commands.find("li[data-group='" + group + "']").show()
    $commands.find("li[data-group!='" + group + "']").hide()
  }

  var $groups = $("#commands nav a")

  $groups.removeClass("current")

  $groups.filter("[href='#" + group + "']").addClass("current")

  document.querySelector('.command-reference-filter').value = group;
}

function autolink(text) {
  return text.replace(/(https?:\/\/[-\w\.]+:?\/[\w\/_\-\.]*(\?\S+)?)/, "<a href='$1'>$1</a>");
}

function massageTweet(text) {
  text = text.replace(/^.* @\w+: /, "");

  return autolink(text);
}

function searchCommandReference() {
  var $commands = $('li')

  $('.js-command-reference-search').bind('input', function(ev) {
    window.location.hash = '';

    if (ev.keyCode === 13) {
      var name = $commands.filter(':visible')[0].getAttribute('data-name');

      window.location = '/commands/' + name.replace(/ /g, '-');

      return;
    }

    var val = $(this).val().toLowerCase().replace(/[^a-z0-9 ]/g, '');

    if (val === '') {
      $commands.show()
    } else {
      $commands.hide()
      $('li[data-name*="' + val + '"]').show()
    }
  })
}

function buzz() {
  var $buzz = $("#buzz");

  if ($buzz.length == 0) return;

  var $ul = $buzz.find("ul");
  var count = 0;
  var limit = parseInt($buzz.attr("data-limit"));
  var users = {};

  $.getJSON("http://redis-buzz.herokuapp.com/?callback=?", function(response) {
    $.each(response, function() {

      if (count++ == limit) { return false; }

      if (this.retweeted_status) {
        var status = this.retweeted_status;
      } else {
        var status = this;
      }

      $ul.append(
        "<li>" +
        "<a href='http://twitter.com/" + status.user.screen_name + "/statuses/" + status.id_str + "' title='" + status.user.screen_name + "'>" +
        "<img src='" + status.user.profile_image_url + "' alt='" + status.user.screen_name + "' />" +
        "</a> " +
        massageTweet(status.text) +
        "</li>"
      );
    });
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
  var slideout = new Slideout({
    'panel': document.querySelector('.site-wrapper'),
    'menu': document.querySelector('.mobile-menu'),
    'padding': 256,
    'tolerance': 70
  });

  document.querySelector('.js-slideout-toggle').addEventListener('click', function() {
    slideout.toggle();
  });

  document.querySelector('.mobile-menu').addEventListener('click', function(eve) {
    if (eve.target.nodeName === 'A') { slideout.close(); }
  });

  if (document.getElementById('commands')) {
    commandReference();
    filterCommandReference();
    searchCommandReference()
  }

  buzz()

  examples()
})

})(jQuery);
