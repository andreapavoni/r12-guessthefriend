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
      alert ('YOO L0SE!');

      if (confirm ('Wanna play again?'))
        go.restart ();
      else
        go.abandon ();
    }, 1000);
  };

  var you_win = function () {
    alert ('FOR THE WIN!!!11');

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
  var root = $('body');
  var people = $('.friend');
  people.click (function (event) {
    event.preventDefault ();

    var person = $(this);
    $.ajax ({
      url: person.data ('url'),
      data: { id: person.data ('id') },

      statusCode: {
        200: function () {
          $(root).trigger ('guesswho:excluded', [person]);
        },

        418: function () { // YOU'RE A TEAPOT
          $(root).trigger ('guesswho:guessed', [person]);
        },

        500: oh_so_sorry
      },
    });
  });

  $(root).bind({
    'guesswho:excluded': function (event, person) {
      switch($mode) {
      case 'MODE_ELIMINATE':
        // OK, hide the wrong one
        person.fadeOut ();

        if (people.filter (':visible').length == 1)
          you_win ();
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
            you_lose ({reveal: id});
          }
        });

        break;
      }
    },

    'guesswho:guessed': function (event, person) {
      switch($mode) {
      case 'MODE_ELIMINATE':
        // Hide everyone except this one, that is the correct one.
        //
        you_lose ({reveal: person.attr ('id')});
        break;

      case 'MODE_GUESS':
        you_win ();
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
