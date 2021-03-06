REBOL [
    title: "WebIDE For Red"
    author: "lisp-successor"
    version: 0.7.0
    date: 2016-02-29
] 
do func [arg] [
    webide-config: make object! [
        key-value: make object! [
            ui_language_id: "" 
            red_source_dir: "" 
            last_red_dir: %"" 
            current_red_dir: %""
        ] 
        write-file: func [file /local blk key value] [
            blk: load/all file 
            while [not tail? blk/6/4/4] [
                unless none? new-value: self/key-value/(to word! blk/6/4/4/1) [
                    blk/6/4/4/2: copy new-value
                ] 
                blk/6/4/4: skip blk/6/4/4 2
            ] blk/6/4/4: head blk/6/4/4 
            save file blk
        ] 
        to-json: func [] [
            json: make string! 0 
            append json "{" 
            props: reflect self/key-value 'words 
            while [not tail? props] [
                append json rejoin [either head? props [{"}] [{,"}] props/1 {":"} self/key-value/(props/1) {"}] 
                props: skip props 1
            ] props: head props 
            append json "}" 
            json
        ]
    ]
] true