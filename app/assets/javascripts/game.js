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

  roll.click (function () {
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

  var you_lose = function () {
    alert ('YOO L0SE!');

    if (confirm ('Wanna play again?'))
      go.restart ();
    else
      go.abandon ();
  };

  var you_win = function () {
    alert ('FOR THE WIN!!!11');

    if (confirm ('Wanna play again?'))
      go.restart ();
  };


  var root = $('body');

  var people = $('.friend');
  people.click (function () {
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
        //
        you_lose ();
        break;
      }
    },

    'guesswho:guessed': function (event, person) {
      switch($mode) {
      case 'MODE_ELIMINATE':
        // Hide everyone except this one, that is the correct one.
        //
        people.filter (':not([id='+person.attr('id')+'])').fadeOut ();
        you_lose ();
        break;

      case 'MODE_GUESS':
        you_win ();
        break;
      }
    }
  });

  var restart = $('#new-game');
  restart.click (function () {
    if (confirm ('Sure, pal?'))
      go.restart ();
  });

  var go = {
    restart: function () {
      this.go ('#restart-url');
    },

    abandon: function () {
      this.go ('#abandon-url');
    },

    go: function (elem) {
      window.location.href = $(elem).val ();
    }
  };


  var i_got_it = $('#i-got-it');
  i_got_it.click (function () {
    if ($mode == 'MODE_ELIMINATE') {
      $mode = 'MODE_GUESS';
      i_got_it.addClass ('active');
      i_got_it.val ('GUESSING...');
    } else {
      $mode = 'MODE_ELIMINATE';
      i_got_it.removeClass ('active');
      i_got_it.val ('I got it!');
    }
  });
});
