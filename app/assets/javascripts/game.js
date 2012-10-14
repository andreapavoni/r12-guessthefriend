// Game Engine.
//
$(function () {
  var oh_so_sorry = function () {
    alert ("Aw, Snap! Something went wrong - we apologize -_-");
  };

  // Next hint button
  //
  var hint = $('#hint');
  var roll = $('#next-hint');

  roll.click (function (event) {
    event.preventDefault ();

    var elem = $(this);

    $.ajax ({
      dataType: 'text',
      type    : 'get',
      url     : elem.data ('url'),

      success : function (data) {
        hint.text (data);
      },

      error: oh_so_sorry
    });
  });

  /* Elimination core */
  var $mode = 'MODE_ELIMINATE';

  var you_lose = function (options) {
    reveal (options.reveal);

    setTimeout (function () {
      alert ('YOO L0SE! You scored '+options.score+' points, anyway');

      if (confirm ('Wanna play again?'))
        go.restart ();
      else
        go.abandon ();
    }, 1000);
  };

  var you_win = function (options) {
    alert ('FOR THE WIN!!!11 You scored '+options.score+' points on this game!');

    if (confirm ('Wanna play again?'))
      go.restart ();
  };


  // Reveals the mysterious friend
  //
  var reveal = function (id) {
    people.filter (':not([id='+id+'])').fadeOut ();
  }

  // API Client
  //
  var people = $('.friend'), friends = $('.friends');
  friends.on ('click', '.friend', function (event) {
    event.preventDefault ();

    var person = $(this);
    $.ajax ({
      url: friends.data ($mode == 'MODE_ELIMINATE' ? 'eliminate-url' : 'guess-url'),

      data: { id: person.attr ('id') },

      statusCode: {
        200: function (score) {
          friends.trigger ('guesswho:success', [person, score]);
        },

        418: function (jqXHR) { // YOU'RE A TEAPOT
          friends.trigger ('guesswho:failed', [person, jqXHR.responseText]);
        },

        500: oh_so_sorry
      },
    });
  });

  $(friends).bind({
    'guesswho:success': function (event, person, score) {
      switch($mode) {
      case 'MODE_ELIMINATE':
        // OK, hide the wrong one
        person.fadeOut (function () {
          if (people.filter (':visible').length == 1)
            you_win ({score: score});
        });
        break;

      case 'MODE_GUESS':
        you_win ({score: score});
        break;
      }
    },

    'guesswho:failed': function (event, person, score) {
      switch($mode) {
      case 'MODE_ELIMINATE':
        // Hide everyone except this one, that is the correct one.
        //
        you_lose ({score: score, reveal: person.attr ('id')});
        break;

      case 'MODE_GUESS':
        // Oh no, you guessed the wrong one ;-)
        // Reveal the right one and fail.
        $.ajax ({
          url      : go.to ('#reveal-url'),
          dataType : 'text',
          sync     : true,
          error    : oh_so_sorry,
          success  : function (id) {
            you_lose ({score: score, reveal: id});
          }
        });
        break;
      }
    }
  });

  // Router
  //
  var restart = $('#new-game');
  restart.click (function (event) {
    event.preventDefault ();

    if (confirm ('Sure, pal?')) {
      $.ajax ({
        url      : go.to ('#reveal-url'),
        dataType : 'text',
        sync     : true,
        error    : oh_so_sorry,
        success  : function (id) {
          reveal (id);
          setTimeout (function () { go.restart () }, 1000);
        }
      });
    }
  });

  var go = {
    restart: function () {
      this.go ('#restart-url');
    },

    abandon: function () {
      this.go ('#abandon-url');
    },

    go: function (elem) {
      window.location.href = this.to (elem);
    },

    to: function (elem) {
      return $(elem).val ();
    }
  };


  // Mode switcher
  //
  (function () {
    var button = $('#i-got-it');
    var label  = button.find ('.text');
    var orig   = label.text ();

    button.click (function (event) {
      event.preventDefault ();

      if ($mode == 'MODE_ELIMINATE') {
        $mode = 'MODE_GUESS';
        button.addClass ('active');
        label.text ('Ok, make your guess!');
      } else {
        $mode = 'MODE_ELIMINATE';
        button.removeClass ('active');
        label.text (orig);
      }
    });
  })();
});
