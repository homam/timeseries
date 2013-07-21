# creates an instance of a cumulative moving average function
cumalativeMovingAverage = (map) ->
  sum = 0
  return (d, i) ->
    sum += map(d)
    return sum / (i+1)

movingAverage = (map, size) ->
  arr = []
  return (d, i) ->
    if arr.length >= size
      arr = arr.slice 1
    arr.push map(d)
    val = (arr.reduce (a,b) -> a+b) / (arr.length)
    return val

d3.csv 'charts/simple/data/iraq-android-refs.json', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.date = parseDate(d.date)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = +d.conv
    d

  window.data = data = data.filter (d) -> 'wap p155' == d.ref

  cumulativeSmoother = cumalativeMovingAverage (d) -> d.visits
  smoother = movingAverage ((d) -> d.visits) , 7

  window.draw = () ->
    window.chart = d3.select('#chart1').datum(data).call complexTimeSeriesChart()
      .x( (d) -> d.date)
      .ys([((d) -> d.visits), smoother, cumulativeSmoother])


  draw()