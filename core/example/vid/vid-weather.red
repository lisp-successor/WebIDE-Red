Red [
    title: "Weather"
    Needs: 'View
]

search-report: function [][
    clear drop-list/data
    url1: http://autocomplete.wunderground.com/aq?format=JSON&lang=zh&query=#city-name#
    json1: read replace/all copy url1 "#city-name#" field-text/text
    city-name: city-zmw: city-lat-lon: ""
    pr1: [
        any [
            thru {"name": "} copy city-name    to {",}
            thru {"zmw": "}  copy city-zmw     to {",}
            thru {"ll": "}   copy city-lat-lon to {",}
            (if city-lat-lon <> "-9999.000000 -9999.000000" [append drop-list/data reduce [city-name to issue! city-zmw]])
        ]
    ]
    parse json1 pr1
    probe length? drop-list/data
    drop-list/selected: 1
    drop-list-on-change2 drop-list
]
blk-data: make block! 0
drop-list-on-change2: function [face [object!] /extern blk-data][
    clear blk-data
    ;-- SVG http://wow.techbrood.com/fiddle/5854
    url2base:  http://api.wunderground.com/api/2b0d6572c90d3e4a/lang:#lang#/forecast10day_v11/q/zmw:#zmw#.json?v=wuiapp
    zmw: form face/data/(face/selected * 2)
    lang: drop-list-lang/data/(drop-list-lang/selected * 2 - 1)
    url2: replace/all copy url2base "#lang#" lang
    url2: replace/all copy url2     "#zmw#"  zmw
    probe url2
    json2: read url2
    probe length? json2
    
    monthname: day: high-celsius: low-celsius: conditions: icon: icon_url: ""
    pr2: [
        thru {"simpleforecast"}
        any [
            thru {"day":}               copy day          to {,}
            thru {"monthname_short":"}  copy monthname    to {",}
            thru {"celsius":"}          copy high-celsius to {"}
            thru {"celsius":"}          copy low-celsius  to {"}
            thru {"conditions":"}       copy conditions   to {",}
            thru {"icon":"}             copy icon         to {",}              
            thru {"icon_url":"}         copy icon_url     to {",}
            (append/only blk-data reduce [day monthname high-celsius low-celsius conditions icon icon_url])
        ]
    ]
    parse json2 pr2
    probe length? blk-data
    repeat i length? grp5/pane [
        grp5/pane/:i/text: append copy "" reduce [blk-data/:i/2 " " blk-data/:i/1]
        img: load to url! blk-data/:i/7
        grp5/pane/:i/pane/1/image: img
        grp5/pane/:i/pane/2/text: blk-data/:i/5
        grp5/pane/:i/pane/3/text: append copy "" reduce [blk-data/:i/4 "~" blk-data/:i/3]
    ]
]
view [
    title "Red Weather"
    drop-list-lang: drop-list 50 [
        btn-search/text: form face/data/(face/selected * 2)
        search-report
    ]
    group-box 2 [
        below
        field-text: field "Beijing" 280
        drop-list: drop-list 280 [
            drop-list-on-change2 face
        ]
    ]
    btn-search: button "Search" 70x50 [search-report]
    return
    grp5: group-box 5 [
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
    ]
    do [
        drop-list-lang/data: ["EN" Search "FR" Recherche "CN" 搜寻]
        drop-list-lang/selected: 1
        drop-list/data: make block! 0
    ]
]