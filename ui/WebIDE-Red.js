window.onload=function(){function e(){Split(["toolbar","content","red_interpret_result"],{sizes:[10,90,0],minSize:[50,50,0],direction:"vertical"}),Split(["editor_tool","red_source"],{sizes:[30,70],minSize:[100,100]}),Split(["github","red_tool"],{sizes:[50,50],minSize:[30,30],direction:"vertical"}),Split(["interpret","compile"],{sizes:[50,50],minSize:[100,100]}),Split(["tabs","explorer"],{sizes:[80,20],minSize:[100,100]})}function n(){function e(){arguments[0].innerHTML.lastIndexOf("/")>-1?("../"==arguments[0].innerHTML?(work_dir=work_dir.slice(0,-1),work_dir=work_dir.substr(0,work_dir.lastIndexOf("/")+1)):(last_dir=arguments[0].innerHTML,work_dir+=arguments[0].innerHTML),div_work_dir.innerHTML=work_dir,w.send(n(["list-dir-file",work_dir],""))):(last_file=arguments[0].innerHTML,w.send(n(["read",work_dir+arguments[0].innerHTML],"")))}function n(e,n){var i=null;if("string"==typeof n){var t=e.join("|"),a=unescape(encodeURIComponent(t)).length,r=unescape(encodeURIComponent(t+n)),i=new DataView(new ArrayBuffer(r.length+2));i.setUint16(0,a,!littleEndian);for(var l=0;l<r.length;l++)i.setUint8(l+2,255&r.charCodeAt(l))}else{var t=unescape(encodeURIComponent(e.join("|"))),i=new DataView(new ArrayBuffer(2+t.length+n.length));i.setUint16(0,t.length,!littleEndian);for(var l=0;l<t.length;l++)i.setUint8(l+2,255&t.charCodeAt(l));for(var l=0;l<n.length;l++)i.setUint8(l+2+t.length,n[l])}return i.buffer}function i(e){var n=new DataView(e),i=n.getUint16(0,!littleEndian),t=String.fromCharCode.apply(null,new Uint8Array(e,2,i)),a=String.fromCharCode.apply(null,new Uint8Array(e,2+i)),r=decodeURIComponent(escape(a));return{keys:t.split("|"),value:r}}function t(e){for(var n=(new Date).getTime();(new Date).getTime()<n+e;);}function a(e){if(null!=dicLanguage)for(var n in dicLanguage){var i=document.getElementById(n);null!=i&&(i.innerHTML=dicLanguage[n][e])}}function r(e){if(e)w.send(n(["write-unzip",o.file_name],o.data));else{var i=s.shift(),t=c.readBinary(i);t.status&&(w.send(n(["write-unzip",i],t.data)),lbl_progress.innerHTML=dicLanguage.msg_unzipping[select_ui_language.selectedIndex]+"("+Math.ceil((d-s.length)/d*100)+"%)",o.file_name=i,o.length=t.data.length,o.data=t.data)}}function l(e){lbl_progress.innerHTML=dicLanguage.msg_compiling[select_ui_language.selectedIndex];var i=["upgrade",e];ckb_needs_view.checked?i.push("needs-view"):i.push(""),ckb_debug_interpret.checked?i.push("-d"):i.push(""),w.send(n(i,""))}work_dir=last_dir=last_file=target_os_default="",littleEndian=function(){var e=new ArrayBuffer(2);return new DataView(e).setInt16(0,256,!0),256===new Int16Array(e)[0]}(),webide_config_obj={},bln_upgrade_red_manual=!1,bln_restart=!1,select_ui_language0.innerHTML='';select_ui_language0.onchange=function(){this.selectedIndex>0&&(first_time.style.display="none",after_first_time.style.visibility="",select_ui_language.selectedIndex=this.selectedIndex-1,select_ui_language.onchange())},select_ui_language.onchange=function(){a(this.selectedIndex),w.send(n(["write-ui-language",this.selectedIndex],""))},btn_save.onclick=function(){w.send(n(["write",work_dir+last_file],ace.edit("editor").getSession().getValue()))};var s=[],d=0,c=null,o={file_name:"",length:0,data:null};ckb_needs_view.checked=!0,red_zip_url="https://github.com/red/red/zipball/master/",btn_upgrade_red.onclick=function(){if(0==bln_upgrade_red_manual)if(confirm(dicLanguage.msg_ask_upgrade_red[select_ui_language.selectedIndex])){lbl_progress.innerHTML=dicLanguage.msg_downloading[select_ui_language.selectedIndex];var e=red_zip_url+(/\?/.test(red_zip_url)?"&":"?")+(new Date).getTime(),i=new XMLHttpRequest;i.open("GET",e,!0),i.responseType="arraybuffer",i.onreadystatechange=function(){if(4==i.readyState&&200==i.status){c=new JSUnzip;var e=c.open(new Uint8Array(i.response));if(e.status){for(var n in c.files)"/"!=n.substr(n.length-1)&&-1==n.indexOf("/system/tests/")&&-1==n.indexOf("/quick-test/")&&-1==n.indexOf("/docs/")&&-1==n.indexOf("/tests/source/")&&s.push(n);d=s.length,r(!1)}else alert("Error: "+e.error)}},i.onprogress=function(e){e.lengthComputable?lbl_progress.innerHTML=dicLanguage.msg_downloading[select_ui_language.selectedIndex]+"("+Math.ceil(e.loaded/e.total*100)+"%)":lbl_progress.innerHTML=dicLanguage.msg_downloading[select_ui_language.selectedIndex]+dicLanguage.msg_unknown_size[select_ui_language.selectedIndex]},i.send(null)}else{bln_upgrade_red_manual=!0;var t=document.createElement("a");t.href=red_zip_url+(/\?/.test(red_zip_url)?"&":"?")+(new Date).getTime(),t.target="blank",t.style.display="none",document.body.appendChild(t),t.click(),document.body.removeChild(t),delete t,btn_upgrade_red.innerHTML=dicLanguage.btn_upgrade_red_manual[select_ui_language.selectedIndex];var a=dicLanguage.msg_ask_upgrade_red_manual[select_ui_language.selectedIndex]+' "'+dicLanguage.btn_upgrade_red_manual[select_ui_language.selectedIndex]+'"\r\n'+webide_config_obj.red_source_dir+"\r\n";alert(a),w.send(n(["list-red-source-dir","0"],""))}else w.send(n(["list-red-source-dir","1"],""))},select_red_dir.onchange=function(){w.send(n(["change-red-dir",this.value],""))},lbl_red_version.onclick=function(){return this.href="https://github.com/red/red/commit/"+select_red_dir.value.replace("red-red-",""),!0},ckb_close_front_interpret.checked=!0,btn_interpret.onclick=function(){ckb_close_front_interpret.checked?w.send(n(["do","kill-front",work_dir+last_file],"")):w.send(n(["do","keep-front",work_dir+last_file],""))},select_compile.innerHTML="",aryOS=["windows","Windows","msdos","Windows(console)","darwin","MacOSX","linux","Linux"];for(var u=0;u<aryOS.length/2;u++){var _=document.createElement("option");_.value=aryOS[2*u],_.innerHTML=aryOS[2*u+1],select_compile.appendChild(_)}ckb_run.checked=!0,btn_compile.onclick=function(){var e=["compile",work_dir+last_file,select_compile.value];ckb_debug_mode.checked?e.push("-d"):e.push(""),ckb_run.checked?e.push("run"):e.push(""),w.send(n(e,""))},w=new WebSocket("ws://127.0.0.1:8080/ws1"),w.binaryType="arraybuffer",w.onopen=function(){w.send(n(["dto-id","5C0A91CD-8B1D-5176-4F73-84574F5C6B0A"],""))},w.onmessage=function(a){var d=i(a.data);switch(d.keys[0]){case"dto-id":webide_config_obj=JSON.parse(d.value),w.send(n(["read-ui-language",""],""));break;case"read-ui-language":var c=d.value.split("\r\n");if(c.length>1){dicLanguage={};var u=c[0].split("	");u.splice(0,1),dicLanguage.__CsvColumnName__=u}for(var _=1;_<c.length;_++){var g=c[_].split("	");dicLanguage[g[0]]=[];for(var p=1;p<g.length;p++)dicLanguage[g[0]].push(g[p].replace(/\\r\\n/g,"\r\n"))}dicLanguage.__CsvColumnName__.map(function(e,n,i){var t=document.createElement("option"),a=document.createElement("option");t.value=t.innerHTML=a.value=a.innerHTML=e,select_ui_language0.appendChild(t),select_ui_language.appendChild(a)}),""!=webide_config_obj.ui_language_id&&(select_ui_language.selectedIndex=parseInt(webide_config_obj.ui_language_id),webide_config_obj.ui_language_id="",select_ui_language.onchange(),first_time.style.display="none",after_first_time.style.visibility="");break;case"write-ui-language":""==webide_config_obj.ui_language_id&&w.send(n(["list-dir-file",""],"")),webide_config_obj.ui_language_id=d.keys[1];break;case"list-dir-file":if(""==work_dir)work_dir=d.value,work_dir+="example/",div_work_dir.innerHTML=work_dir,w.send(n(["list-dir-file",work_dir],""));else{if(selectOptionsBox.innerHTML="",""!=d.value){var f=-1;d.value.split("|").map(function(e,n,i){var t=document.createElement("li");t.innerHTML=e,"/"==e.substr(e.length-1)&&(t.style.backgroundColor="#BBBB00",last_dir==e&&(f=n+1)),selectOptionsBox.appendChild(t)})}var m=document.createElement("li");m.innerHTML="../",m.style.backgroundColor="#BBBB00",selectOptionsBox.insertBefore(m,selectOptionsBox.children[0]),init_fake_select(function(){e(this)}),f>-1&&selectOptionsBox.children[f].onclick(),""==target_os_default&&w.send(n(["target-os-default"],""))}break;case"read":ace.edit("editor").getSession().setValue(d.value,-1);break;case"write":break;case"target-os-default":target_os_default=d.value;for(var _=0;_<select_compile.length;_++)if(d.value==select_compile.options[_].value){select_compile.selectedIndex=_;break}"windows"!=d.value&&(ckb_needs_view.style.display=lbl_needs_view.style.display="none",ckb_needs_view.checked=!1),w.send(n(["list-red-dir",""],""));break;case"list-red-dir":select_red_dir.innerHTML="",""==d.value?(Split(["github","red_tool"],{sizes:[0,100],direction:"vertical"}),alert(dicLanguage.msg_need_red[select_ui_language.selectedIndex])):(d.value.split("|").map(function(e,n,i){var t=document.createElement("option");t.value=e,t.innerHTML=t.value.replace("/",""),select_red_dir.appendChild(t)}),w.send(n(["change-red-dir",d.keys[1]],"")));break;case"change-red-dir":var b="";if(b=""!=d.keys[1]?d.keys[1]:d.value,""==b)select_red_dir.selectedIndex=0,select_red_dir.onchange();else if(b!=select_red_dir.value)for(var _=0;_<select_red_dir.length;_++)if(b==select_red_dir.options[_].value){select_red_dir.selectedIndex=_,select_red_dir.onchange();break}break;case"do":break;case"compile":break;case"write-unzip":parseInt(d.value)==o.length?s.length>0?r(!1):l(o.file_name.substr(0,o.file_name.indexOf("/")+1)):(r(!0),t(100));break;case"list-red-source-dir":"1"==d.keys[1]&&""!=d.value&&l(d.value);break;case"upgrade":lbl_progress.innerHTML="",bln_restart=!0,alert(dicLanguage.msg_need_restart[select_ui_language.selectedIndex]),window.close();break;case"server-push":var h=ace.edit("server_push").getSession();h.setValue(h.getValue()+d.value,-1)}},w.onclose=function(e){},window.onbeforeunload=function(){bln_restart&&w.send(n(["restart"],""))}}loadjs(["./WebIDE/split/split.js"],function(){e()}),loadjs(["./WebIDE/fake-select/fake-select.js","./WebIDE/jsunzip/jsunzip.js"],function(){n(),loadjs(["./WebIDE/ace/src-min/ace.js"],function(){for(var e=["./WebIDE/ace/src-min","basePath","modePath","themePath","workerPath"],n=1;n<e.length;n++)ace.config.set(e[n],e[0])})})};