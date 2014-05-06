load_all = (tm) ->
    $.get 'data/list.txt', (data) ->
        load_set(name, tm) for name in data.trim().split('\n')


load_set = (name, tm) ->
    $.get "data/#{name}.txt", (data) ->
        [stations, rails] = data.trim().split('\n===\n')
        ds = tm.createDataset
            id: name
            title: name
            theme: 'red'
            type: 'basic'
        for line in stations.split('\n')
            [id, title, dt, ll] = line.split('\t')
            [start, end] = dt.split(',')
            end = '2100' unless end?
            [lat, lon] = ll.split(',')
            point = {lat, lon}
            ds.loadItem {id, title, start, end, point}
        for line in rails.split('\n')
            [id, title, dt, lls] = line.split('\t')
            [start, end] = dt.split(',')
            end = '2100' unless end?
            lls = (ll.split(',') for ll in lls.split(' '))
            polyline = ({lat, lon} for [lat, lon] in lls)
            ds.loadItem {id, title, start, end, polyline}
        ds.loadItems []
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
