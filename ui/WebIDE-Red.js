window.onload=function(){function e(){Split(["#toolbar","#content"],{sizes:[10,90],minSize:[50,50,0],direction:"vertical"}),Split(["#editor_tool","#red_source"],{sizes:[30,70],minSize:[100,100]}),Split(["#github","#red_tool"],{sizes:[50,50],minSize:[30,30],direction:"vertical"}),Split(["#interpret","#compile"],{sizes:[50,50],minSize:[100,100]}),Split(["#tabs","#explorer"],{sizes:[80,20],minSize:[100,100]})}function n(){function e(){arguments[0].innerHTML.lastIndexOf("/")>-1?("../"==arguments[0].innerHTML?(work_dir=work_dir.slice(0,-1),work_dir=work_dir.substr(0,work_dir.lastIndexOf("/")+1)):(last_dir=arguments[0].innerHTML,work_dir+=arguments[0].innerHTML),div_work_dir.innerHTML=work_dir,w.send(n(["list-dir-file",work_dir],""))):(last_file=arguments[0].innerHTML,w.send(n(["read",work_dir+arguments[0].innerHTML],"")))}function n(e,n){var t=null;if("string"==typeof n){var i=e.join("|"),a=unescape(encodeURIComponent(i)).length,r=unescape(encodeURIComponent(i+n)),t=new DataView(new ArrayBuffer(r.length+2));t.setUint16(0,a,!littleEndian);for(var s=0;s<r.length;s++)t.setUint8(s+2,255&r.charCodeAt(s))}else{var i=unescape(encodeURIComponent(e.join("|"))),t=new DataView(new ArrayBuffer(2+i.length+n.length));t.setUint16(0,i.length,!littleEndian);for(var s=0;s<i.length;s++)t.setUint8(s+2,255&i.charCodeAt(s));for(var s=0;s<n.length;s++)t.setUint8(s+2+i.length,n[s])}return t.buffer}function t(e){var n=new DataView(e),t=n.getUint16(0,!littleEndian),i=String.fromCharCode.apply(null,new Uint8Array(e,2,t)),a=String.fromCharCode.apply(null,new Uint8Array(e,2+t)),r=decodeURIComponent(escape(a));return{keys:i.split("|"),value:r}}function i(e){if(null!=dicLanguage)for(var n in dicLanguage){var t=document.getElementById(n);null!=t&&(t.innerHTML=dicLanguage[n][e])}}function a(e){if(e)w.send(n(["write-one-unzip",o.file_name],o.data));else{var t=s.shift(),i=d.readBinary(t);i.status&&(w.send(n(["write-one-unzip",t],i.data)),lbl_progress.innerHTML=dicLanguage.msg_unzipping[select_ui_language.selectedIndex]+"("+Math.ceil((l-s.length)/l*100)+"%)",o.file_name=t,o.length=i.data.length,o.data=i.data)}}function r(e){lbl_progress.innerHTML=dicLanguage.msg_compiling[select_ui_language.selectedIndex];var t=["upgrade",e];ckb_needs_view.checked?t.push("needs-view"):t.push(""),ckb_debug_interpret.checked?t.push("-d"):t.push(""),w.send(n(t,""))}work_dir=last_dir=last_file=target_os_default="",littleEndian=function(){var e=new ArrayBuffer(2);return new DataView(e).setInt16(0,256,!0),256===new Int16Array(e)[0]}(),webide_config_obj={},bln_upgrade_red_manual=!1,bln_restart=!1,select_ui_language0.onchange=function(){this.selectedIndex>0&&(first_time.style.display="none",after_first_time.style.visibility="",select_ui_language.selectedIndex=this.selectedIndex-1,select_ui_language.onchange())},select_ui_language.onchange=function(){i(this.selectedIndex),w.send(n(["write-ui-language",this.selectedIndex],""))},btn_save.onclick=function(){""!=last_file&&w.send(n(["write",work_dir+last_file],ace.edit("editor").getSession().getValue()))};var s=[],l=0,d=null,o={file_name:"",length:0,data:null};ckb_needs_view.checked=!0,red_zip_url="https://github.com/qtxie/red/zipball/MacOSX-GUI/",btn_upgrade_red.onclick=function(){if(0==bln_upgrade_red_manual)if(confirm(dicLanguage.msg_ask_upgrade_red[select_ui_language.selectedIndex])){btn_upgrade_red.style.display="none",lbl_progress.innerHTML=dicLanguage.msg_downloading[select_ui_language.selectedIndex];var e=red_zip_url+(/\?/.test(red_zip_url)?"&":"?")+(new Date).getTime(),t=new XMLHttpRequest;t.open("GET",e,!0),t.responseType="arraybuffer",t.onreadystatechange=function(){if(4==t.readyState&&200==t.status){d=new JSUnzip;var e=d.open(new Uint8Array(t.response));if(e.status){for(var n in d.files)"/"!=n.substr(n.length-1)&&-1==n.indexOf("/system/tests/")&&-1==n.indexOf("/quick-test/")&&-1==n.indexOf("/docs/")&&-1==n.indexOf("/tests/source/")&&s.push(n);l=s.length,a(!1)}else alert("Error: "+e.error)}},t.onprogress=function(e){e.lengthComputable?lbl_progress.innerHTML=dicLanguage.msg_downloading[select_ui_language.selectedIndex]+"("+Math.ceil(e.loaded/e.total*100)+"%)":lbl_progress.innerHTML=dicLanguage.msg_downloading[select_ui_language.selectedIndex]+'('+Math.ceil(event.loaded/1024)+' KB / ?)'},t.send(null)}else{bln_upgrade_red_manual=!0;var i=document.createElement("a");i.href=red_zip_url+(/\?/.test(red_zip_url)?"&":"?")+(new Date).getTime(),i.target="blank",i.style.display="none",document.body.appendChild(i),i.click(),document.body.removeChild(i),delete i,btn_upgrade_red.innerHTML=dicLanguage.btn_upgrade_red_manual[select_ui_language.selectedIndex];var r=dicLanguage.msg_ask_upgrade_red_manual[select_ui_language.selectedIndex]+' "'+dicLanguage.btn_upgrade_red_manual[select_ui_language.selectedIndex]+'"\r\n'+webide_config_obj.red_source_dir+"\r\n";alert(r),w.send(n(["list-red-source-dir","0"],""))}else w.send(n(["list-red-source-dir","1"],""))},select_red_dir.onchange=function(){w.send(n(["change-red-dir",this.value],""))},lbl_red_version.onclick=function(){return this.href="https://github.com/red/red/commit/"+select_red_dir.value.replace("red-red-",""),!0},ckb_close_front_interpret.checked=!0,btn_interpret.onclick=function(){""!=last_file&&(ckb_close_front_interpret.checked?w.send(n(["do","kill-front",work_dir+last_file],"")):w.send(n(["do","keep-front",work_dir+last_file],"")))},select_compile.innerHTML="",aryOS=["windows","Windows","msdos","Windows(console)","darwin","MacOSX","linux","Linux"];for(var c=0;c<aryOS.length/2;c++){var u=document.createElement("option");u.value=aryOS[2*c],u.innerHTML=aryOS[2*c+1],select_compile.appendChild(u)}ckb_run.checked=!0,btn_compile.onclick=function(){if(""!=last_file){var e=["compile",work_dir+last_file,select_compile.value];ckb_debug_mode.checked?e.push("-d"):e.push(""),ckb_run.checked?e.push("run"):e.push(""),w.send(n(e,""))}},w=new WebSocket("ws://127.0.0.1:8080/ws1"),w.binaryType="arraybuffer",w.onopen=function(){w.send(n(["dto-id","5C0A91CD-8B1D-5176-4F73-84574F5C6B0A"],""))},w.onmessage=function(i){var l=t(i.data);switch(l.keys[0]){case"dto-id":webide_config_obj=JSON.parse(l.value),w.send(n(["read-ui-language",""],""));break;case"read-ui-language":var d=l.value.split("\r\n");if(d.length>1){dicLanguage={};var c=d[0].split("	");c.splice(0,1),dicLanguage.__CsvColumnName__=c}for(var u=1;u<d.length;u++){var _=d[u].split("	");dicLanguage[_[0]]=[];for(var g=1;g<_.length;g++)dicLanguage[_[0]].push(_[g].replace(/\\r\\n/g,"\r\n"))}dicLanguage.__CsvColumnName__.map(function(e,n,t){var i=document.createElement("option"),a=document.createElement("option");i.value=i.innerHTML=a.value=a.innerHTML=e,select_ui_language0.appendChild(i),select_ui_language.appendChild(a)}),""!=webide_config_obj.ui_language_id&&(select_ui_language.selectedIndex=parseInt(webide_config_obj.ui_language_id),webide_config_obj.ui_language_id="",select_ui_language.onchange(),first_time.style.display="none",after_first_time.style.visibility="");break;case"write-ui-language":""==webide_config_obj.ui_language_id&&w.send(n(["list-dir-file",""],"")),webide_config_obj.ui_language_id=l.keys[1];break;case"list-dir-file":if(""==work_dir)work_dir=l.value,work_dir+="example/",div_work_dir.innerHTML=work_dir,w.send(n(["list-dir-file",work_dir],""));else{if(selectOptionsBox.innerHTML="",""!=l.value){var p=-1;l.value.split("|").map(function(e,n,t){var i=document.createElement("li");i.innerHTML=e,"/"==e.substr(e.length-1)&&(i.style.backgroundColor="#BBBB00",last_dir==e&&(p=n+1)),selectOptionsBox.appendChild(i)})}var f=document.createElement("li");f.innerHTML="../",f.style.backgroundColor="#BBBB00",selectOptionsBox.insertBefore(f,selectOptionsBox.children[0]),init_fake_select(function(){e(this)}),p>-1&&selectOptionsBox.children[p].onclick(),""==target_os_default&&w.send(n(["target-os-default"],""))}break;case"read":ace.edit("editor").getSession().setValue(l.value,-1);break;case"write":break;case"target-os-default":target_os_default=l.value;for(var u=0;u<select_compile.length;u++)if(l.value==select_compile.options[u].value){select_compile.selectedIndex=u;break}"windows"!=l.value&&(ckb_needs_view.style.display=lbl_needs_view.style.display="none",ckb_needs_view.checked=!1),w.send(n(["list-red-dir",""],""));break;case"list-red-dir":select_red_dir.innerHTML="",""==l.value?(document.getElementById('red_tool').style.visibility='hidden',alert(dicLanguage.msg_need_red[select_ui_language.selectedIndex])):(l.value.split("|").map(function(e,n,t){var i=document.createElement("option");i.value=e,i.innerHTML=i.value.replace("/",""),select_red_dir.appendChild(i)}),w.send(n(["change-red-dir",l.keys[1]],"")));break;case"change-red-dir":var m="";if(m=""!=l.keys[1]?l.keys[1]:l.value,""==m)select_red_dir.selectedIndex=0,select_red_dir.onchange();else if(m!=select_red_dir.value)for(var u=0;u<select_red_dir.length;u++)if(m==select_red_dir.options[u].value){select_red_dir.selectedIndex=u,select_red_dir.onchange();break}break;case"do":break;case"compile":break;case"write-one-unzip":parseInt(l.value)==o.length?s.length>0?a(!1):r(o.file_name.substr(0,o.file_name.indexOf("/")+1)):a(!0);break;case"list-red-source-dir":"1"==l.keys[1]&&""!=l.value&&r(l.value);break;case"upgrade":lbl_progress.innerHTML="",bln_restart=!0,alert(dicLanguage.msg_need_restart[select_ui_language.selectedIndex]),window.close();break;case"server-push":var h=ace.edit("server_push").getSession();h.setValue(h.getValue()+l.value,-1)}},w.onclose=function(e){},window.onbeforeunload=function(){bln_restart&&w.send(n(["restart"],""))}}function t(){_editor="editor",code=document.getElementById("txt_code").value;var e=ace.require("ace/editor").Editor,n=ace.edit(_editor);return session=n.getSession(),n.setTheme("ace/theme/github"),theme.onchange=function(){n.setTheme(this.value)},btn_foldAll.onclick=function(){ace.edit("editor").getSession().foldAll()},btn_unfoldAll.onclick=function(){ace.edit("editor").getSession().unfold()},n.setOptions({fontFamily:"consolas, monaco, monospace;",fontSize:"13pt"}),ace.config.defineOptions(e.prototype,"editor",{onlyKeywordsAutoComplete:{set:function(e){this.getOption("enableBasicAutocompletion")&&(e?(this._completers=this._completers||this.completers.slice(),this.completers=[this.completers[2]]):this._completers&&(this.completers=this._completers,this._completers=null))},value:!1}}),ace.config.loadModule("ace/ext/language_tools",function(){n.setOptions({enableBasicAutocompletion:!0,enableLiveAutocompletion:!0}),n.setOptions({onlyKeywordsAutoComplete:!0}),n.setValue(code,-1),session.setMode(ace_mode),session.setFoldStyle("markbeginend"),UseSoftTabs.onchange=function(){session.setUseSoftTabs(this.checked)},UseSoftTabs.checked=!0,ShowInvisibles.onchange=function(){n.setShowInvisibles(this.checked)},n.setHighlightSelectedWord(!0),n.commands.bindKey("Ctrl-Right","startAutocomplete")}),n}loadjs(["./WebIDE/split/split.js"],function(){e()}),loadjs(["./WebIDE/fake-select/fake-select.js","./WebIDE/jsunzip/jsunzip.js"],function(){n(),loadjs(["./WebIDE/ace/src-min/ace.js"],function(){for(var e=["./WebIDE/ace/src-min","basePath","modePath","themePath","workerPath"],n=1;n<e.length;n++)ace.config.set(e[n],e[0]);loadjs.ready("theme_init",function(){t()})})})};
