console.log 'inside module.js'

define ['css!./hello.css', 'text!./hello.html'], (_css, html) ->
  return html

