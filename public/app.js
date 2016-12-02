!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.Slideout=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';

/**
 * Module dependencies
 */
var decouple = require('decouple');

/**
 * Privates
 */
var scrollTimeout;
var scrolling = false;
var doc = window.document;
var html = doc.documentElement;
var msPointerSupported = window.navigator.msPointerEnabled;
var touch = {
  'start': msPointerSupported ? 'MSPointerDown' : 'touchstart',
  'move': msPointerSupported ? 'MSPointerMove' : 'touchmove',
  'end': msPointerSupported ? 'MSPointerUp' : 'touchend'
};
var prefix = (function prefix() {
  var regex = /^(Webkit|Khtml|Moz|ms|O)(?=[A-Z])/;
  var styleDeclaration = doc.getElementsByTagName('script')[0].style;
  for (var prop in styleDeclaration) {
    if (regex.test(prop)) {
      return '-' + prop.match(regex)[0].toLowerCase() + '-';
    }
  }
  // Nothing found so far? Webkit does not enumerate over the CSS properties of the style object.
  // However (prop in style) returns the correct value, so we'll have to test for
  // the precence of a specific property
  if ('WebkitOpacity' in styleDeclaration) { return '-webkit-'; }
  if ('KhtmlOpacity' in styleDeclaration) { return '-khtml-'; }
  return '';
}());

/**
 * Slideout constructor
 */
function Slideout(options) {
  options = options || {};

  // Sets default values
  this._startOffsetX = 0;
  this._currentOffsetX = 0;
  this._opening = false;
  this._moved = false;
  this._opened = false;
  this._preventOpen = false;

  // Sets panel
  this.panel = options.panel;
  this.menu = options.menu;

  // Sets  classnames
  this.panel.className += ' slideout-panel';
  this.menu.className += ' slideout-menu';

  // Sets options
  this._fx = options.fx || 'ease';
  this._duration = parseInt(options.duration, 10) || 300;
  this._tolerance = parseInt(options.tolerance, 10) || 70;
  this._padding = parseInt(options.padding, 10) || 256;

  // Init touch events
  this._initTouchEvents();
}

/**
 * Opens the slideout menu.
 */
Slideout.prototype.open = function() {
  var self = this;
  if (html.className.search('slideout-open') === -1) { html.className += ' slideout-open'; }
  this._setTransition();
  this._translateXTo(this._padding);
  this._opened = true;
  setTimeout(function() {
    self.panel.style.transition = self.panel.style['-webkit-transition'] = '';
  }, this._duration + 50);
  return this;
};

/**
 * Closes slideout menu.
 */
Slideout.prototype.close = function() {
  var self = this;
  if (!this.isOpen() && !this._opening) { return this; }
  this._setTransition();
  this._translateXTo(0);
  this._opened = false;
  setTimeout(function() {
    html.className = html.className.replace(/ slideout-open/, '');
    self.panel.style.transition = self.panel.style['-webkit-transition'] = '';
  }, this._duration + 50);
  return this;
};

/**
 * Toggles (open/close) slideout menu.
 */
Slideout.prototype.toggle = function() {
  return this.isOpen() ? this.close() : this.open();
};

/**
 * Returns true if the slideout is currently open, and false if it is closed.
 */
Slideout.prototype.isOpen = function() {
  return this._opened;
};

/**
 * Translates panel and updates currentOffset with a given X point
 */
Slideout.prototype._translateXTo = function(translateX) {
  this._currentOffsetX = translateX;
  this.panel.style[prefix + 'transform'] = this.panel.style.transform = 'translate3d(' + translateX + 'px, 0, 0)';
};

/**
 * Set transition properties
 */
Slideout.prototype._setTransition = function() {
  this.panel.style[prefix + 'transition'] = this.panel.style.transition = prefix + 'transform ' + this._duration + 'ms ' + this._fx;
};

/**
 * Initializes touch event
 */
Slideout.prototype._initTouchEvents = function() {
  var self = this;

  /**
   * Decouple scroll event
   */
  decouple(doc, 'scroll', function() {
    if (!self._moved) {
      clearTimeout(scrollTimeout);
      scrolling = true;
      scrollTimeout = setTimeout(function() {
        scrolling = false;
      }, 250);
    }
  });

  /**
   * Prevents touchmove event if slideout is moving
   */
  doc.addEventListener(touch.move, function(eve) {
    if (self._moved) {
      eve.preventDefault();
    }
  });

  /**
   * Resets values on touchstart
   */
  this.panel.addEventListener(touch.start, function(eve) {
    self._moved = false;
    self._opening = false;
    self._startOffsetX = eve.touches[0].pageX;
    self._preventOpen = (!self.isOpen() && self.menu.clientWidth !== 0);
  });

  /**
   * Resets values on touchcancel
   */
  this.panel.addEventListener('touchcancel', function() {
    self._moved = false;
    self._opening = false;
  });

  /**
   * Toggles slideout on touchend
   */
  this.panel.addEventListener(touch.end, function() {
    if (self._moved) {
      (self._opening && Math.abs(self._currentOffsetX) > self._tolerance) ? self.open() : self.close();
    }
    self._moved = false;
  });

  /**
   * Translates panel on touchmove
   */
  this.panel.addEventListener(touch.move, function(eve) {

    if (scrolling || self._preventOpen) { return; }

    var dif_x = eve.touches[0].clientX - self._startOffsetX;
    var translateX = self._currentOffsetX = dif_x;

    if (Math.abs(translateX) > self._padding) { return; }

    if (Math.abs(dif_x) > 20) {
      self._opening = true;

      if (self._opened && dif_x > 0 || !self._opened && dif_x < 0) { return; }

      if (!self._moved && html.className.search('slideout-open') === -1) {
        html.className += ' slideout-open';
      }

      if (dif_x <= 0) {
        translateX = dif_x + self._padding;
        self._opening = false;
      }

      self.panel.style[prefix + 'transform'] = self.panel.style.transform = 'translate3d(' + translateX + 'px, 0, 0)';

      self._moved = true;
    }

  });

};

/**
 * Expose Slideout
 */
module.exports = Slideout;

},{"decouple":2}],2:[function(require,module,exports){
'use strict';

var requestAnimFrame = (function() {
  return window.requestAnimationFrame ||
    window.webkitRequestAnimationFrame ||
    function (callback) {
      window.setTimeout(callback, 1000 / 60);
    };
}());

function decouple(node, event, fn) {
  var eve,
      tracking = false;

  function captureEvent(e) {
    eve = e;
    track();
  }

  function track() {
    if (!tracking) {
      requestAnimFrame(update);
      tracking = true;
    }
  }

  function update() {
    fn.call(node, eve);
    tracking = false;
  }

  node.addEventListener(event, captureEvent, false);
}

/**
 * Expose decouple
 */
module.exports = decouple;

},{}]},{},[1])(1)
});



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

  $.getJSON("https://redis-buzz.herokuapp.com/?callback=?", function(response) {
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
        "<img src='" + status.user.profile_image_url_https + "' alt='" + status.user.screen_name + "' />" +
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
