require.config({
  baseUrl: ''
  map:
    '*':
      'css': 'libs/require-css/css'
      'text': 'libs/require-text'
})


# this too works: /modules-test/modules/hello/module.js
require ['modules/hello/module'], (html) ->
  $("body").append($(html))