exports = exports ? this

exports.treeMapZoomableChart = () ->
  findParentWithProp = (d, prop) ->
    if(!d)
      return null
    if(d.hasOwnProperty(prop))
      return d[prop]
    return findParentWithProp d.parent, prop

  # configs
  margin =
    top: 0
    right: 0
    bottom: 0
    left: 0
  width = 1200
  height = 900

  awidth = width-margin.left-margin.right
  aheight = height-margin.top-margin.bottom

  formatConv = d3.format('.2%')
  formatNumber = d3.format(',')

  x = d3.scale.linear().range([0,awidth])
  y = d3.scale.linear().range([0,aheight])



  color = d3.scale.category20()

  treemap = d3.layout.treemap()
  .size([width-margin.left-margin.right,height-margin.left-margin.right])
  .round(false)
  .sticky(true)
  .value (d) -> d.visits

  rectWidth = (d) -> if d.dx>2 then d.dx-2 else 0
  rectHeight = (d) -> if d.dy>2 then d.dy-2 else 0

  #tooltip = d3tooltip(d3)


  chart = (selection) ->
    selection.each () ->
      $svg = d3.select(this).append('svg')
      .attr('class', 'chart')
      .attr("width", width).attr("height", height)
      .append("g").attr('transform', 'translate('+margin.top+','+margin.left+')')

      currentNode = null

      TopLeft = () ->
        _px = 0
        _py = 0
        _kx = 1
        _ky = 1
        return (px, py, kx, ky) ->
          if arguments.length > 0
            _px = px
            _py = py

            if(arguments.length > 1)
              _kx = kx
              _ky = ky

          x: _px
          y: _py
          kx: _kx
          ky: _ky
          xdomain: x.domain()
          ydomain: y.domain()

      topLeft = TopLeft()

      window.move = (px, py) ->
        if arguments.length == 0
          return topLeft()
        else
          tl = topLeft()
          kx = tl.kx
          ky = tl.ky


      zoom = (r, single = false) ->
        kx = awidth/ r.dx
        ky = aheight/ r.dy

        x.domain([r.x, r.dx+r.x])
        y.domain([r.y, r.dy+r.y])

        if single
          kx *= .5
          ky *= .5
          x.domain([r.x-r.dx*.5,1.5*r.dx+r.x])
          y.domain([r.y-r.dy*.5,1.5*r.dy+r.y])

        t = $svg.selectAll('.node').transition().duration(1500)
        .attr('transform', (d) -> "translate(" + x(d.x) + "," + y(d.y) + ")")

        t.select('rect')
        .attr('width', (d) -> kx*d.dx)
        .attr('height', (d) -> ky*d.dy)

        t.selectAll('text')
        .attr('x', (d) -> kx*d.dx/2)

        t.select('text.name').attr('y', (d) -> ky*d.dy/2).style('opacity', (d) -> if (kx * d.dx > d._tnamew) then 1 else 0)
        t.select('text.conv').attr('y', (d) ->.7*ky*d.dy).style('opacity', (d) -> if (kx * d.dx > d._tconvw) then 1 else 0)


        currentNode = r
        d3.event.stopPropagation()

      window.zoom = zoom



      chart.draw = (root) ->

        nodes = treemap.nodes(root).filter (d) -> d.children.length==0


        currentNode = root

        $node = $svg.selectAll('.node').data(nodes)
        .enter().append('g').attr('class','node')
        .on('click', (d) ->
            if(!d.parent || currentNode.wurfl_device_id == d.parent.wurfl_device_id)
                zoom(root)
            else
              zoom(d.parent)
        )
        .on('dblclick', (d) ->
            if(!d.parent || currentNode.wurfl_device_id == d.parent.wurfl_device_id)
              zoom(d, true)
            else
              zoom(d, true)
        )

        $node.attr('transform', (d) -> "translate(" + d.x + "," + d.y + ")")
        .call(d3.helper.tooltip()
          .attr('class', (d, i) -> d.wurfl_device_id)
          .style('color', 'blue')
          .text((d) ->
            avgConv = findParentWithProp d, 'averageConversion'
            stdevConv = findParentWithProp d, 'stdevConversion'
            html = d.brand_name+' '+d.model_name
            html += '<br/>' +d.wurfl_device_id
            html += '<br/>Visits: ' + formatNumber d.visits
            if d.conv < avgConv-stdevConv
              html += '<br/><span style="color:red">Conv: ' + (formatConv d.conv) + '</span>'
            else
              html += '<br/>Conv: ' + formatConv d.conv
            html += '<br/>Avg: ' + formatConv avgConv
            html += '<br/>SigmaAvg: ' + formatConv stdevConv
            html
          )
        )
        $node.append('rect')
        .attr('width', rectWidth).attr('height', rectHeight)
        .style('fill', (d) -> color(d.wurfl_device_id))
        .attr('stroke', (d) ->
          if d.conv < (findParentWithProp d, 'averageConversion')-(findParentWithProp d, 'stdevConversion')
            'red'
          else
            'white'
        )

        $node.append('text').attr('class', 'name')
        .attr('x', (d) -> d.dx/2).attr('y', (d) -> d.dy/2)
        .attr('dy', '.35em').attr('text-anchor', 'middle')
        .text((d) ->
            if d.children.length > 0
              return null
            d.brand_name+' '+d.model_name
        )
        .style('opacity', (d) ->
            d._tnamew = this.getComputedTextLength();
            if d.dx > d._tnamew then 1 else 0
        )
        $node.append('text').attr('class', 'conv')
        .attr('x', (d) -> d.dx/2).attr('y', (d) -> d.dy*.7)
        .attr('dy', '.35em').attr('text-anchor', 'middle')
        .text((d) ->
            if d.children.length > 0
              return null
            formatConv d.conv
        )
        .style('opacity', (d) ->
            d._tconvw = this.getComputedTextLength();
            if d.dx > d._tconvw then 1 else 0
        )



  chart

