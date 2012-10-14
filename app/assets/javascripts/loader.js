$(function () {
  var loader = $('#stalk');
  if (loader.length == 0)
    return;

  $.ajax ({
    type    : 'get',
    dataType: 'html',
    url     : loader.data ('url'),
    error   : Guesswho.on_error,

    success : function (data) {
      var target = $(loader.data ('target'));
      target.html (data)
    }
  });
});
