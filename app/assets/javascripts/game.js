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
    var options = $.extend ({}, options)
    var buttons = options.buttons || {
      'Close': function () {
        go.abandon ();
      },
      'Play again!': function () {
        go.restart ();
      }
    };

    container.dialog ({
      width        : 400,
      height       : 220,
      modal        : true,
      resizable    : false,
      draggable    : false,
      closeOnEscape: false,
      dialogClass  : 'noclose',
      title        : container.find ('.title').text (),
      buttons      : buttons,

      open: function () {
        if (options.score)
          container.find ('.score').text (options.score);

        if (options.open)
          options.open.apply (this, [container]);

        if (options.profile) {
          var name = $('#'+options.profile).find ('.name .text').text ();
          var box  = $('#profile-link');
          var link = box.find ('a');

          link.attr ('href', link.attr ('href') + options.profile);
          link.text (name);

          container.append ('<br/>').append (box.html ());
        }
      }
    });
  };

  var you_lose = function (options) {
    dialog ('#wrong-dialog', {
      buttons: {
        'OK': function () {
          $(this).dialog ('close');

          reveal (options.reveal);

          setTimeout (function () { // FIXME use AnimationEnd event
            dialog ('#lose-dialog', {
              score  : options.score,
              profile: options.reveal,
              open   : function (container) {
                container.find (
                  options.score == 0 ? '.no-points' : '.points'
                ).show ();
              }
            });
          }, 3000);
        }
      }
    });
  };

  var you_win = function (options) {
    reveal (options.reveal)

    $.ajax ({
      type: 'PUT',
      url : go.to ('won')
    });

    dialog ('#win-dialog', {
      score:   options.score,
      profile: options.reveal
    });
  };


  // Reveals the mysterious friend
  //
  var reveal = function (id) {
    // Highlight
    var target = $('#'+id).addClass ('highlighted');
    // Flip and dim everyone else
    $('.friend:not(#'+id+')').addClass ('flipped flip-animation dimmed');
    // Scroll to
    $('html, body').animate ({'scrollTop': target.position().top - 150});
  };

  // API Client
  //
  game.on ('click', '.friend', function (event) {
    event.preventDefault ();

    var person = $(this);

    if (person.is ('.flipped'))
      return;

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
        person.addClass ('flipped flip-animation');

        // If only one remains, announce victory
        var remaining = $('.friend:not(.flipped)');
        if (remaining.length == 1)
          you_win ({score: score, reveal: remaining.attr ('id')});

        break;

      case 'MODE_GUESS':
        you_win ({score: score, reveal: person.attr ('id')});
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
