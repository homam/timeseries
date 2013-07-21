d3.csv 'charts/simple/data/iraq-android-refs.json', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.date = parseDate(d.date)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = +d.conv
    d

  window.chart = simpleUpdatableTimeSeriesChart()
    .x( (d) -> d.date)
    .y( (d) -> d.visits)
  window.draw = () ->
    d3.select('#chart1').datum(data.filter (d) -> 'wap p155' == d.ref).call chart


  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };

  groups = _(data).groupBy (d) -> d.ref
  refs = _(groups).keys().map (ref) ->
    ref: ref
    visits: groups[ref].map((d) -> d.visits).reduce (a,b) -> a+b

  refs = _.sortBy(refs, (r) -> -r.visits)


  $ref = d3.select('#refSelector').selectAll('div.ref').data(refs)
  $ref.enter().append('div').attr('class', 'ref').attr('data-ref', (d) -> d.ref)
  $ref.append('input').attr('type', 'radio').attr('name', 'ref').attr('id', (d)->d.ref)
  .on('change', (d)-> chart.addLine data.filter (a) -> d.ref == a.ref)
  $ref.append('label').attr('for', (d)->d.ref).text((d)->d.ref)

  d3.select('[data-ref="wap p155"] input').attr('checked', 'checked')


  draw()