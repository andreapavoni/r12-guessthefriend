// Game Engine.
//

Guesswho = {
  on_error: function () {
    alert ("Aw, Snap! Something went wrong - we apologize -_-");
  }
};

$(function () {
  var game = $('#game');

  // Next hint button
  //
  (function () {
    var target, label, orig;

    game.on ('click', '#next-hint', function (event) {
      event.preventDefault ();

      if (!game.hinter) {
        game.hinter = $(this);

        target = $(game.hinter.data ('target'));
        label  = game.hinter.find ('.text');
        orig   = label.text ();
      }

      $.ajax ({
        dataType: 'text',
        type    : 'get',
        url     : game.hinter.data ('url'),

        beforeSend: function () {
          label.text ('Loading...');
          target.addClass ('loading');
        },

        complete: function () {
          label.text (orig);
          target.removeClass ('loading');
        },

        success : function (data) {
          target.text (data);
        },

        error: Guesswho.on_error
      });
    });
  }) ();

  var dialog = function (selector, options) {
    var container = $(selector);
    var buttons = $.extend ({}, options).buttons || {
      'Close': function () {
        go.abandon ();
      },
      'Play again!': function () {
        go.restart ();
      }
    };

    container.dialog ({
      width     : 400,
      height    : 180,
      modal     : false,
      resizable : false,
      draggable : false,
      title     : container.find ('.title').text (),
      buttons   : buttons,

      open: function () {
        container.find ('.score').text (options.score);

        if (options.open)
          options.open.apply (this, [container]);
      }
    });
  };

  var you_lose = function (options) {
    reveal (options.reveal);

    setTimeout (function () { // FIXME use AnimationEnd event
      dialog ('#lose-dialog', {
        score: options.score,
        open : function (container) {
          container.find (
            options.score == 0 ? '.no-points' : '.points'
          ).show ();
        }
      });
    }, 3000);
  };

  var you_win = function (options) {
    var target = $('.friend:not(.flipped)');
    highlight (target.attr ('id')); // DIRTY

    $.ajax ({
      type: 'PUT',
      url : go.to ('won')
    });

    dialog ('#win-dialog', {
      score: options.score
    });
  };


  // Reveals the mysterious friend
  //
  var reveal = function (id) {
    $('.friend:not(#'+id+')').addClass ('flipped flip-animation');
    highlight (id);
  };

  var highlight = function (id) {
    $('#'+id).addClass ('highlighted');
    $('.friend:not(#'+id+')').addClass ('dimmed');
  };

  // API Client
  //
  game.on ('click', '.friend', function (event) {
    event.preventDefault ();

    var person = $(this);
    $.ajax ({
      url: game.data (game.mode == 'MODE_ELIMINATE' ? 'eliminate-url' : 'guess-url'),

      data: { id: person.attr ('id') },

      beforeSend: function () {
        person.addClass ('loading');
      },

      complete: function () {
        person.removeClass ('loading');
      },

      statusCode: {
        200: function (score) {
          game.trigger ('guesswho:success', [person, score]);
        },

        418: function (jqXHR) { // YOU'RE A TEAPOT
          game.trigger ('guesswho:failed', [person, jqXHR.responseText]);
        },

        500: Guesswho.on_error
      },
    });
  });

  $(game).on ({
    'guesswho:success': function (event, person, score) {
      switch(game.mode) {
      case 'MODE_ELIMINATE':
        // OK, hide the wrong one
        person.addClass ('flipped').addClass ('flip-animation');
        if ($('.friend:not(.flipped)').length == 1)
          you_win ({score: score});
        break;

      case 'MODE_GUESS':
        you_win ({score: score});
        break;
      }
    },

    'guesswho:failed': function (event, person, score) {
      switch(game.mode) {
      case 'MODE_ELIMINATE':
        // Hide everyone except this one, that is the correct one.
        //
        you_lose ({score: score, reveal: person.attr ('id')});
        break;

      case 'MODE_GUESS':
        // Oh no, you guessed the wrong one ;-)
        // Reveal the right one and fail.
        $.ajax ({
          url      : go.to ('reveal'),
          dataType : 'text',
          sync     : true,
          error    : Guesswho.on_error,
          success  : function (id) {
            you_lose ({score: score, reveal: id});
          }
        });
        break;
      }
    }
  });

  game.on ('click', '#new-game', function (event) {
    event.preventDefault ();

    dialog ('#abort-dialog', {
      buttons: {
        'Yes': function () {
          $(this).dialog ('close');

          $.ajax ({
            url      : go.to ('reveal'),
            dataType : 'text',
            sync     : true,
            error    : Guesswho.on_error,
            success  : function (id) {
              reveal (id);
              setTimeout (function () {
                dialog ('#another-try-dialog'); // CONVOLUTED
              }, 3000);
            }
          });
        },

        'No': function (event) {
          $(this).dialog ('close');
        }
      }
    })

  });

  // Router
  //
  var go = {
    restart: function () {
      this.go ('restart');
    },

    abandon: function () {
      this.go ('abandon');
    },

    go: function (url) {
      window.location.href = this.to (url);
    },

    to: function (url) {
      return game.data (url + '-url');
    }
  };


  // Mode switcher
  //
  game.mode = 'MODE_ELIMINATE';
  game.addClass ('eliminating');

  (function () {
    var label, orig;

    game.on ('click', '#i-got-it', function (event) {
      if (!game.switcher) {
        game.switcher = $(this);
        label = game.switcher.find ('.text');
        orig  = label.text ();
      }

      event.preventDefault ();

      if (game.mode == 'MODE_ELIMINATE') {
        game.mode = 'MODE_GUESS';
        game.switcher.addClass ('active');
        game.removeClass ('eliminating').addClass ('guessing');
        label.text ('Who\'s it?');
      } else {
        game.mode = 'MODE_ELIMINATE';
        game.switcher.removeClass ('active');
        game.removeClass ('guessing').addClass ('eliminating');
        label.text (orig);
      }
    });
  })();
});
