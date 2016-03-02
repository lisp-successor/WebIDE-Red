REBOL [
    title: "WebIDE For Red"
    author: "lisp-successor"
    version: 0.7.0
    date: 2016-02-29
]
;-- rebol2 anonymous function
do func [arg][


websocket-obj: make object! [
    ; https://github.com/gimite/web-socket-js/blob/master/flash-src/src/net/gimite/websocket/WebSocket.as
    log-handler: none
    output-log: func [target][
        if function? :log-handler [
            log-handler target
        ]
    ]
    rebol2?: value? 'disarm
    red?: not object? rebol ;-- logic? rebol ;bug
    handshake: func [ data [binary!] /local key][
        parse data [ thru "Sec-WebSocket-Key: " copy key to "^(0D)^(0A)" ]
        ;to binary! append make string! 0 reduce [...]
        to binary! rejoin [
            "HTTP/1.1 101 Switching Protocols^(0D)^(0A)Upgrade: websocket^(0D)^(0A)Connection: Upgrade^(0D)^(0A)Sec-WebSocket-Accept: "
            enbase checksum/method to binary! join to string! key "258EAFA5-E914-47DA-95CA-C5AB0DC85B11" 'sha1
            "^(0D)^(0A)^(0D)^(0A)"
        ]
    ]
    int-to-bin: func[byte-len int][
        bin: make binary! 0
        either rebol2? [
            bin: debase/base to-hex int 16
        ][
            bin: to binary! int
        ]
        pad-len: byte-len - (length? bin)
        either pad-len > 0 [
            repeat i pad-len [head insert bin #{00}]
        ][
            repeat i abs pad-len [remove bin]
        ]
        bin
    ]
    int-shift: func[int bits][
        either rebol2? [either bits < 0 [shift int abs bits][shift/left int bits]][shift int bits]
    ]
    int-mod: func[int1 int2][
        either value? 'mod [mod int1 int2][do bind load "int1 % int2" 'int1]
    ]
    swap-endian: func [bin /local new-bin a b][
        if 0 = int-mod len: length? bin 2 [
            new-bin: copy bin
            half-len: len / 2
            repeat i half-len [
                either rebol2? [
                    new-bin/(i):            to char! bin/(i + half-len)
                    new-bin/(i + half-len): to char! bin/(i)
                ][
                    new-bin/(i):                     bin/(i + half-len)
                    new-bin/(i + half-len):          bin/(i)
                ]
            ]
            new-bin
        ]
    ];swap-endian bin: #{0102030405060708}

    data-frame?:   true
    last-frame?:   true
    error-rsv?:    false
    error-length?: false
    opcode: #{00}
    bin-payload-buffer: make binary! 0
    parse-frame: func [bin-in /local copy-len byte1 byte2 length1 length2 masking-key payload-data][
;print "{"
        copy-len: 0
        byte1:  copy/part bin-in copy-len: 1    bin-in: skip bin-in copy-len
        error-rsv?: #{00} <> (byte1 and #{70})
        last-frame?: #{80} <= byte1
        opcode: byte1 and #{0F}
;probe copy/part head bin-in 10
        either data-frame?: #{08} > opcode [
            byte2: copy/part bin-in copy-len: 1    bin-in: skip bin-in copy-len
            length1: byte2 and #{7F}
            case [
                (int-to-bin 1 126) = length1 [length1: copy/part bin-in copy-len: 2    bin-in: skip bin-in copy-len]
                (int-to-bin 1 127) = length1 [length1: copy/part bin-in copy-len: 8    bin-in: skip bin-in copy-len]
            ]
            masking-key:                               copy/part bin-in copy-len: 4    bin-in: skip bin-in copy-len
            payload-data: bin-in
            length2: int-to-bin length? length1 length? payload-data
            error-length?: length2 < length1
            either error-length? [
;probe reduce [length2 length1]
;probe copy/part head bin-in 10
            ][
                clear bin-payload-buffer
                xor-length: length? payload-data
                if length2 <> length1 [
                    xor-length: xor-length - ((to integer! last length2) - (to integer! last length1))
;probe reduce [length2 length1 xor-length]
                ]
                repeat i xor-length [
                    append bin-payload-buffer int-to-bin 1 payload-data/:i xor masking-key/((int-mod (i - 1) 4) + 1)
                ]
            ]
        ][
            ;probe "not data frame"
        ]
;print "}"
        bin-payload-buffer
    ]
    make-frame: func [first-byte [binary!] bin-in [binary!] /local int-len bin-len bin-out] [
        len: length? bin-in
        bin-out: make binary! 0
        append bin-out first-byte
        case [
            len <=        125 [append bin-out int-to-bin 1 len]
            len <=      65535 [append bin-out int-to-bin 1 126    append bin-out int-to-bin 2 len]
            len <= 4294967295 [append bin-out int-to-bin 1 127    append bin-out int-to-bin 8 len]
            true [print "frame size too large"]
        ]
        append bin-out bin-in
        bin-out
    ]
]
tcp-server-client-obj: make object! [
    log-handler: none
    output-log: func [target][
        if function? :log-handler [
            log-handler target
        ]
    ]
    system/schemes/default/timeout: 86400 ;24 hours
    tcp-target: none
    server?: false
    send-ready?: false
    start: func [tcp-target data-handler client-closed-handler][
        accept-port: none
        either none? tcp-target: tcp-target [
            tcp-target: ask "input tcp target (like tcp://:8080 or tcp://127.0.0.1:8080) ? "
        ][
            output-log tcp-target
        ]
        if find tcp-target "tcp://:" [
            server?: true
            accept-port: open/no-wait/binary/direct to url! tcp-target
        ]
        tcp-wait: 0.1
        ws-wait:  0.1
        active-ports: append make block! 0 ws-wait
        forever [
            either server? [
                ;output-log "wait new connect..."
                if not none? wait [tcp-wait accept-port] [
                    active-ports: head insert active-ports first accept-port
                    ;output-log join "connection from: " [active-ports/1/remote-ip ":" active-ports/1/remote-port " at " now/time/precise]
                ]
            ][
                append active-ports open/no-wait/binary/direct to url! tcp-target
            ]
            ;output-log "wait connected data..."
            if not none? active-port: wait active-ports [
                if not none? data: copy active-port [
                    either send-ready?: not empty? data [
                        data-handler active-port data
                    ][
                        if client-closed-handler active-port [
                            break
                        ]
                    ]
                ]
            ]
        ]
        if not none? accept-port [
            close accept-port
        ]
        wait 0.3
        quit
    ]
    send: func [active-port bin][
        if send-ready? [
            insert active-port bin
        ]
    ]
    remove-active-port: func [active-port][
        attempt [close active-port]
        head remove back skip active-ports index? find active-ports active-port
        active-port: none
    ]
]
log-handler1: func [target][
    probe target
]
websocket-obj/log-handler:         :log-handler1
tcp-server-client-obj/log-handler: :log-handler1

