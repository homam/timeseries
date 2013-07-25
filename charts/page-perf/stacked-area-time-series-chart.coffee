exports = exports ? this

exports.stackedAreaimeSeriesChart = () ->
  # configs
  margin =
    top: 20
    right: 40
    bottom: 20
    left: 50
  width = 720
  height = 300

  xMap = (d) -> d[0]
  yMap = (d) -> d[1]

  xScale = d3.time.scale()
  yScale = d3.scale.linear()

  keyMap = (d) -> d['key']
  valuesMap = (d) -> d['values']
  keyFilter = (d) -> true
  stackOffset = 'zero'


  X = (d) -> xScale d
  Y = (d) -> yScale d


  line = d3.svg.line().interpolate('basis').x(X).y(Y)


  chart = (selection) ->
    selection.each (raw) ->

      xScale.range([0, width - margin.left - margin.right])
      yScale.range([height - margin.top - margin.bottom, 0])

      xAxis = d3.svg.axis().scale(xScale).orient('bottom')
      .tickSize(-height+margin.top+margin.bottom,0,0)
      #.tickFormat((d) -> d.getDate() + '/' + d.getMonth())

      yAxis = d3.svg.axis().scale(yScale).orient('left')
      .tickSize(-width+margin.left+margin.right,0,0)


      $svg = d3.select(this).append('svg')
      .attr('width', width).attr('height', height)
      .append('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")")


      # horizontal axis
      $svg.append('g').attr('class', 'x axis')
      $svg.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')')
      #.call(xAxis)

      # line axis
      $svg.append('g').attr('class', 'y axis line')
      $svg.select('.y.axis.line')
      .append('text').attr('transform', 'translate(20,0) rotate(90)')
      .attr('y', 6).attr('dy', '.71em').style('text-anchor', 'start')
      .text('Y')

      area = d3.svg.area().x((d) -> X(d.day)).y0((d) -> Y(d.y0)).y1((d) -> Y(d.y0 + d.y))


      chart.addStack = (data) ->

        stack = d3.layout.stack()
        .offset(stackOffset)
        .x(xMap).y(yMap)
        .values(valuesMap)

        layers = stack(data)


        keys = data.map(keyMap).filter(keyFilter)


        # set the y and y0 position of filtered out keys to 0, so keep the path for animation purpose but its area will be 0
        layers = layers.map (layer) ->
          if keys.indexOf(keyMap layer) < 0
            (valuesMap layer).map (d) ->
              d.y = d.y0 = 0
              d
          layer

        xScale.domain d3.extent valuesMap(layers[0]), xMap
        $svg.select('.x.axis').transition().duration(1500).ease("sin-in-out").call(xAxis)

        scaleLayers = stack(data.filter (d) -> keyFilter keyMap d)
        yScale.domain [0, d3.max(scaleLayers, (l) -> d3.max(valuesMap(l), (d) -> d.y0+d.y))]
        $svg.select('.y.axis.line').transition().duration(1500).ease("sin-in-out").call(yAxis)
        $svg.select('.y.axis.line > text').text(label ? '')


        $layer = $svg.selectAll('.layer').data(layers)
        $layer.enter().append('g').attr('class', 'layer')
        $layer.style('fill', (d) ->d.color)
        .transition().duration(500).ease("sin-in-out").delay(200)
        .style('opacity', (d) -> if (keys.indexOf(keyMap(d))<0) then 0 else 1)

        $path = $layer.selectAll('path.area').data((d) -> [valuesMap(d)])
        $path.enter().append('path').attr('class', 'area')
        $path.style('fill', (d) -> d.color)
        $path.transition().duration(1000).ease("sin-in-out")
        .attr('d', area)








  chart.key = (map) -> keyMap = map ? keyMap; return chart;
  chart.keyFilter = (filter) -> keyFilter = filter ? keyFilter; return chart;
  chart.values = (map) -> valuesMap = map ? valuesMap; return chart;
  chart.stackOffset = (val) -> stackOffset = val ? stackOffset; return chart;
  chart.x = (map) -> xMap = map ? xMap; return chart
  chart.y = (map) -> yMap = map ? yMap; return chart;


  chart.height = (val) -> height = val ? height; return chart;

  return chart