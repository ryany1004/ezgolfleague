// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets
//= require moment
//= require selectize
//= require chosen-jquery
//= require chosen_scaffold
//= require jquery.mCustomScrollbar.concat.min.js
//= require jquery.magnific-popup.min.js

//= require_tree .

/*menu handler*/
$(function() {
  function stripTrailingSlash(str) {
    if (str.substr(-1) == "/") {
      return str.substr(0, str.length - 1);
    }
    return str;
  }

  //highlight stuff
  var url = window.location.pathname;
  var activePage = stripTrailingSlash(url);

  $(".nav li a").each(function() {
    var currentPage = stripTrailingSlash($(this).attr("href"));

    if (activePage == currentPage && !activePage.includes("play")) {
      $(this)
        .parent()
        .addClass("active");
    }
  });
});

jQuery.fn.extend({
  disable: function(state) {
    return this.each(function() {
      this.disabled = state;
    });
  }
});

function ezglTrackAnalyticsEvent(eventName, eventProperties = null) {
  amplitude.getInstance().logEvent(eventName, eventProperties);

  _dcq.push(["track", eventName, eventProperties]);
}
