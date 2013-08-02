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
      brand_name: root.brand_name
      model_name: root.model_name
      conv: root.conv
      device_os :root.device_os
      visits: root.visits


groupBy = (data, what, childrenMap = _.identity) ->
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
  return groupBy data,((d) ->d.brand_name), (children) -> groupBy(children,((c) ->c.device_os), collectLongTail)

  #, makeTreeByParentId





d3.csv 'charts/devicedet/data/ae.csv', (data) ->

  data = data.map (d) ->
    wurfl_device_id : d.wurfl_device_id
    wurfl_fall_back : d.wurfl_fall_back
    brand_name : d.brand_name
    model_name : d.model_name
    visits : +d.visits
    subscribers : +d.subscribers
    method : d.method
    conv : +d.conv
    device_os :d.device_os
    children : []

  window.data = data

  data = data.filter ((d) -> 'WAP' == d.method)


  totalVisits= data.map((d) -> d.visits).reduce((a,b)->a+b)
  totalSubs = data.map((d) -> d.subscribers).reduce((a,b)->a+b)
  totalConv= totalSubs/totalVisits




  data = groupByBrandName data


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





