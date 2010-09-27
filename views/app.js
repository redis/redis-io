;(function($) {

function login() {
  var logged_in = document.cookie.match(/gravatar=([a-z0-9]+)/)

  if (logged_in) {
    var gravatar = logged_in[1]

    $(".user.logged-in").show()
    $(".user.anonymous").hide()

    $(".user.gravatar").each(function() {
      this.src = "http://www.gravatar.com/avatar/" + gravatar + ".jpg?s=" + this.width
    })
  }
}

$(document).ready(function() {
  $("time").timeago()

  login()
})

})(jQuery);
