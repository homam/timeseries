exports = exports ? this

# creates an instance of a cumulative moving average function
cumulativeMovingAverage = (map) ->
  sum = 0
  return (d, i) ->
    sum += map(d)
    return sum / (i+1)

exports.timeSeriesChart = () ->
  # configs
  margin =
    top: 20
    right: 20
    bottom: 20
    left: 20
  width = 720
  height = 300
  xValue = (d) -> d[0]
  yValue = (d) -> d[1]

  # scale
  xScale = d3.time.scale()
  yScale = d3.scale.linear()

  # the standard data format will be [x,y]
  X = (d) -> xScale d[0]
  Y = (d) -> yScale d[1]

  # axis
  xAxis = d3.svg.axis().scale(xScale).orient('bottom').tickSize(6, 0)
  line = d3.svg.line().x(X).y(Y)

  chart = (selection) ->
    selection.each (raw) ->
      # convert data to the standard representation, to avoid the problem of
      # non-determinstic xValue and yValue s
      data = raw.map (d,i) -> [(xValue.call raw, d, i ), (yValue.call raw, d, i)]

      # update scales
      xScale.domain d3.extent data, (d) -> d[0]
      xScale.range [0, width - margin.left - margin.right]

      yScale.domain d3.extent data, (d) -> d[1]
      yScale.range [height - margin.top - margin.bottom, 0]

      # select the svg element
      svg = d3.select(this).selectAll('svg').data [data]

      # create the svg element, if it doesn't exits
      # and create the skeletal chart
      gEnter = svg.enter().append('svg').append('g')
      gEnter.append('path').attr 'class', 'line' # line
      gEnter.append('g').attr 'class', 'x axis'

      # update from configs
      svg.attr 'width', width
      svg.attr 'height', height
      g = svg.select('g').attr 'transform', 'translate(' +margin.left + ',' +margin.top + ')'

      # update the x-axis
      g.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')').call(xAxis)

      # update the line path, added transition for fun
      path = g.select('.line')#.attr 'd', line # line
      path.transition().attr 'd', line # line

  # updatable config options
  chart.margin = (value) -> margin = value ? margin; return chart
  chart.width = (value) -> width = value ? width; return chart
  chart.height = (value) -> height = value ? height; return chart
  chart.x = (map) -> xValue = map ? xValue; return chart
  chart.y = (map) -> yValue = map ? yValue; return chart;

  return chart




