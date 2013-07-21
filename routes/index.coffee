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