d3.csv 'charts/simple/data/iraq-android-refs.json', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.date = parseDate(d.date)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = +d.conv
    d


  groups = _(data).groupBy (d) -> d.ref
  refs = _.chain(groups).keys().map (ref) ->
    ref: ref
    visits: groups[ref].map((d) -> d.visits).reduce (a,b) -> a+b
  .sortBy((r) -> -r.visits).value()

  # add missing data points
  dateRange = d3.extent data.map (d) ->d.date
  msInaDay = 24*60*60*1000
  _.keys(groups).forEach (key) ->
    group = groups[key]
    index = -1
    for i in [+dateRange[0]..+dateRange[1]] by msInaDay
      ++index
      date = new Date(i)
      if !_(group).some( (d) -> Math.abs(+d.date - +date) < 1000)
        group.splice index, 0, {date: date, visits: 0, subs: 0, conv: 0}
        groups[key] = group



  visitsChart = lineBarTimeSeriesChart()
  .x( (d) -> d.date)
  .y( (d) -> d.visits)
  .yB( (d) -> d.subs)

  convChart = lineBarTimeSeriesChart()
  .x( (d) -> d.date)
  .y( (d) -> d.conv)
  .height(150)


  d3.select('#visitsChart').call visitsChart
  d3.select('#convChart').call convChart

  changeScale = false
  chartedData = groups['wap p155']
  d3.select('h1').text('wap p155')


  drawCharts = () ->

    scaleData = if changeScale then chartedData else data

    visitsChart.xScale d3.extent scaleData, (d) -> d.date
    visitsChart.yScale (d3.extent scaleData, (d) -> d.visits), 'Visits'
    visitsChart.addLine chartedData

    visitsChart.yBScale (d3.extent scaleData, (d) -> d.subs), 'Subs'
    visitsChart.addBar chartedData


    convChart.xScale d3.extent scaleData, (d) -> d.date
    convChart.yScale (d3.extent scaleData.filter((d) -> d.visits > 100), (d) -> d.conv), 'Conv'
    convChart.addLine chartedData


  drawCharts()

  d3.select('#changeScale').on('change', () ->
    changeScale =  this.checked
    drawCharts()
  )


  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };

  $ref = d3.select('#refSelector').selectAll('div.ref').data(refs)
  $ref.enter().append('div').attr('class', 'ref').attr('data-ref', (d) -> d.ref)
  $ref.append('input').attr('type', 'radio').attr('name', 'ref').attr('id', (d)->d.ref)
  .on('change',(d)->
      chartedData = groups[d.ref]
      drawCharts()
      d3.select('h1').text(d.ref)
      #convChart.addLine groups[d.ref]
  )
  $ref.append('label').attr('for', (d)->d.ref).text((d)->d.ref)

  d3.select('[data-ref="wap p155"] input').attr('checked', 'checked')


