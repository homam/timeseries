exports = exports ? this

exports.treeMapChart = () ->
  # configs
  margin =
    top: 0
    right: 0
    bottom: 0
    left: 0
  width = 1100
  height = 600

  color = d3.scale.category20()

  treemap = d3.layout.treemap()
  .size([width-margin.left-margin.right,height-margin.left-margin.right])
  .sticky(true)
  .value (d) -> d.visits

  position = () ->
    this
    .style('left', (d) -> d.x+ 'px')
    .style('top', (d) -> d.y+ 'px')
    .style('width', (d) -> Math.max(0, d.dx-1) + 'px')
    .style('height', (d) -> Math.max(0, d.dy-1) + 'px')

  chart = (selection) ->
    selection.each () ->
      $div = d3.select(this).append('div')
        .style("position", "relative")
        .style("width", (width) + "px")
        .style("height", (height) + "px")
        .style("left", margin.left + "px")
        .style("top", margin.top + "px");

      chart.draw = (root) ->
        node = $div.datum(root)
        .selectAll('.node').data(treemap.nodes)
        .enter().append('div').attr('class','node').call(position)
        .style('background', (d) -> if d.children.length > 0 then color(d.wurfl_device_id) else null)
        .text((d) ->
            if d.children.length > 0 then null else d.brand_name+' '+d.model_name)
        .attr('title', (d) -> d3.format('.2%')(d.conv))




  chart

