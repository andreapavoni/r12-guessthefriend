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

  var people = $('.friend');

  people.click (function () {
    var person = $(this);

    $.ajax ({
      url: person.data ('url'),
      data: { id: person.data ('id') },

      statusCode: {
        200: function () { // OK, remove it
          person.fadeOut ();
        },

        418: function () { // YOU'RE A TEAPOT
          // Hide everyone except this one, that is the correct one.
          //
          people.filter (':not([id='+person.attr('id')+'])').fadeOut ();
          alert ('YOO L0SE!');
        }
      }
    });

  });
});
