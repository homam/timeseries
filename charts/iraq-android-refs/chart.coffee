# creates an instance of a cumulative moving average function
movingAverage = (map) ->
  sum = 0
  return (d, i) ->
    sum += map(d)
    return sum / (i+1)

d3.csv 'charts/iraq-android-refs/data/iraq-android-refs.json', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.date = parseDate(d.date)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = +d.conv
    d

  window.data = data = data.filter (d) -> 'wap p155' == d.ref
  window.draw = () ->
    window.chart = d3.select('#chart1').datum(data).call timeSeriesChart()
      .x( (d) -> d.date)
      .y( (d) -> d.visits)

    smoother = movingAverage (d) -> d.visits

    d3.select('#chart2').datum(data).call timeSeriesChart()
      .x( (d) -> d.date)
      .y smoother

  draw()