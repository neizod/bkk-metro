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


load_dataset = (name, ds) ->
    $.get "data/#{name}.txt", (data) ->
        [header, contents] = data.trim().split('===\n')
        [title, color] = header.trim().split('\n')
        ds.opts.title = title
        ds.changeTheme new TimeMapTheme
            lineColor: color
            lineWeight: 3
            icon: 'img/tiny-donut.png'
            iconAnchor: [4, 4]
            iconSize: [8, 8]
        ds.loadItems(contents.split('\n').filter(data_line), read_with_memo())
        ds.timemap.refreshTimeline()


decorate_tl = (tm) ->
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


decorate_map = (tm) ->
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


listen_to_events = (tm) ->
    map = tm.getNativeMap()
    tm.addFilter 'map', (item) ->
        item.opts.type != 'marker' or item.map.getZoom() > 10
    google.maps.event.addListener map, 'zoom_changed', ->
        tm.filter('map')


$(document).ready ->
    $.get 'data/list.txt', (data) ->
        train_lines = data.trim().split('\n')
        tm = TimeMap.init
            mapId: 'map'
            timelineId: 'tl'
            datasets: ({ id: name, type: "basic" } for name in train_lines)
        load_dataset(name, ds) for name, ds of tm.datasets
        decorate_tl(tm)
        decorate_map(tm)
        listen_to_events(tm)
