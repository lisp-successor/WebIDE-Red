Red [
    title: "Weather"
    Needs: 'View ;https://github.com/red/red/wiki/Red-View-Graphic-System
]
self-dir: either interpreted?: system/state/interpreted? [either none? system/script/path [what-dir][copy/part to-red-file system/script/path index? find/last to-red-file system/script/path "/"]][copy/part to-red-file system/options/boot index? find/last to-red-file system/options/boot "/"]

face-main1: layout [
    title "Red Weather"
    dlst-language: drop-list 50 [
        btn-search/text: form dlst-language/data/(dlst-language/selected * 2)
        if (length? dlst-city-name-similar/data) > 0 [
            fn-on-change-dlst-city-name-similar
        ]
    ]
    group-box 2 [
        below
        fld-city-name: field "Beijing" 280
        dlst-city-name-similar: drop-list 280 [
            fn-on-change-dlst-city-name-similar
        ]
    ]
    btn-search: button "Search" 70x50 [
        fn-search-city-weather
    ]
    return
    grp5: group-box 5 [
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
        group-box "" [below origin 5x20 image 48x48 text "" 70x50 text "" 46x25]
    ]
    return
    button "open" [
        fld-red-file/text: form request-file/title/file "find a red file" "*.red"
    ]
    fld-red-file: field "" 370
    btn-interpret: button "interpret red file" 120 [
        attempt [do load to-red-file fld-red-file/text]
    ]
    do [append self/text reduce [" (" either interpreted? ["interpret"]["complie"] ")"]]
]

rejoin: function [blk][
    append make string! 0 reduce blk
]

blk-wether-data: make block! 0
fn-on-change-dlst-city-name-similar: function [][
    clear blk-wether-data

    zmw: form dlst-city-name-similar/data/(dlst-city-name-similar/selected * 2)
    lang: dlst-language/data/(dlst-language/selected * 2 - 1)
    url2: rejoin ["http://api.wunderground.com/api/2b0d6572c90d3e4a/lang:" lang "/forecast10day_v11/q/zmw:" zmw ".json?v=wuiapp"]
    json2: read probe to url! url2

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
            (append/only blk-wether-data reduce [day monthname high-celsius low-celsius conditions icon icon_url])
        ]
    ]
    parse json2 pr2
    print rejoin [{get } length? blk-wether-data { days weather of "} dlst-city-name-similar/data/(dlst-city-name-similar/selected * 2 - 1) {"}]
    repeat i length? grp5/pane [
        grp5/pane/:i/text: rejoin [blk-wether-data/:i/2 " " blk-wether-data/:i/1]
        img: load to url! blk-wether-data/:i/7
        grp5/pane/:i/pane/1/image: img
        grp5/pane/:i/pane/2/text: blk-wether-data/:i/5
        grp5/pane/:i/pane/3/text: rejoin [blk-wether-data/:i/4 "~" blk-wether-data/:i/3 " C"]
    ]
]

fn-search-city-weather: function [][    
    clear dlst-city-name-similar/data
    url1: rejoin ["http://autocomplete.wunderground.com/aq?format=JSON&lang=zh&query=" fld-city-name/text]
    json1: read probe to url! url1
    city-name: city-zmw: city-lat-lon: ""
    pr1: [
        any [
            thru {"name": "} copy city-name    to {",}
            thru {"zmw": "}  copy city-zmw     to {",}
            thru {"ll": "}   copy city-lat-lon to {",}
            (if city-lat-lon <> "-9999.000000 -9999.000000" [append dlst-city-name-similar/data reduce [city-name to issue! city-zmw]])
        ]
    ]
    parse json1 pr1
    print rejoin ["similar city names: " (length? dlst-city-name-similar/data) / 2]
    dlst-city-name-similar/selected: 1
    fn-on-change-dlst-city-name-similar
]

fn-between-layout-and-view: function [][
    dlst-language/data: ["EN" Search "FR" Recherche "CN" 搜寻]
    dlst-language/selected: 1
    dlst-city-name-similar/data: make block! 0
    ;fld-red-file/text: rejoin [self-dir "vid-calculator.red"]
]

fn-between-layout-and-view
view face-main1