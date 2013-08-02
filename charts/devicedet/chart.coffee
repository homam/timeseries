isPrime = (x) -> [2,3,5,7].indexOf(x) > -1
even = (x) -> x%2 == 0

h = (map, xs) -> map xs.filter (x) -> x<=5
g = (map, xs) -> _.chain(xs).groupBy(isPrime).map((arr) -> map arr).value()
f = (map, xs) -> _.chain(xs).groupBy(even).map((arr) -> map arr).value()

data = _.range(1,11)

hp = _.partial h, _.identity
gp = _.partial g, hp
fp = _.partial f, gp

console.log fp(data)



# convers the data array to a tree starting from root
pack = (root, data) ->
  data.forEach (d,i) ->
    if(d != null && d.wurfl_fall_back == root.wurfl_device_id)
      data = pack d, data
      root.children.push d
      data[i] = null
  data

makeTreeByParentId = (data) ->

  [0..data.length-1].forEach (i) ->
    d = data[i]
    if(!!d)
      data = pack data[i], data
    data = data.filter (d) -> d != null

  [0..data.length-1].forEach (i) ->
    addBack(data[i])

  data

# adds the root of tree back to the tree
addBack = (root) ->
  if(root.children.length > 0)
    root.children.forEach addBack
    root.children.push
      children: []
      wurfl_device_id: root.wurfl_device_id
      wurfl_fall_back: root.wurfl_fall_back
      brand_name: root.brand_name
      model_name: root.model_name
      conv: root.conv
      device_os :root.device_os
      visits: root.visits
      subscribers: root.subscribers


groupBy = (childrenMap, what, data) ->
  groups = _(data).groupBy what

  _(groups).map (darr) ->

    groupVisits = darr.map((d) -> d.visits).reduce((a,b)->a+b)
    groupSubs = darr.map((d) -> d.subscribers).reduce((a,b)->a+b)
    groupAverageConv = groupSubs / groupVisits
    groupStdevConversion = darr.map((g) ->
      Math.sqrt(Math.pow((g.conv-groupAverageConv), 2)) * g.visits / groupVisits
    )
    .reduce((a,b) -> a+b)

    return {
      averageConversion: groupAverageConv
      stdevConversion: groupStdevConversion
      children: childrenMap darr
    }


collectLongTail = (data) ->
  if (data.length<2)
    return data
  more = data.filter((d) ->d.visits <= 100)
  if(more.length < 2)
    return data
  moreVisits = more.map((d) -> d.visits).reduce((a,b)->a+b)
  moreSubs = more.map((d) -> d.subscribers).reduce((a,b)->a+b)
  data = data.filter (d) ->d.visits > 100
  data.push
    children: [],
    wurfl_fall_back: 'root'
    wurfl_device_id: 'more...'
    brand_name: 'more'
    model_name: '..'
    device_os :'any'
    visits: moreVisits
    subscribers: moreSubs
    conv : moreSubs/moreVisits
  data

groupByBrandName = (data) ->

  osF = _.partial groupBy, _.compose(makeTreeByParentId,collectLongTail), (d) ->d.device_os
  brandF = _.partial groupBy, osF, (d) -> d.brand_name

  return brandF(data)


chart = treeMapZoomableChart()
d3.select('#chart').call chart


d3.csv 'charts/devicedet/data/ae.csv', (raw) ->

  fresh = () ->
    raw.map (d) ->
      wurfl_device_id : d.wurfl_device_id
      wurfl_fall_back : d.wurfl_fall_back
      brand_name : d.brand_name
      model_name : d.model_name
      visits : +d.visits
      subscribers : +d.subscribers
      method : d.method
      conv : (+d.conv) or 0
      device_os :d.device_os
      children : []

  draw = (method, chartDataMap) ->
    chartData = fresh().filter ((d) -> method == d.method)


    totalVisits= chartData.map((d) -> d.visits).reduce((a,b)->a+b)
    totalSubs = chartData.map((d) -> d.subscribers).reduce((a,b)->a+b)
    totalConv= totalSubs/totalVisits
    totalStdevConv = chartData.map((g) ->
      Math.sqrt(Math.pow((g.conv-totalConv), 2)) * g.visits / totalVisits
    )
    .reduce((a,b) -> a+b)


    chartData = chartDataMap(chartData)

    window.chartData = chartData

    tree =
      children: chartData
      wurfl_device_id: 'root'
      brand_name: 'root'
      model_name: 'root'
      averageConversion: totalConv
      stdevConversion: totalStdevConv
      visits: 0


    chart.draw tree


  subMethods = _.chain(fresh()).map((d) -> d.method).uniq().value()

  d3.select('#submethods').data([subMethods])
  .on('change', () -> redraw())
  .selectAll('option').data((d) -> d)
  .enter().append('option').text((d) -> d)

  makeGroupByFunction = (order, treefy, cutLongTail) ->
    order = _(order).reverse()
    t = if treefy then makeTreeByParentId else _.identity
    l = if cutLongTail then collectLongTail else _.identity
    lastF = _.compose(t,l)
    order.forEach (p) ->
      lastF = _.partial groupBy, lastF, (d) -> d[p]
    lastF


  # how to call draw: draw subMethods[0],(makeGroupByFunction ['brand_name', 'device_os'], true, true)
  redraw = () ->
    groupBys = ($('#groupbys-bin').find('li').map () -> $(this).attr('data-groupby')).get()
    draw $("#submethods").val(),(makeGroupByFunction groupBys, true, true)

  redraw()

  $ () ->

    $('#groupbys-bin, #groupbys').sortable({
      connectWith: '.connected'
    })
    $('#groupbys-bin, #groupbys').on('dragend', () -> redraw());
