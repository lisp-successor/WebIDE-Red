Red []
url: http://www.tdvs.chc.edu.tw/test/Service.asmx/HelloWorld_Yuping
data: to binary! "a=Hello你好"
result: write/binary url reduce [
    'post
    [
        Connection:     "close"
        Referer:        http://www.tdvs.chc.edu.tw/test/Service.asmx/HelloWorld_Yuping
        Content-Type:   "application/x-www-form-urlencoded"
    ]
    to string! data
]
probe to string! result
wait 3