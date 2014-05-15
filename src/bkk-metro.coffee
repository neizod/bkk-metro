data_line = (x) -> x.trim() != ''
get_coord = (ll, memo) -> if ll of memo then memo[ll] else ll.split(',')


read_with_memo = (memo={}) -> (text) ->
    [id, title, dt, llspecs] = text.split('\t')
    id = null if id == '-'
    [start, end] = dt.split(',')
    end = '2100' unless end?
    lls = (get_coord(ll, memo) for ll in llspecs.split(' '))
    polyline = [point, others...] = ({lat, lon} for [lat, lon] in lls)
    if others.length
        {id, title, start, end, polyline}
    else
        memo[id] = [lat, lon] if id?
        {id, title, start, end, point}


load_all = (tm) ->
    $.get 'data/list.txt', (data) ->
        load_set(name, tm) for name in data.trim().split('\n')


load_set = (name, tm) ->
    $.get "data/#{name}.txt", (data) ->
        [header, contents] = data.trim().split('===\n')
        [title, color] = header.trim().split('\n')
        ds = tm.createDataset name,
            title: title
            theme: new TimeMapTheme
                lineColor: color
                lineWeight: 3
                icon: 'img/tiny-donut.png'
                iconAnchor: [4, 4]
                iconSize: [8, 8]
            type: 'basic'
        ds.loadItems(contents.split('\n').filter(data_line), read_with_memo())
        tm.refreshTimeline()


$(document).ready ->
    tm = TimeMap.init
        mapId: 'map'
        timelineId: 'tl'
        datasets: [ { title: "dummy", type: "basic" } ]
    tm.initTimeline [
        Timeline.createBandInfo
            width: "58%"
            intervalPixels: 50
            intervalUnit: Timeline.DateTime.MONTH
        Timeline.createBandInfo
            overview: true
            width: "42%"
            intervalPixels: 75
            intervalUnit: Timeline.DateTime.YEAR
    ]
    tm.addFilter 'map', (item) ->
        item.opts.type != 'marker' or item.map.getZoom() > 10
    load_all(tm)
    map = tm.getNativeMap()
    map.setOptions
        panControl: true
        panControlOptions:
            position: google.maps.ControlPosition.RIGHT_BOTTOM
        zoomControl: true
        zoomControlOptions:
            position: google.maps.ControlPosition.LEFT_BOTTOM
        overviewMapControl: false
        mapTypeControl: false
        scaleControl: true
        scrollwheel: true
    google.maps.event.addListener map, 'zoom_changed', ->
        tm.filter('map')
