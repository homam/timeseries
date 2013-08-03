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


sum = (arr) ->
  if(arr.length == 0)
    return 0
  if (arr.length == 1)
    return arr[0]
  return arr.reduce((a,b) ->a+b)



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
    root.visits = 0
    root.subscribers = 0
    root.conv = 0


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
    collected_children: more
  data

groupByBrandName = (data) ->

  osF = _.partial groupBy, _.compose(makeTreeByParentId,collectLongTail), (d) ->d.device_os
  brandF = _.partial groupBy, osF, (d) -> d.brand_name

  return brandF(data)


chart = treeMapZoomableChart()
d3.select('#chart').call chart


subMethodDeviceChart = new groupedBarsChart()
d3.select('#submethodDevice-chart').call subMethodDeviceChart

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

  #sanity check: console.log sum fresh().filter((d) -> d.method == 'WAPPIN').map((d) -> d.subscribers)

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
    draw $("#submethods").val(),(makeGroupByFunction groupBys, $('#treefy')[0].checked, $('#collectLongTail')[0].checked)

  redraw()


  $ () ->

    $('#groupbys-bin, #groupbys').sortable({
      connectWith: '.connected'
    })
    $('#groupbys-bin, #groupbys').on('dragend', () -> redraw())

    $('#treefy, #collectLongTail').on('change', () -> redraw())



  createSubMethodDeviceHierarchy = (wurflIds, name) ->
    data = fresh().map (d) ->
      method: d.method,
      device: (if wurflIds.indexOf(d.wurfl_device_id)>-1  then name else 'Everything Else'),
      visits: d.visits
      subscribers: d.subscribers
      conv: d.conv

    mainGroupMap = (d) ->d.method
    subGroupsMap = (d) ->d.device

    parts = _.chain(data).groupBy(mainGroupMap).value()

    hierarchy = _(parts).map (arr, key) ->
      name: key
      value: _.chain(arr).groupBy(subGroupsMap).map((sarr, skey) ->
        # filter only converting devices: sarr = sarr.filter (d) -> d[2].subscribers >0
        subGroupVisits = sum(sarr.map (a) -> a.visits)
        mu = if sarr.length ==0 then 0 else sum(sarr.map (a) -> a.subscribers)/subGroupVisits
        name: skey
        value: mu
        stdev: if sarr.length <2 then 0 else sum( sarr.map (d) -> Math.sqrt(Math.pow(d.conv-mu,2)) *d.visits/subGroupVisits)

      ).value()



    # add missing values

    mainValueMap = (v) ->v.value
    subNameMap = (v)->v.name
    allSubKeys = _.uniq _.flatten hierarchy.map((d) -> mainValueMap(d).map subNameMap)


    hierarchy = hierarchy.map (h)->
      hnames = h.value.map (d) ->d.name
      for k in allSubKeys.filter( (s) -> hnames.indexOf(s)<0)
        h.value.push({name:k,value:0,stdev:0})

      h.values = _(h.values).sortBy (v) ->v.name
      h

    return _(hierarchy).sortBy (v) ->v.name


  chart.zoomed (node) ->
    zip = (n) ->

      zipped = (n.children.map (c) -> zip(c))
      visits = if zipped.length == 0 then 0 else zipped.map((d)->d.visits).reduce (a,b)->a+b
      subscribers = if zipped.length == 0 then 0 else zipped.map((d)->d.subscribers).reduce (a,b)->a+b
      wurflIds = _.flatten zipped.map (c) ->c.wurflIds

      if !!n.wurfl_device_id
        wurflIds.push(n.wurfl_device_id)
      if !!n.collected_children
        for c in n.collected_children
          wurflIds.push c.wurfl_device_id

      visits: (n.visits||0) + visits
      subscribers: (n.subscribers||0) + subscribers
      wurflIds: wurflIds

    zipped= zip node

    hierarchy = createSubMethodDeviceHierarchy(zipped.wurflIds, node.wurfl_device_id or zipped.wurflIds[0])
    subMethodDeviceChart.draw hierarchy