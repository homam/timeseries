#bar-groups-stacked

define ['../common/property'], (Property) ->
  () ->
    # configs
    margin =
      top: 20
      right: 0
      bottom: 20
      left: 70
    width = 720
    height = 300


    x = d3.scale.ordinal().rangeRoundBands([0,width], .1)
    #x1 = d3.scale.ordinal()
    y = d3.scale.linear().range([height,0])

    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(d3.format(','))
    .tickSize(-width,0,0)


    mainNameMap = (d) ->d.name
    subNameMap = (d) ->d.name
    mainValuesMap  = (d) ->d.values
    subValueMap = (d)->d.value

    colorMap = d3.scale.category10()

    color = d3.scale.category10()

    tooltip = () ->


    dispatch = d3.dispatch('mouseover', 'mouseout')



    # configurable properties

    properties = {
      width: new Property (value) ->
        width = value - margin.left-margin.right
        x.rangeRoundBands([0,width], .1)
        yAxis.tickSize(-width,0,0)

      height: new Property (value) ->
        height = value - margin.top-margin.bottom
        y.range([height,0])

      margin: new Property (value) ->
        margin = _.extend margin, value # value might be missing some margins (like right, top ...)
        properties.width.reset() # width and height depend on margin
        properties.height.reset()

      yAxisTickFormat: new Property (value) ->
        yAxis.tickFormat(value)

      mainNames : new Property (value) -> mainNameMap = value

      mainValues : new Property (value) ->mainValuesMap = value

      subNames : new Property (value) -> subNameMap = value

      subValues : new Property (value) ->subValueMap = value

      stackOffset : new Property

      transitionDuration:  new Property

      tooltip : new Property (value) -> tooltip = value
    }

    properties.width.set(width)
    properties.height.set(height)
    properties.stackOffset.set('zero')
    properties.transitionDuration.set(500)


    chart = (selection) ->
      selection.each (data) ->


        allSubKeys = _.uniq _.flatten data.map((d) -> mainValuesMap(d).map((i) -> subNameMap(i)))

        data.forEach (d) ->
          y0 = 0
          d._children = allSubKeys.map (name) ->
            name: name
            y0: y0
            y1: y0 += subValueMap mainValuesMap(d).filter((a) -> subNameMap(a) == name)[0]
          d._total = _.last(d._children).y1

        data.sort((a, b) -> b._total - a._total)


        allMainKeys = _.flatten data.map mainNameMap




        x.domain(allMainKeys)
        y.domain([0, d3.max(data, (d) -> d._total)]);

        $selection = d3.select(this)

        $svg = $selection.selectAll('svg').data([data])
        $gEnter = $svg.enter().append('svg').append('g')

        $svg.attr('width', width+margin.left+margin.right).attr('height', height+margin.top+margin.bottom)
        $g = $svg.select('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")")


        $gEnter.append('g').attr('class', 'x axis')
        $xAxis = $svg.select('.x.axis').attr("transform", "translate(0," + (height)+ ")")

        $gEnter.append('g').attr('class', 'y axis')
        $yAxis = $svg.select('.y.axis')


        $main = $g.selectAll(".main")
        .data(data)
        .enter().append("g")
        .attr("class", "main")
        .attr("transform", (d) ->  "translate(" + x(mainNameMap(d)) + ",0)");


        $main.selectAll("rect")
        .data((d) -> d._children)
        .enter().append("rect")
        .attr("width", x.rangeBand())
        .attr("y", (d) -> y(d.y1))
        .attr("height", (d) -> y(d.y0) - y(d.y1))
        .style("fill", (d) -> colorMap(subNameMap(d)));







        $xAxis.transition().duration(200).call(xAxis)
        $yAxis.transition().duration(200).call(yAxis)

        $legend = $g.selectAll('.legend').data(allSubKeys)
        $legendEnter = $legend.enter().append('g').attr('class', 'legend')
        $legend.attr('transform', (d,i) -> "translate(0," + (i*20-margin.top) + ")")



        $legendEnter.append('rect')
        $legend.select('rect')
        .attr('x', width-18).attr('width', 18).attr('height', 18)
        .style('fill', (d) -> color allSubKeys.indexOf(d))
        $legendEnter.append('text')
        $legend.select('text')
        .attr('x', width-24).attr('y', 9).attr('dy', '.35em').style('text-anchor', 'end')
        .text((d) -> d)

        null # selection.each()
    null # chart()




    # expose the properties

    chart = Property.expose(chart, properties)
    chart.mouseover = (handler) -> dispatch.on('mouseover', handler)

    return chart