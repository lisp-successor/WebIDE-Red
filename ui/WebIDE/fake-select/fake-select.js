//http://stackoverflow.com/questions/26239087/bold-text-in-select-list
//http://jsfiddle.net/ahcpuewf/
//http://jsfiddle.net/q3uketo9/
function init_fake_select(selectOption_ondblclick){
    var selectOptionsBox = document.getElementById("selectOptionsBox");
    selectOptionsBox.last_selectOption = null;
    for (var i = 0; i < selectOptionsBox.children.length; i++) {
        (function(i) {
            selectOptionsBox.children[i].onclick = function() {
                if (selectOptionsBox.last_selectOption != null) {
                    selectOptionsBox.last_selectOption.className = '';
                }
                selectOptionsBox.last_selectOption = this;
                selectOptionsBox.last_selectOption.className = 'selectedOption';
            }
            if (selectOption_ondblclick!= null) {
                selectOptionsBox.children[i].ondblclick = selectOption_ondblclick;
            }
        })(i);
    }
    var selectBox = document.getElementById("selectBox");
    selectBox.str_filter = '';
    selectBox.oninput = function(){
        selectBox.str_filter = this.value.trim();
        if (selectBox.str_filter.length > 0) {
            for (var i=1; i<selectOptionsBox.children.length; i++) {
                var idx = selectOptionsBox.children[i].innerHTML.replace(/<b>/g, '').replace(/<\/b>/g, '').indexOf(this.value);
                if (idx > -1) {
                    selectOptionsBox.children[i].style.display = 'block';
                } else {
                    selectOptionsBox.children[i].style.display = 'none';
                }
            }
        } else {
	        for (var i=1; i<selectOptionsBox.children.length; i++) {
                if (selectOptionsBox.children[i].style.display == 'none') {
                    selectOptionsBox.children[i].style.display = 'block';
                }
            }
        }
    }
}
//<div id="fakeSelect">
//    <input id="selectBox"/>
//    <ul id="selectOptionsBox">
//        <li>Manni</li>
//        <li>Manni - Haraldarmanni</li>
//        <li>Manni - <b>Hornafjarearmanni</b></li>
//        <li>Manni - Laugarvatnsmanni</li>
//    </ul>
//</div>