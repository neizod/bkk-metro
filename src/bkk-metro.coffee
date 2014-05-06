non_empty_line = (x) -> x.trim() != ''


read_spec = (text) ->
    [id, title, dt, llspecs] = text.split('\t')
    [start, end] = dt.split(',')
    end = '2100' unless end?
    lls = (ll.split(',') for ll in llspecs.split(' '))
    polyline = [point, others...] = ({lat, lon} for [lat, lon] in lls)
    if others.length
        {id, title, start, end, polyline}
    else
        {id, title, start, end, point}


load_all = (tm) ->
    $.get 'data/list.txt', (data) ->
        load_set(name, tm) for name in data.trim().split('\n')


load_set = (name, tm) ->
    $.get "data/#{name}.txt", (data) ->
        [header, contents] = data.trim().split('===\n')
        ds = tm.createDataset name,
            title: name
            theme: 'red'
            type: 'basic'
        ds.loadItems(contents.split('\n').filter(non_empty_line), read_spec)
        tm.refreshTimeline()


$(document).ready ->
    tm = TimeMap.init
        mapId: 'map'
        timelineId: 'tl'
        bandIntervals: 'yr'
        datasets: [ { title: "dummy", type: "basic" } ]
    load_all(tm)
    tm.getNativeMap().setOptions
        zoomControl: true
        scaleControl: true
