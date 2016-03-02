Red [
    title: "Calculator"
    Needs: 'View
]
view [
    title "Red Calculator"
    field-text: field "" 250x24 return
    group-box 4 [
        style btn-num: button 50x50 [append field-text/text face/text]
        style btn-op:  button 50x50 [append field-text/text reduce [" " face/text " "]]
        style btn-clr: button 50x50 [field-text/text: make string! 0]
        btn-num "7" btn-num "8" btn-num "9" btn-op "/"
        btn-num "4" btn-num "5" btn-num "6" btn-op "*"
        btn-num "1" btn-num "2" btn-num "3" btn-op "-"
        btn-num "0" btn-num "." btn-clr "C" btn-op "+"
    ] return
    button "=" 250x50 [field-text/text: either none? re: attempt [form do field-text/text][make string! 0][re]]
]