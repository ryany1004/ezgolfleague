(function($) {
  "use strict"; // Start of use strict

  // Smooth scrolling using jQuery easing
  $('a.js-scroll-trigger[href*="#"]:not([href="#"])').click(function() {
    if (
      location.pathname.replace(/^\//, "") ==
        this.pathname.replace(/^\//, "") &&
      location.hostname == this.hostname
    ) {
      var target = $(this.hash);
      target = target.length ? target : $("[name=" + this.hash.slice(1) + "]");
      if (target.length) {
        $("html, body").animate(
          {
            scrollTop: target.offset().top - 48
          },
          1000,
          "easeInOutExpo"
        );
        return false;
      }
    }
  });

  // Closes responsive menu when a scroll trigger link is clicked
  $(".js-scroll-trigger").click(function() {
    $(".navbar-collapse").collapse("hide");
  });

  $(window).on("load", function() {
    $(".content").mCustomScrollbar();
  });

  $(function() {
    $('[data-toggle="tooltip"]').tooltip();
  });

  // Hash tracking for Bootstrap tabs
  $(document).ready(() => {
    let url = location.href.replace(/\/$/, "");

    if (location.hash) {
      const hash = url.split("#");
      $('.panel-side-text a[href="#' + hash[1] + '"]').tab("show");
      url = location.href.replace(/\/#/, "#");
      history.replaceState(null, null, url);
      setTimeout(() => {
        $(window).scrollTop(0);
      }, 400);
    }

    $('a[data-toggle="tab"]').on("click", function() {
      let newUrl;
      const hash = $(this).attr("href");
      if (hash == "#v-edit-profile-tab") {
        newUrl = url.split("#")[0];
      } else {
        newUrl = url.split("#")[0] + hash;
      }
      newUrl += "/";
      history.replaceState(null, null, newUrl);
    });
  });

  $(document).ready(function() {
    $(".sortable").sortable({
      connectWith: ".sortable",
      zIndex: 9999999999999
    });

    $(".popup-with-zoom-anim").magnificPopup({
      type: "inline",

      fixedContentPos: true,
      fixedBgPos: true,

      overflowY: "auto",

      closeBtnInside: true,
      preloader: false,

      midClick: true,
      removalDelay: 300,
      mainClass: "my-mfp-zoom-in"
    });
  });

  // Collapse Navbar
  $(document).ready(function() {
    var navbarCollapse = function() {
      if ($("#mainNav").offset().top > 50) {
        $("#mainNav").addClass("navbar-shrink");
      } else {
        $("#mainNav").removeClass("navbar-shrink");
      }
    };
    // Collapse now if page is not at top
    navbarCollapse();
    // Collapse the navbar when page is scrolled
    $(window).scroll(navbarCollapse);
  });
})(jQuery); // End of use strict
