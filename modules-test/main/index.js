// Generated by CoffeeScript 1.6.2
(function() {
  require.config({
    baseUrl: '',
    map: {
      '*': {
        'css': 'libs/require-css/css',
        'text': 'libs/require-text'
      }
    }
  });

  require(['modules/hello/module'], function(html) {
    return $("body").append($(html));
  });

}).call(this);
