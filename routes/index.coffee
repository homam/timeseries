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

  app.get '/nv-page-perf', (req, res) ->
    res.render '../charts/nv-page-perf/view',
      title: 'nv page perf'

  app.get '/page-perf-bar', (req, res) ->
    res.render '../charts/page-perf/view-bar',
      title: 'page perf bar'

  app.get '/page-perf', (req, res) ->
    res.render '../charts/page-perf/view',
      title: 'Campaign Pages Performance'

  app.get '/treemap', (req, res) ->
    res.render '../charts/treemap/view',
      title: 'Tree Map'
