exports.register = (app) ->
  app.get '/', (req, res) ->
    res.render '../charts/simple/view',
      title: 'Simple'

  app.get '/complex', (req, res) ->
    res.render '../charts/complex/view',
      title: 'Complex'

  app.get '/multi', (req, res) ->
    res.render '../charts/multi/view',
      title: 'Multi'

  app.get '/simple-updatable', (req, res) ->
    res.render '../charts/simple-updatable/view',
      title: 'simple updatable'

  app.get '/line-bar', (req, res) ->
    res.render '../charts/line-bar/view',
      title: 'line bar'