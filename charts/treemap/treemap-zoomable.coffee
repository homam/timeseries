exports = exports ? this

exports.treeMapZoomableChart = () ->
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


  chart = (selection) ->
    selection.each () ->
      $svg = d3.select(this).append('svg')
      .attr('class', 'chart')
      .attr("width", width).attr("height", height)
      .append("g").attr('transform', 'translate('+margin.top+','+margin.left+')')

      currentNode = null

      zoom = (r, single = false) ->
        kx = awidth/ r.dx
        ky = aheight/ r.dy

        x.domain([r.x, r.dx+r.x])
        y.domain([r.y, r.dy+r.y])



        t = $svg.selectAll('.node').transition().duration(1500)
        .attr('transform', (d) -> "translate(" + x(d.x) + "," + y(d.y) + ")")

        t.select('rect')
        .attr('width', (d) -> kx*d.dx)
        .attr('height', (d) -> ky*d.dy)

        t.select('text')
        .attr('x', (d) -> kx*d.dx/2)
        .attr('y', (d) -> ky*d.dy/2)
        .style('opacity', (d) -> if (kx * d.dx > d._tw) then 1 else 0)

        currentNode = r
        d3.event.stopPropagation()

      window.zoom = zoom



      chart.draw = (root) ->

        nodes = treemap.nodes(root).filter (d) -> d.children.length==0


        currentNode = root

        $node = $svg.selectAll('.node').data(nodes)
        .enter().append('g').attr('class','node')
        .on('dblclick', (d) ->
            if(!d.parent || currentNode.wurfl_device_id == d.parent.wurfl_device_id)
                zoom(root)
            else
              zoom(d.parent)
        )
        .on('click', (d) ->
            console.log currentNode.wurfl_device_id, if d.parent then d.parent.wurfl_device_id else ''
            if(!d.parent || currentNode.wurfl_device_id == d.parent.wurfl_device_id)
              zoom(d, true)
            else
              zoom(d.parent)
        )

        $node.attr('transform', (d) -> "translate(" + d.x + "," + d.y + ")")
        $node.append('rect')
        .attr('width', rectWidth).attr('height', rectHeight)
        .style('fill', (d) -> color(d.wurfl_device_id))
        .attr('stroke', 'white')

        $node.append('text')
        .attr('x', (d) -> d.dx/2).attr('y', (d) -> d.dy/2)
        .attr('dy', '.35em').attr('text-anchor', 'middle')
        .text((d) ->
            if d.children.length > 0
              return null
            d.brand_name+' '+d.model_name
        )
        .style('opacity', (d) ->
            d._tw = this.getComputedTextLength();
            if d.dx > d._tw then 1 else 0
        )



  chart

