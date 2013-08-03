sum = (arr) ->
  if(arr.length == 0)
    return 0
  if (arr.length == 1)
    return arr[0]
  return arr.reduce((a,b) ->a+b)

chart = new groupedBarsChart()
d3.select('#chart').call chart





d3.csv 'charts/grouped-bars/data/ae.csv', (raw) ->

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



  redraw = (freshData, wurflid) ->
    data = freshData.map (d) ->
      method: d.method,
      device: (if d.wurfl_device_id == wurflid then wurflid else 'Everything Else'),
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

    chart.draw hierarchy


  data = _.chain(fresh()).groupBy((d) -> d.wurfl_device_id)
  .map((arr, key) ->
    wurfl_device_id: key
    visits: sum(arr.map (a) -> a.visits)
  ).sortBy((a) -> -a.visits).value()

  index = -1;
  next = () ->
    key = data[++index].wurfl_device_id
    redraw(fresh(), key)
    setTimeout next, 4000

  next()

  #redraw(fresh(), 'nokia_n8_00_ver1_subs53')

