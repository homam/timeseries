d3.csv 'charts/simple/data/iraq-android-refs.json', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.date = parseDate(d.date)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = +d.conv
    d

  window.chart = simpleUpdatableTimeSeriesChart()
    .x( (d) -> d.date)
    .y( (d) -> d.visits)
  window.draw = () ->
    d3.select('#chart1').datum(data.filter (d) -> 'wap p155' == d.ref).call chart


  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };
  groups = _(data).groupBy (d) -> d.ref
  refs = _(groups).keys().map (ref) -> {ref: ref}

  #todo use d3 here too
  template = refs.map (r) -> _.template document.getElementById('refSelector-template').innerHTML, r
  document.getElementById('refSelector').innerHTML = template.reduce (a,b) -> a+b







  setTimeout ()->
    console.log 'update'
    chart.addLine data.filter (d) -> 'wap p11' == d.ref#, 'p11'
  , 2000

  draw()