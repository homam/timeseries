exports = exports ? this

class LineGroup
  # maps: array of y map
  constructor: (yScale, maps) ->
    @yScale = yScale
    @maps = maps


exports.complexTimeSeriesChart = () ->
  lines = [[]]; # array of groups of lines, groupbed by scale

  # configs
  margin =
    top: 20
    right: 20
    bottom: 20
    left: 20
  width = 720
  height = 300
  xValue = (d) -> d[0]
  yValues = [((d) -> d[1]), ((d) -> d[1])]

  # scale
  xScale = d3.time.scale()
  yScale = d3.scale.linear()

  # the standard data format will be [x,y]
  X = (d) -> xScale d[0]
  Ys = yValues.map (_,i) -> (d) ->
    yScale _(d)[i]
  #Y = (d) -> yScale d[1]

  # axis
  xAxis = d3.svg.axis().scale(xScale).orient('bottom').tickSize(6, 0)
  lines = yValues.map (_,i) -> d3.svg.line().x(X).y(Ys[i])

  chart = (selection) ->
    selection.each (raw) ->
      # convert data to the standard representation, to avoid the problem of
      # non-determinstic xValue and yValue s
      data = raw.map (d,i) -> [xValue.call(raw, d, i), yValues.map (yValue) -> yValue.call(raw, d, i)]

      # update scales
      xScale.domain d3.extent data, (d) -> d[0]
      xScale.range [0, width - margin.left - margin.right]

      yScale.domain d3.extent data, (d) -> d[1][0]
      yScale.range [height - margin.top - margin.bottom, 0]

      # select the svg element
      svg = d3.select(this).selectAll('svg').data [data]

      # create the svg element, if it doesn't exits
      # and create the skeletal chart
      gEnter = svg.enter().append('svg').append('g')
      gEnter.append('g').attr 'class', 'x axis'
      g = svg.select('g')
      yValues.forEach (_,i) ->
        gEnter.append('path').attr 'class', 'line line-' + i # line
        # update the line path
        g.select('.line-' + i).attr 'd', lines[i] # line

      # update from configs
      svg.attr 'width', width
      svg.attr 'height', height
      g.attr 'transform', 'translate(' +margin.left + ',' +margin.top + ')'

      # update the x-axis
      g.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')').call(xAxis)



  # updatable config options
  chart.margin = (value) -> margin = value ? margin; return chart
  chart.width = (value) -> width = value ? width; return chart
  chart.height = (value) -> height = value ? height; return chart
  chart.x = (map) -> xValue = map ? xValue; return chart
  chart.ys = (map) -> yValues = map ? yValues; return chart;

  return chart




