class Property
  constructor: (@_onSet) ->
  _value: null
  set: (value)->
    this._value = value
    this._onSet(value)
  get: () ->
    this._value
  reset: () ->
    this.set(this._value)

define [], () ->

  () ->
    # configs
    margin =
      top: 20
      right: 0
      bottom: 20
      left: 70
    width = 720
    height = 300


    x = d3.scale.ordinal()
    y = d3.scale.linear()

    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(d3.format(','))


    nameMap = (d) ->d.name
    valueMap  = (d) ->d.value
    devMap = (d) ->d.dev


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
        margin = value
        properties.width.reset()
        properties.height.reset()

      names : new Property (value) -> nameMap = value

      values : new Property (value) ->valueMap = value

      devs : new Property (value) -> devMap = value
    }

    properties.width.set(width)
    properties.height.set(height)

    chart = (selection) ->
      selection.each (data) ->

        $selection = d3.select(this)

        $svg = $selection.selectAll('svg').data([data])
        $gEnter = $svg.enter().append('svg').append('g')

        $svg.attr('width', width+margin.left+margin.right).attr('height', height+margin.top+margin.bottom)
        $g = $svg.select('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")")


        $gEnter.append('g').attr('class', 'x axis')
        $xAxis = $svg.select('.x.axis').attr("transform", "translate(0," + (height)+ ")")

        $gEnter.append('g').attr('class', 'y axis')
        $yAxis = $svg.select('.y.axis')



        keys = _.flatten data.map nameMap
        x.domain(keys)
        y.domain([0, d3.max data.map valueMap ])

        $main = $g.selectAll('.main').data(data)
        $main.enter().append('g').attr('class','main').append('rect').attr('class', 'conv')
        $main.transition().duration(200)

        $rect = $main.select('rect.conv')
        $rect.transition().duration(200).attr('width', x.rangeBand())
        .attr('x', (d) -> x(nameMap(d)))
        .attr('y', (d) -> y(valueMap(d)))
        .attr('height', (d)-> height-y(valueMap(d)))
        .style('fill', (d,i)-> '#ff7f0e')

        $main.exit().select('rect').attr('y', 0).attr('height', 0)

        $xAxis.transition().duration(200).call(xAxis)
        $yAxis.transition().duration(200).call(yAxis)


        return
        chart.draw = (data) ->



          # start standard deviation lines

          #        $devG = $main.selectAll('g.dev').data(mainValueMap)
          #        $devG.enter().append('g').attr('class', 'dev')
          #        $devG.transition().duration(200)
          #        .attr('transform', (d) -> 'translate(0,'+(-height+y(mainValueMap(d))-(-height+y(subValueDevMap(d)))/2)+')')
          #
          #        $devUpperLine = $devG.selectAll('line.dev.up').data((d) -> [d])
          #        $devUpperLine.enter().append('line').attr('class', 'dev up')
          #        $devUpperLine.transition().duration(200)
          #        .attr('x1', _.compose(x1, subNameMap)).attr('x2', (d) -> _.compose(x1, subNameMap)(d)+x1.rangeBand())
          #        .attr('y1', _.compose y, subValueDevMap).attr('y2', _.compose y, subValueDevMap)
          #
          #        $devLowerLine = $devG.selectAll('line.dev.low').data((d) -> [d])
          #        $devLowerLine.enter().append('line').attr('class', 'dev low')
          #        $devLowerLine.transition().duration(200)
          #        .attr('x1', _.compose(x1, subNameMap)).attr('x2', (d) -> _.compose(x1, subNameMap)(d)+x1.rangeBand())
          #        .attr('y1', (d) -> y(0)).attr('y2', (d) -> y(0))
          #
          #        $devrect = $devG.selectAll('rect.dev').data((d) -> [d])
          #        $devrect.enter().append('rect').attr('class', 'dev')
          #        $devrect.transition().duration(200).attr('width', x1.rangeBand()*.25)
          #        .attr('x', (d) -> x1(subNameMap(d))+x1.rangeBand()*.375)
          #        .attr('y', _.compose y, subValueDevMap)
          #        .attr('height', (d)-> height- (_.compose y, subValueDevMap)(d))
          #
          #        $devG.exit().select('rect').attr('height', 0).attr('y', () ->0).attr('width', 0)
          #        $devG.exit().selectAll('line').attr('y1', 0).attr('y2', 0)

          # end standard deviation lines




        null




      # expose the properties

      d3.keys(properties).forEach (k) ->
        p = properties[k]
        chart[k] = (val) ->
          if(!!arguments.length)
            p.set(val)
            chart
          else
            p.get()

    return chart