webide: make object! [
    script-dir: either none? system/script/path [copy system/options/boot][copy system/script/path]
    webide-config-file: rejoin [script-dir %webide-config.reb]
    webide-config-obj: do webide-config-file
    work-dir: copy script-dir
    html-dir: clean-path append copy script-dir %../ui/
    unless probe exists? rejoin [html-dir %WebIDE-Red.html][
        write/binary rejoin [html-dir %WebIDE-Red.html] read/binary rejoin [html-dir %WebIDE-Red.html_]
        delete rejoin [html-dir %WebIDE-Red.html_]
    ]
    os-id: system/version/4
    if os-id = 3 [
        kernel32: load/library %kernel32.dll
        GetACP: make routine! [
            return: [int]
        ] kernel32 "GetACP"
        ansi-code-page: GetACP ;ansi-code-page: 0
        MultiByteToWideChar: make routine! [
            CodePage          [int]
            dwFlags           [int]
            lpMultiByteStr    [char*]
            cbMultiByte       [int]
            lpWideCharStr     [char*]
            cchWideChar       [int]
            return:           [int]
        ] kernel32 "MultiByteToWideChar"
        WideCharToMultiByte: make routine! [
            CodePage          [int]
            dwFlags           [int]
            lpWideCharStr     [char*]
            cchWideChar       [int]
            lpMultiByteStr    [char*]
            cbMultiByte       [int]
            lpDefaultChar     [char*]
            lpUsedDefaultChar [char*]
            return:           [int]
        ] kernel32 "WideCharToMultiByte"
        GetLastError: make routine! [
            return: [ int ]
        ] kernel32 "GetLastError"
        utf16be-to-utf8: func [bin16 [binary!] /local bin8 code-point count offset temp][
            bin8: make binary! 0
            while [not tail? bin16][
                code-point: to integer! websocket-obj/swap-endian copy/part bin16 2 ; utf16le-to-utf16be
                count: offset: none
                case [
                    code-point < to integer!       #{80} [count: 0 offset: to integer! #{00}]
                    code-point < to integer!     #{0800} [count: 1 offset: to integer! #{C0}]
                    code-point < to integer!   #{010000} [count: 2 offset: to integer! #{E0}]
                    code-point < to integer!   #{110000} [count: 3 offset: to integer! #{F0}]
                ]
                append bin8 websocket-obj/int-to-bin 1 (websocket-obj/int-shift code-point (-6 * count)) + offset
                temp: none
                while [count > 0][
                    temp: websocket-obj/int-shift code-point (-6 * (count - 1))
                    append bin8 websocket-obj/int-to-bin 1 (to integer! #{80}) or (temp and to integer! #{3F})
                    count: count - 1
                ]
                bin16: skip bin16 2
            ] bin16: head bin16
            bin8
        ]
        bin-to-utf16le: func [code-page [integer!] bin [binary! string! file!]][
            unless binary? bin [bin: to binary! bin]
            len-utf16le: MultiByteToWideChar code-page 0 bin -1 #{00} 0
            len-utf16le: (len-utf16le - 1) * 2
            bin-utf16le: make binary! 0
            repeat i len-utf16le [append bin-utf16le #{00}]
            len-utf16le: MultiByteToWideChar code-page 0 bin -1 bin-utf16le len-utf16le
            bin-utf16le
        ]
        utf16le-to-ansi: func [bin-utf16le /local len-ansi bin-ansi][
            len-ansi: WideCharToMultiByte ansi-code-page 0 bin-utf16le -1 #{00} 0 #{00} #{00}
            len-ansi: len-ansi - 1
            bin-ansi: make binary! 0
            repeat i len-ansi [append bin-ansi #{00}]
            len-ansi: WideCharToMultiByte ansi-code-page 0 bin-utf16le -1 bin-ansi len-ansi #{00} #{00}
            bin-ansi
        ]
        if empty? webide-config-obj/key-value/red_source_dir [
            ;http://blogs.msdn.com/b/gblock/archive/2006/12/19/tips-steams-zones-vista-and-blocked-files-in-ie.aspx
            write/binary rejoin [html-dir %"WebIDE-Red.html:Zone.Identifier"] read/binary rejoin [html-dir %WebIDE-Red.html]
        ]
    ]
    
    handlers: make block! 0
    file-viewer: make object! [
        browse: func [url][
            ;rebol-core and rebol-pro do not support browse
            case [
                os-id = 3 [
                    ;call/show join "start /max " url
                    call/show join "explorer " url
                ]
                os-id = 2 [
                    call/show join "open " url
                ]
                os-id = 4 [
                    call/show join "x-www-browser " url
                ]
            ]
        ]
        show-dirs-files: func [target-dir /local blk-dir dir-or-file dir][
            target-blk: make block! 0
            blk-dir: make block! 0
            foreach dir-or-file sort read target-dir [
                either #"/" = last dir-or-file [
                    insert blk-dir form dir-or-file
                ][
                    ext: to word! form find/last dir-or-file "."
                    if find [.r .reb .reds .red .bat .command .desktop] ext [
                        append target-blk form dir-or-file
                    ]
                ]
            ]
            foreach dir blk-dir [
                insert target-blk dir
            ]
            target-blk
        ]
        go-parent: func [target-dir /local part-length][
            part-length: length? target-dir
            either part-length > 1 [
                if #"/" = last target-dir [
                    part-length: part-length - 1
                ]
                copy/part target-dir (length? target-dir) - (length? find/part/last target-dir "/" part-length) + 1
            ][
                target-dir
            ]
        ]
        data-handler: func [keys value /local reply][
            reply: none
            case [
                "dto-id" = keys/1 [
                    if "5C0A91CD-8B1D-5176-4F73-84574F5C6B0A" = keys/2 [
                        reply: probe webide-config-obj/to-json
                    ]
                ]
                "read-ui-language" = keys/1 [
                    reply: read/binary rejoin [go-parent script-dir "ui/WebIDE-Red.csv"]
                ]
                "write-ui-language" = keys/1 [
                    if webide-config-obj/key-value/ui_language_id <> keys/2 [
                        webide-config-obj/key-value/ui_language_id: keys/2
                        webide-config-obj/write-file webide-config-file
                    ]
                    reply: make string! 0
                ]
                "list-dir-file" = keys/1 [
                    either none? keys/2 [
                        reply: work-dir
                    ][
                        work-dir: change-dir to file! keys/2
                        reply: make string! 0
                        foreach df show-dirs-files work-dir [ ; list-dir return none
                            append reply either empty? reply [df][reduce ["|" df]]
                        ]
                    ]
                ]
                "read" = keys/1 [
                    editing-file: to file! keys/2
                    reply: read/binary editing-file
                ]
                "write" = keys/1 [
	                editing-file: to file! keys/2
                    write/binary editing-file value
                    reply: make string! 0
                ]
            ]
            reply
        ]
    ] append handlers file-viewer
    
    executor: make object! [
        os-dir:    none
        rebol-exe: none
        case [
            3 = os-id [os-dir: %windows/ rebol-exe: rejoin [script-dir os-dir %rebol-view-278-3-1.lol]]
            2 = os-id [os-dir: %darwin/  rebol-exe: rejoin [script-dir os-dir %rebol-core-278-2-5]]
            4 = os-id [os-dir: %linux/   rebol-exe: rejoin [script-dir os-dir %rebol-core-278-4-3]]
        ]
        blk-red-source-dir: make block! 0
        red-source-dir: rejoin [script-dir %red-source/]
        if webide-config-obj/key-value/red_source_dir <> replace/all to-local-file red-source-dir "\" "\\" [
            webide-config-obj/key-value/red_source_dir:  replace/all to-local-file red-source-dir "\" "\\"
            webide-config-obj/write-file webide-config-file
        ]
        red-r:           none
        console-red:     none
        red-console-exe: none
        change-red-dir: func [short-dir /write-file /local clean-red-dir][
            red-r:           rejoin [script-dir %red-source/ short-dir %red.r]
            console-red:     rejoin [script-dir %red-source/ short-dir %environment/console/console.red]
            red-console-exe: rejoin [script-dir os-dir       short-dir %red-console]
            if 3 = os-id [
                append red-console-exe %.exe
            ]
            if write-file [
                webide-config-obj/key-value/current_red_dir: short-dir
                webide-config-obj/write-file webide-config-file
            ]
            clean-red-dir: none
            if exists? red-console-exe [
                clean-red-dir: file-viewer/go-parent red-console-exe
            ]
            clean-red-dir
        ]
        replace-path-spaces: func [str][
            replace/all copy str " " "%20"
        ]
        kill-then-call: func [str-kill-first str-cmd /need-wait /no-run /local all-str-cmd cmd-kill cmd-before cmd-after][
            all-str-cmd: make string! 0
            unless none? str-kill-first [
                case [
                    3 = os-id [cmd-kill: rejoin ["taskkill /f /t /im " str-kill-first ".exe"]]
                    true      [cmd-kill: rejoin ["killall "            str-kill-first       ]]
                ]
                call probe cmd-kill
                if 2 = os-id [
                    cmd-kill: {osascript -e 'tell application "Terminal" to close (every window whose name contains "bash")' & exit}
                    call probe cmd-kill
                ]
                wait 0.5 ;do not forget this
            ]
            case [
                3 = os-id [
                    cmd-before: ""
                    cmd-after:  ""
                ]
                2 = os-id [
                    cmd-before: {osascript -e 'tell app "Terminal" to do script "}
                    cmd-after:  {"'}
                    replace/all str-cmd {"} {\"}
                ]
                4 = os-id [
                    cmd-before: "gnome-terminal -x sh -c '"
                    cmd-after:  "'"
                ]
            ]
            probe all-str-cmd: rejoin [cmd-before str-cmd cmd-after]
            unless no-run [
                ;reply: make string! 200
                ;call/show/output probe str reply
                either need-wait [
                    call/show/wait all-str-cmd
                ][
                    call/show      all-str-cmd
                ]
            ]
            all-str-cmd
        ]
        compile: func [output-file target-os debug-flag file /call-new-rebol /then-run /need-wait /local all-str-cmd str-do temp-reb temp-reb-str][
            if none? debug-flag [
                debug-flag: make string! 0
            ]
            make-dir/deep file-viewer/go-parent output-file
            ;-- only do/args, second argument needs to replace all spaces in file! to "%20"
            str-do: rejoin [{do/args %} red-r { "-o %} replace-path-spaces output-file { -t } target-os { } debug-flag { %} replace-path-spaces file {"}]
            if then-run [
                either 4 = os-id [
                    append str-do rejoin [{^(0D)^(0A) call/show/wait %"} to-local-file output-file {"}]
                ][
                    append str-do rejoin [{^(0D)^(0A) call/show %"} to-local-file output-file {"}]
                ]
            ]
            either call-new-rebol [
                temp-reb: rejoin [script-dir os-dir %_temp.reb_]
                temp-reb-str: rejoin ["REBOL [] ^(0D)^(0A)" str-do]
                write temp-reb probe temp-reb-str
                either need-wait [
                    kill-then-call/need-wait none rejoin [to-local-file rebol-exe " -i -v -s " to-local-file temp-reb]
                ][
                    kill-then-call           none rejoin [to-local-file rebol-exe " -i -v -s " to-local-file temp-reb]
                ]
            ][
                do probe str-do
            ]
        ]
        data-handler: func [keys value /local reply][
            reply: none
            case [
                "target-os-default" = keys/1 [
                    reply: replace to string! copy os-dir "/" ""
                ]
                "list-red-dir" = keys/1 [
                    reply: make string! 0
                    foreach df file-viewer/show-dirs-files rejoin [script-dir os-dir][
                        if all ["/" = skip tail df -1    not none? change-red-dir df][
                            append reply either empty? reply [df][reduce ["|" df]]
                        ]
                    ]
                ]
                "change-red-dir" = keys/1 [
                    reply: make string! 0
                    either none? keys/2 [
                        if empty? reply: webide-config/key-value/current_red_dir [
                            reply: make string! 0
                        ]
                    ][
                        change-red-dir/write-file to file! keys/2
                    ]
                ]
                "do" = keys/1 [
                    str-call: rejoin [{"} to-local-file red-console-exe {" "} to-local-file to file! keys/3 {"}]
                    either find keys/2 "kill" [
                        kill-then-call "red-console" str-call
                    ][
                        kill-then-call none          str-call
                    ]
                    reply: make string! 0
                ]
                "compile" = keys/1 [
                    output-file: replace/all copy editing-file ".red" ""
                    if 3 = os-id [
                        append output-file ".exe"
                    ]
                    editing-file: to file! keys/2
                    either all [not none? keys/5    find keys/5 "run"] [
                        compile/call-new-rebol/then-run output-file keys/3 keys/4 editing-file
                    ][
                        compile/call-new-rebol          output-file keys/3 keys/4 editing-file
                    ]
                    reply: make string! 0
                ]
                "write-unzip" = keys/1 [
                    unziped-file: rejoin [script-dir "red-source/" keys/2]
                    make-dir/deep file-viewer/go-parent unziped-file
                    write/binary unziped-file value
                    reply: to string! length? value
                    ;wait 0.5
                ]
                "list-red-source-dir" = keys/1 [
                    reply: make string! 0
                    either "0" == keys/2 [
                        clear blk-red-source-dir
                        foreach df file-viewer/show-dirs-files red-source-dir [
                            if all ["/" = skip tail df -1    find file-viewer/show-dirs-files rejoin [red-source-dir df] "red.r"][
                                append blk-red-source-dir df
                            ]
                        ]
                    ][
                        blk-red-source-dir2: make block! 0
                        foreach df file-viewer/show-dirs-files red-source-dir [
                            if all ["/" = skip tail df -1    find file-viewer/show-dirs-files rejoin [red-source-dir df] "red.r"][
                                append blk-red-source-dir2 df
                            ]
                        ]
                        exclude blk-red-source-dir2 blk-red-source-dir
                        either 0 < length? blk-red-source-dir2 [
                            append reply blk-red-source-dir2/1
                        ][
                            if 1 = length? blk-red-source-dir [
                                append reply blk-red-source-dir/1
                            ]
                        ]
                    ]
                ]
                "upgrade" = keys/1 [
                    webide-config-obj/key-value/last_red_dir: webide-config-obj/key-value/current_red_dir
                    change-red-dir to file! keys/2
                    if all [not none? keys/3    find keys/3 "needs-view"] [
                        blk: load console-red
                        append blk/2 [Needs: 'View]
                        write/binary console-red to-binary mold/only blk
                    ]
                    target-os: replace to string! copy os-dir "/" ""
                    if "windows" = target-os [
                        target-os: "msdos"
                    ]
                    ;either 3 = os-id [
                    ;    compile/call-new-rebol/need-wait red-console-exe target-os keys/4 console-red ; because different shell, /need-wait nowork in mac
                    ;][
                        compile                red-console-exe target-os keys/4 console-red
                    ;]
                    reply: make string! 0
                ]
                "restart" = keys/1 [
                    foreach df file-viewer/show-dirs-files file-viewer/go-parent script-dir [
                        if find df replace to string! copy os-dir "/" "" [
                            kill-then-call none to-local-file rejoin [file-viewer/go-parent script-dir df]
                            break
                        ]
                    ]
                    reply: make string! 0
                ]
            ]
            reply
        ]
    ] append handlers executor

    ws-send-ready?: false
    ws-send: func [active-port first-byte bin][
        if ws-send-ready? [
            tcp-server-client-obj/send active-port websocket-obj/make-frame first-byte bin
        ]
    ]
    dto-out: func [keys [string!] value [binary! string! file!] /local bin][
        bin: make binary! 0
        append bin websocket-obj/int-to-bin 2 length? keys
        append bin to binary! keys
        if all [os-id = 3    find keys "list-dir-file"][
            value: utf16be-to-utf8 bin-to-utf16le ansi-code-page value
        ]
        append bin to binary! value
        bin
    ]
    dto-in: func [bin /local reply key-length key value][
        reply: make block! 0
        key-length: to integer! copy/part bin          2    bin: skip bin 2
        key:                    copy/part bin key-length    bin: skip bin key-length
        if os-id = 3 [
            key: utf16le-to-ansi bin-to-utf16le 65001 key
        ]
        append reply reduce [to string! key to string! bin]
        reply
    ]
    editing-file: %""
    active-port-http: none
    active-port-ws:   none
    client-closed-handler: func [active-port][
        ;-- can not use "=" on closed port, but on port-id
        case [
            all [
                not none? active-port-http
                active-port-http/port-id = active-port/port-id
            ][
                tcp-server-client-obj/remove-active-port active-port-http
                false
            ]
            active-port-ws/port-id = active-port/port-id [
                true
            ]
            all [
                true
            ]
        ]
    ]
    data-handler: func [active-port data][
        case [ ;case1 must be front than case2
            all [
                buffer: "GET /ws1 "
                equal? buffer to string! copy/part data length? buffer
                find data "upgrade: websocket"
            ][
                active-port-ws: active-port
                tcp-server-client-obj/send active-port-ws websocket-obj/handshake data
            ]
            true [
                ws-send-ready?: true
                bin: websocket-obj/parse-frame data
;write/binary %temp.txt bin
                either websocket-obj/error-length? [
                    probe "error-length"
                    dto: dto-in websocket-obj/bin-payload-buffer
probe dto
                    ;ws-send active-port-ws #{82} dto-out dto/1 "0"
                ][
                    either websocket-obj/data-frame? [
                        dto: dto-in websocket-obj/bin-payload-buffer
                        either find dto/1 "write-unzip|" [
                            probe rejoin ["in: " dto/1 " " length? dto/2]
                        ][
                            prin "in: " probe dto
                        ]
                        reply: none
                        foreach handler handlers [
                            unless none? reply: handler/data-handler parse/all dto/1 "|" dto/2 [
                                break
                            ]
                        ]
                        unless none? reply [
                            ws-send active-port-ws #{82} dto-out dto/1 reply
                        ]
                    ][
                        probe websocket-obj/opcode
                    ]
                ]
            ]
        ]
    ]
]

webide/file-viewer/browse to-local-file join webide/file-viewer/go-parent system/script/path %ui/WebIDE-Red.html
tcp-server-client-obj/start 
"tcp://:8080"
either websocket-obj/rebol2? [get in webide 'data-handler]         [:webide/data-handler]
either websocket-obj/rebol2? [get in webide 'client-closed-handler][:webide/client-closed-handler]


] true