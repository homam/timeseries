# convers the data array to a tree starting from root
pack = (root, data) ->
  data.forEach (d,i) ->
    if(d != null && d.wurfl_fall_back == root.wurfl_device_id)
      data = pack d, data
      root.children.push d
      data[i] = null
  data

# adds the root of tree back to the tree
addBack = (root) ->
  if(root.children.length > 0)
    root.children.forEach addBack
    root.children.push
      children: []
      wurfl_device_id: root.wurfl_device_id
      brand_name: root.brand_name
      model_name: root.model_name
      conv: root.conv
      visits: root.visits


groupByBrandName = (data) ->
  groups = _(data).groupBy (d) -> d.brand_name

  _(groups).map (darr, key) ->

    groupVisits = darr.map((d) -> d.visits).reduce((a,b)->a+b)
    groupSubs = darr.map((d) -> d.subscribers).reduce((a,b)->a+b)
    groupAverageConv = groupSubs / groupVisits
    groupStdevConversion = darr.map((g) ->
      Math.sqrt(Math.pow((g.conv-groupAverageConv), 2)) * g.visits / groupVisits
    )
    .reduce((a,b) -> a+b)

    [0..darr.length-1].forEach (i) ->
      d = darr[i]
      if(!!d)
        darr = pack darr[i], darr
    darr = darr.filter (d) -> d != null

    [0..darr.length-1].forEach (i) ->
      addBack(darr[i])

    return {
      averageConversion: groupAverageConv
      stdevConversion: groupStdevConversion
      children: darr
    }

groupByParentIdOnly = (data) ->
  [0..data.length-1].forEach (i) ->
    d = data[i]
    if(!!d)
      data = pack data[i], data
    data = data.filter (d) -> d != null

  [0..data.length-1].forEach (i) ->
    addBack(data[i])

  data



d3.csv 'charts/treemap/data/devices-ae.csv', (data) ->

  data = data.map (d) ->
    wurfl_device_id : d.wurfl_device_id
    wurfl_fall_back : d.wurfl_fall_back
    brand_name : d.brand_name
    model_name : d.model_name
    visits : +d.visits
    subscribers : +d.subscribers
    conv : +d.conv
    children : []


  totalVisits= data.map((d) -> d.visits).reduce((a,b)->a+b)
  totalSubs = data.map((d) -> d.subscribers).reduce((a,b)->a+b)
  totalConv= totalSubs/totalVisits


  more = data.filter((d) ->d.visits <= 100)
  moreVisits = more.map((d) -> d.visits).reduce((a,b)->a+b)
  moreSubs = more.map((d) -> d.subscribers).reduce((a,b)->a+b)
  data = data.filter (d) ->d.visits > 100
  data.push
    children: [],
    wurfl_fall_back: 'root'
    wurfl_device_id: 'more...'
    brand_name: 'more'
    model_name: '..'
    visits: moreVisits
    subscribers: moreSubs
    conv : moreSubs/moreVisits

  data = groupByBrandName data #groupByParentIdOnly data


  window.data = data

  tree =
    children: data
    wurfl_device_id: 'root'
    brand_name: 'root'
    model_name: 'root'
    visits: 0

  chart = treeMapZoomableChart() #treeMapChart()

  d3.select('#chart').call chart

  chart.draw tree





