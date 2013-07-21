d3.csv 'charts/simple/data/iraq-android-refs.json', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.date = parseDate(d.date)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = +d.conv
    d

  #window.data = data = data.filter (d) -> 'wap p155' == d.ref || 'wap p11' == d.ref || 'wap p9' == d.ref
  window.c = multiTimeSeriesChart()
    .x( (d) -> d.date)
    .y( (d) -> d.visits)
  window.draw = () ->
    window.chart = d3.select('#chart1').datum(data).call c


  draw()