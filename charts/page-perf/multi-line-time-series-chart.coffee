exports = exports ? this

exports.multiLineTimeSeriesChart = () ->
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


  mouseEvents = d3.dispatch('mouseover', 'mouseout')


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



      chart.addStack = (raw) ->

        # clone the raw data
        data = raw.map (g) ->
          key: keyMap g
          color: g.color #todo use colorMap
          values: (valuesMap g).map (d) -> [xMap(d), yMap(d)]

        keys = data.map((g) -> g.key).filter(keyFilter)

        line = d3.svg.line().interpolate('basis')
        .x((d) -> xScale d[0]).y((d) -> yScale d[1])

        layers = data

        # set the y and y0 position of filtered out keys to 0, so keep the path for animation purpose but its area will be 0
        layers = layers.map (layer) ->
          if keys.indexOf(layer.key) < 0
            layer.values.map (d) ->
              d[1] = 0
              d
          layer

        xScale.domain d3.extent layers[0].values.map((d) -> d[0])
        $svg.select('.x.axis').transition().duration(1500).ease("sin-in-out").call(xAxis)

        scaleLayers = (data.filter (g) -> keys.indexOf(g.key) >-1)
        yScale.domain [0, d3.max(scaleLayers, (g) -> d3.max(g.values, (d) -> d[1]))]
        $svg.select('.y.axis.line').transition().duration(1500).ease("sin-in-out").call(yAxis)
        $svg.select('.y.axis.line > text').text(label ? '')


        $line = $svg.selectAll('.data.line').data(layers)
        $line.enter().append('path').attr('class', 'data line')
        $line.attr('data-key', (d) -> d.key).style('stroke', (d) ->d.color)
        .on('mouseover', (d) -> mouseEvents.mouseover d.key )
        .on('mouseout', (d) -> mouseEvents.mouseout d.key )
        $line.transition().duration(500).attr('d', (d) -> line(d.values))
        .style('opacity', (d) ->
            if (keys.indexOf(d.key)<0) then 0 else 1
        )




  chart.mouseover = (delegate) -> mouseEvents.on('mouseover', delegate); return chart;
  chart.mouseout = (delegate) -> mouseEvents.on('mouseout', delegate); return chart;
  chart.key = (map) -> keyMap = map ? keyMap; return chart;
  chart.keyFilter = (filter) -> keyFilter = filter ? keyFilter; return chart;
  chart.values = (map) -> valuesMap = map ? valuesMap; return chart;
  chart.x = (map) -> xMap = map ? xMap; return chart
  chart.y = (map) -> yMap = map ? yMap; return chart;


  chart.height = (val) -> height = val ? height; return chart;

  return chart