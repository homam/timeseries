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
  width = screen.availWidth
  height = d3.min([screen.availHeight-300, screen.availHeight*.5])

  awidth = width-margin.left-margin.right
  aheight = height-margin.top-margin.bottom

  formatConv = d3.format('.2%')
  formatNumber = d3.format(',')

  x = d3.scale.linear().range([0,awidth])
  y = d3.scale.linear().range([0,aheight])



  color = d3.scale.quantile()
  .range ['#ffe866', '#fefd69', '#eafd6d', '#d5fc70', '#c2fa74', '#b1f977', '#a0f87a', '#91f77e', '#83f681', '#84f592', '#87f4a4', '#8af2b5', '#8df1c4', '#90f0d3', '#93efe0', '#96eeec', '#99e3ed', '#9cd7eb', '#9fccea', '#a2c3e9']



  rectWidth = (d) -> if d.dx>2 then d.dx-2 else 0
  rectHeight = (d) -> if d.dy>2 then d.dy-2 else 0

  mouseEvents = d3.dispatch('zoomed')

  chart = (selection) ->
    selection.each () ->
      $svg = d3.select(this).append('svg')
      .attr('class', 'chart')
      .attr("width", width).attr("height", height)
      .append("g").attr('transform', 'translate('+margin.top+','+margin.left+')')

      currentNode = null

      zoom = (r, single = false) ->
        mouseEvents.zoomed r
        kx = awidth/ r.dx
        ky = aheight/ r.dy

        x.domain([r.x, r.dx+r.x])
        y.domain([r.y, r.dy+r.y])

        if single
          kx *= .5
          ky *= .5
          x.domain([r.x-r.dx*.5,1.5*r.dx+r.x])
          y.domain([r.y-r.dy*.5,1.5*r.dy+r.y])

        t = $svg.selectAll('.node.visible').transition().duration(1500)
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

        color.domain([0, root.averageConversion+2*root.stdevConversion])

        treemap = d3.layout.treemap()
        .size([width-margin.left-margin.right,height-margin.left-margin.right])
        .round(false)
        .padding(1)
        .sticky(false)
        .value (d) -> d.visits

        nodes = treemap.nodes(root).filter (d) -> d.children.length==0


        currentNode = root

        $node = $svg.selectAll('.node').data(nodes)

        $enterNode = $node.enter().append('g').attr('class','node visible')
        $node.on('click', (d) ->
          alt = d3.event.altKey
          if alt
            zoom(d, true)
          else
            if(!d.parent || currentNode.wurfl_device_id == d.parent.wurfl_device_id)
                zoom(root)
            else
              zoom(d.parent)
        )


        $node.attr('class','node visible')
        .attr('transform', (d) -> "translate(" + d.x + "," + d.y + ")")
        .call(d3.helper.tooltip()
          .text((d) ->
            avgConv = findParentWithProp d, 'averageConversion'
            stdevConv = findParentWithProp d, 'stdevConversion'
            d._badConverting = d.conv == 0 or d.conv < avgConv-stdevConv

            html = d.brand_name+' '+d.model_name
            html += '<br/>' +d.wurfl_device_id
            html += '<br/>' + d.wurfl_fall_back
            html += '<br/>' + d.device_os;
            html += '<br/><br/>Visits: ' + formatNumber d.visits
            html += '<br/>Subs: ' + formatNumber d.subscribers
            if d._badConverting
              html += '<br/><span style="color:red">Conv: ' + (formatConv d.conv) + '</span>'
            else
              html += '<br/>Conv: ' + formatConv d.conv
            html += '<br/><br/>Avg: ' + formatConv avgConv
            html += '<br/>SigmaAvg: ' + formatConv stdevConv
            html
          )
        ).classed('bad', (d) ->
          avgConv = findParentWithProp d, 'averageConversion'
          stdevConv = findParentWithProp d, 'stdevConversion'
          d._badConverting = d.conv == 0 or d.conv < avgConv-stdevConv
          false && d._badConverting
        )

        $enterNode.append('rect')
        $node.select('rect')
        .style('fill', (d) -> color(d.conv))
        .attr('data-wid', (d)->d.wurfl_device_id)
        .transition().duration(200).attr('width', rectWidth).attr('height', rectHeight)

        $enterNode.append('text').attr('class', 'name')
        $node.select('text.name').attr('x', (d) -> d.dx/2).attr('y', (d) -> d.dy/2)
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
        $enterNode.append('text').attr('class', 'conv')
        $node.select('text.conv').attr('x', (d) -> d.dx/2).attr('y', (d) -> d.dy*.7)
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


        $node.exit().attr('class', 'node').select('rect').transition().duration(200).attr('width', 0).attr('height', 0)
        $node.exit().selectAll('text').text(null)

  chart.zoomed = (delegate) -> mouseEvents.on('zoomed', delegate); return chart;
  chart

