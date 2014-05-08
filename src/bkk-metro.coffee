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
                icon: 'img/tiny-pointer.png'
            type: 'basic'
        ds.loadItems(contents.split('\n').filter(data_line), read_with_memo())
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
