var SectionBuffer='';var SectionModified=new Array();function closesurvey(id){if(window.submitted){return;}window.submitted=true;var isKBEmbedded=false;if(id==10){isKBEmbedded=true;id=1;}readAnswers();writeAnswers(id,isKBEmbedded);if(g_surveystyle=="embedded"){document.getElementById("FMSACTION").value="FINISHEMBED:"+g_URL;}if(id==0||g_surveystyle=="embedded"){if(g_ISCONTACTUS)
document.forms["frmSurveyMain"].action="https://"+g_servername+"/contactus/feedback.aspx";else
document.forms["frmSurveyMain"].action="https://"+g_servername+"/common/survey.aspx";document.forms["frmSurveyMain"].submit();delayhalfsecond();}else if(typeof(g_ISCONTACTUS)=='undefined'||!g_ISCONTACTUS){var framefields=document.frames("submitframe").document.getElementsByTagName("INPUT");var i=0;for(i=0;i<framefields.length;i++){var formfield=document.getElementById(framefields[i].id);if(formfield!=null){framefields[i].value=formfield.value;}}if(document.frames("submitframe").document.forms[0]!=null){document.frames("submitframe").document.forms[0].submit();}delayhalfsecond(1500);}if(bClickCancel==1&&g_surveystyle!="embedded"){window.top.close();location.reload();}}

function shownext(mode){if(mode=="1"&&!validateAll())return false;resetFailMsgs();if(mode=="0")
restoreSectionValues(currentsectionid);if(mode=="1"&&SectionModified[currentsectionid]!=1){SectionModified[currentsectionid]=1;}var nextsectionid="";var tempbuffer;nextsectionid=DecideNextSectionByBranching(currentsectionid);if(nextsectionid==null||nextsectionid==""){tempbuffer=document.getElementById(currentsectionid+"___NEXTSECTION");if(tempbuffer!=null){nextsectionid=tempbuffer.value;}}if(nextsectionid==null||nextsectionid==""||nextsectionid<=0){tempbuffer=document.getElementById(currentsectionid+"___NEXTSECTIONINORDER");if(tempbuffer!=null){nextsectionid=tempbuffer.value;}}if(nextsectionid==null||nextsectionid=="")
nextsectionid=navpath[navindex+1];
navpath[navindex]=currentsectionid;currentsection=document.getElementById("DIV_"+navpath[navindex]);var previoussection=currentsection;if(nextsectionid!=null&&nextsectionid>0)
currentsectionid=nextsectionid;else
currentsectionid="notexist";currentsection=document.getElementById("DIV_"+currentsectionid);if(currentsection!=null){currentsection.style.display="block";if(previoussection!=null)previoussection.style.display="none";}else
closesurvey(0);navindex++;rememberSectionValues(currentsectionid);window.scrollTo(0,0)}function showprevious(){resetFailMsgs();navpath[navindex]=currentsectionid;var currentsection=document.getElementById("DIV_"+navpath[navindex]);if(currentsection!=null)currentsection.style.display="none";if(navpath[navindex-1]>=0){currentsectionid=navpath[navindex-1];}else{var tempbuffer=document.getElementById(currentsectionid+"___PREVSECTIONINORDER");if(tempbuffer!=null&&tempbuffer.value!=""){currentsectionid=tempbuffer.value;}else
currentsectionid--;if(currentsectionid<0)
currentsectionid=0;}currentsection=document.getElementById("DIV_"+currentsectionid);if(currentsection!=null){currentsection.style.display="block";}navindex--;rememberSectionValues(currentsectionid);window.scrollTo(0,0)}function addAnswer(sName,sOptionValue,sOptionText,sType,sAnswerID){var sQuestionID;var sOptionID="0";sQuestionID=sName;
if(sAnswerID!='')
sOptionID=sAnswerID;if(g_iAnswerPtr>0&&(sType=="text"||sType=="textarea"||sType=="password")){if(sQuestionID==g_asAnswers[g_iAnswerPtr-1][0]&&sOptionID==g_asAnswers[g_iAnswerPtr-1][1]&&''==g_asAnswers[g_iAnswerPtr-1][3]){
g_asAnswers[g_iAnswerPtr-1][3]=UnicodeFixup(escape(sOptionText));return;}}g_asAnswers[g_iAnswerPtr]=new Array('','','','','');g_asAnswers[g_iAnswerPtr][0]=sQuestionID;g_asAnswers[g_iAnswerPtr][1]=sOptionID;g_asAnswers[g_iAnswerPtr][2]=sOptionValue;g_asAnswers[g_iAnswerPtr][3]=UnicodeFixup(escape(sOptionText));g_asAnswers[g_iAnswerPtr][4]=sType.toLowerCase();g_iAnswerPtr++;}function readAnswers(){


var o=document.forms["frmSurveyMain"];for(var i=0;i<o.elements.length;i++){var e=o.elements[i];var sType=(e.type).toLowerCase();switch(sType){case "radio":
if(e.checked){var radioname=e.name;var dash=radioname.indexOf("_");
if(dash!=-1)
radioname=radioname.substring(0,dash);if(e.value<0){addAnswer(radioname,-(e.value),eval('o.'+e.name+'.value'),sType,e.id);}else{var temptxt=e.title;
if(typeof(temptxt)=='undefined')
temptxt='';addAnswer(radioname,e.value,temptxt,sType,e.id);}}break;case "checkbox":
if(e.checked){if(e.value<0){addAnswer(e.name,-(e.value),eval('o.'+e.name+'.value'),sType,e.id);}else{addAnswer(e.name,e.value,'',sType,e.id);}}break;case "select-one":
if(e.selectedIndex>=0){var indexs=e.name.indexOf("s");var indexq=e.name.indexOf("q");if(indexs==-1||indexq==-1||indexq-indexs<2)
break;var sname=parseInt(e.name.substring(indexs+1,indexq));
if(SectionModified[sname]==1){
var txt='';try{txt=e.options[e.selectedIndex].text;}catch(e){txt='';}addAnswer(e.name,e.value,txt,sType,e.options[e.selectedIndex].id);}}break;case "select-multiple":
for(var j=0;j<e.options.length;j++){var u=e.options[j];if(u.selected){addAnswer(e.name,u.value,'',sType,u.id);}}break;case "text":
case "textarea":
case "password":


if((""!=e.value)&&(-1==(e.name).indexOf('_TEXT'))){addAnswer(e.name,0,e.value,sType,e.id);}break;}}}


function writeAnswers(id,isKBEmbedded){document.getElementById("SURVEYSCID").value=g_SCID;document.getElementById("SITE").value=g_SITE;document.getElementById("REGIONID").value=g_REGIONID;document.getElementById("BROWSERLANGCODE").value=g_BROWSERLANGCODE;document.getElementById("SURVEYLANGCODE").value=g_SURVEYLANGCODE;document.getElementById("SURVEYID").value=g_SURVEYID;document.getElementById("SURVEYNAME").value=g_SURVEYNAME;document.getElementById("FMSURL").value=g_URL;if(document.getElementById("CONTACTUSQUERYSTRINGS")!=null)
document.getElementById("CONTACTUSQUERYSTRINGS").value=g_CONTACTUSQUERYSTRINGS;if(document.getElementById("CLIENTOSLANG")!=null){if(typeof(window.navigator.systemLanguage)=='undefined')
document.getElementById("CLIENTOSLANG").value=window.navigator.language;else
document.getElementById("CLIENTOSLANG").value=window.navigator.systemLanguage;}if(id!=0||isKBEmbedded){document.getElementById("FMSACTION").value="GIVEUP";}if(g_asParams!=null){document.getElementById("PARAMLENGTH").value=g_asParams.length;var params=document.getElementById("PARAMS");params.value='';
for(var i=0;i<g_asParams.length;i++){params.value+=g_asParams[i];if(i<g_asParams.length-1)params.value+=",";}}else{document.getElementById("PARAMLENGTH").value="0";document.getElementById("PARAMS").value="";}document.getElementById("DATALENGTH").value=g_asAnswers.length;var answers=document.getElementById("SURVEYANSWERS");answers.value="";
for(var i=0;i<g_asAnswers.length;i++){var SQID=g_asAnswers[i][0].substring(1,g_asAnswers[i][0].length);
SQID=SQID.replace("q",",");answers.value+=(SQID+","+g_asAnswers[i][1]+","+g_asAnswers[i][2]+","+g_asAnswers[i][3]);answers.value+="|";}if(isKBEmbedded)
id=0;answers.value+=id;}function SurveyLoad(){if(g_surveystyle=="full screen")
resizeTo(screen.availWidth,screen.availHeight);else{
var surveyStyle=queryString['surveystyle'];
if(surveyStyle!=null&&surveyStyle.toLowerCase()=="popup")
resizeTo(725,500);}var hrefs=document.getElementsByTagName("A");var i=0;for(i=0;i<hrefs.length;i++){if(hrefs[i].href!=null&&hrefs[i].href!=""&&hrefs[i].href.toLowerCase().indexOf("javascript")<0)
hrefs[i].target="_blank";}if(g_showall==1)
AppendBranchInfoToCtrl();SurveyMNPAdjust();}function SurveyUnload(){if((!window.submitted)&&(g_showall!=1)){if(currentsectionid==0){closesurvey(2);}else{restoreSectionValues(currentsectionid)
closesurvey(1);}}}function rememberSectionValues(sid){SectionBuffer="";if(SectionModified[sid]!=1)
return;var o=document.forms["frmSurveyMain"];var nameprefix="s"+sid+"q";for(var i=0;i<o.elements.length;i++){var e=o.elements[i];var sType=(e.type).toLowerCase();switch(sType){case "radio":
case "checkbox":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;if(e.checked)
SectionBuffer+="1;";else
SectionBuffer+="0;"
break;case "select-one":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;SectionBuffer+=e.selectedIndex+";";break;case "select-multiple":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;for(var j=0;j<e.options.length;j++){var u=e.options[j];if(u.selected)
SectionBuffer+="1";else
SectionBuffer+="0";}SectionBuffer+=";"
break;case "text":
case "textarea":
case "password":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;if(e.disabled){e.value="";break;}

if(-1==(e.name).indexOf('_TEXT')){SectionBuffer+="'"+Replace(e.value,"'","''")+"$';"}break;}}}function restoreSectionValues(sid){var IsFirstPage=false;if(SectionBuffer==""){IsFirstPage=true;}var index=0;var o=document.forms["frmSurveyMain"];var nameprefix="s"+sid+"q";for(var i=0;i<o.elements.length;i++){var e=o.elements[i];var sType=(e.type).toLowerCase();switch(sType){case "radio":
case "checkbox":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;if(IsFirstPage){e.checked=false;break;}if(SectionBuffer.charAt(index)=='1')
e.checked=true;if(SectionBuffer.charAt(index)=='0')
e.checked=false;index+=2;break;case "select-one":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;if(IsFirstPage){
break;}var endindex=SectionBuffer.indexOf(";",index);if(endindex<0)return;e.selectedIndex=parseInt(SectionBuffer.substring(index,endindex));index=endindex+1;break;case "select-multiple":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;for(var j=0;j<e.options.length;j++){var u=e.options[j];if(IsFirstPage){u.checked=false;continue;}if(SectionBuffer.charAt(index)=='1')
u.selected=true;if(SectionBuffer.charAt(index)=='0')
u.selected=false;index++;}index++;break;case "text":
case "textarea":
case "password":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;

if(-1==(e.name).indexOf('_TEXT')){if(IsFirstPage){e.value="";break;}var indexend=index+1;indexend=SectionBuffer.indexOf("$';",indexend);if(indexend==-1)
return;
if(indexend>index+1){e.value=Replace(SectionBuffer.substring(index+1,indexend),"''","'");}else
e.value="";index=indexend+3;}break;}}}function Replace(strOrig,str1,str2){if(strOrig.length==0||str1.length==0)
return strOrig;var index=0;var indexend=0;var len1=str1.length;var result="";do{indexend=strOrig.indexOf(str1,index);if(indexend==-1){indexend=strOrig.length;}result+=strOrig.substring(index,indexend);if(indexend!=strOrig.length)
result+=str2;index=indexend+len1;if(index>=strOrig.length)
break;}while(true);return result;}function handleKeypress(){if(typeof(event)=='undefined')
return;if(event.keyCode==27&&g_surveystyle=="embedded"){SurveyUnload();}if(event.keyCode==13){if(window.event.srcElement==null||window.event.srcElement.type!="textarea")
shownext(1);}}function DecideNextSectionByBranching(sid){var o=document.forms["frmSurveyMain"];var nameprefix='s'+sid+'q';for(var i=0;i<o.elements.length;i++){var e=o.elements[i];var sType=(e.type).toLowerCase();switch(sType){case "radio":
case "checkbox":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;if(e.checked){var elementid=sid+"___"+e.name+"___";var hiddensec=document.getElementById(elementid+e.id);
if(hiddensec==null&&sType=="radio"){hiddensec=document.getElementById(elementid+e.value);}if(hiddensec!=null)
return hiddensec.value;}break;case "select-one":
case "select-multiple":
if(e.name==null||e.name.indexOf(nameprefix)!=0)
break;for(var j=0;j<e.options.length;j++){var u=e.options[j];if(u.selected){var elementid=sid+"___"+e.name+"___"+u.id;var hiddensec=document.getElementById(elementid);if(hiddensec!=null)
return hiddensec.value;}}break;default:
break;}}return "";}function enforceMaxLength(oElement,iMaxLength){if(oElement.value.length>iMaxLength){oElement.value=(oElement.value).substring(0,iMaxLength);event.returnValue=false;}return;}
function checkvalid(){var requiredObjects=document.getElementsByName("requiredhidden");if(requiredObjects.length==0)
return true;var index=0;var o=document.forms["frmSurveyMain"];var nameprefix="s"+currentsectionid+"q";var objindex=0;var bfind=0;for(index=0;index<requiredObjects.length;index++){var id=requiredObjects[index].id;var value=requiredObjects[index].value;var qindex=id.indexOf("q");var sindex=id.indexOf("s");var isection=parseInt(id.substring(sindex+1,qindex));if(isection!=currentsectionid)
continue;var iquestion=parseInt(id.substring(qindex+1,id.length));var istextin=id.indexOf("textin");if(value==null||value=="")
value="Please answer the required question!";bfind=0;do{var e=o.elements[objindex];if(e.name==null||e.name.indexOf(nameprefix)!=0){objindex++;continue;}var e_end=e.name.indexOf("_");if(e_end<0)
e_end=e.name.length;var equestion=parseInt(e.name.substring(nameprefix.length,e_end));if(equestion!=iquestion){objindex++;continue;}var sType=(e.type).toLowerCase();switch(sType){case "radio":
case "checkbox":
if(e.checked&&istextin<0){bfind=1;break;}if(!e.checked&&istextin>=0&&("textin_"+e.name+"_"+e.id==id)){bfind=1;break;}break;case "select-one":
case "select-multiple":
for(var j=0;j<e.options.length;j++){var u=e.options[j];if(u.selected&&u.value!=""&&u.id!=""){bfind=1;}}break;case "text":
case "textarea":
case "password":


if(e.value!="")
bfind=1;break;}objindex=objindex+1;if(bfind==1)
break;}while(objindex<o.length)
if(bfind!=1){alert(value);return false;}}return true;}function readSubmitNewWindowClose(newURL){var iHeight=300,iWidth=400;if(readSubmitNewWindowClose.arguments.length>1){iHeight=readSubmitNewWindowClose.arguments[1];}if(readSubmitNewWindowClose.arguments.length>2){iWidth=readSubmitNewWindowClose.arguments[2];}window.open(newURL,'_self','resizable=yes,scrollbars=yes,menubar=no,location=no,toolbar=no,status=no,height='+iHeight+',width='+iWidth);closesurvey(1);}function AppendBranchInfoToCtrl(){var o=document.forms["frmSurveyMain"];var nameprefix='s'+sid+'q';for(var i=0;i<o.elements.length;i++){var e=o.elements[i];var sType=(e.type).toLowerCase();if(e.name==null)
continue;var indexs=e.name.indexOf("s");var indexq=e.name.indexOf("q");if(indexs<0||indexq<0)
continue;var sid=e.name.substring(indexs+1,indexq);switch(sType){case "radio":
case "checkbox":
var elementid=sid+"___"+e.name+"___";var hiddensec=document.getElementById(elementid+e.id);
if(hiddensec==null&&sType=="radio"){hiddensec=document.getElementById(elementid+e.value);}if(hiddensec!=null){e.outerHTML=e.outerHTML+"<font color='green'>(-->"+hiddensec.value+")</font>";}break;case "select-one":
case "select-multiple":
for(var j=0;j<e.options.length;j++){var u=e.options[j];var elementid=sid+"___"+e.name+"___"+u.id;var hiddensec=document.getElementById(elementid);if(hiddensec!=null){u.innerHTML=u.innerHTML+"(-->"+hiddensec.value+")";}}break;default:
break;}}}
function SwitchSurveyLink(id){
var surveyLink=document.getElementById("SendFeedback_tr");if(surveyLink!=null){if(id==0)
surveyLink.style.display="none";else
surveyLink.style.display="block";}}function KBFeedBackShowSurvey(){g_kbvisited=fetchcookieval("kbvisited");if(g_currentContent==null||g_currentContent=="")
return;g_currentContent=g_currentContent.replace(";",":");g_currentContent=g_currentContent.replace(";",":");if(g_kbvisited==null||g_kbvisited.charAt(0)!='|')
g_kbvisited="";var index=g_kbvisited.indexOf(g_currentContent);if(index>0){lastSection.style.display="block";SwitchSurveyLink(0);}else{firstSection.style.display="block";SwitchSurveyLink(1);}}function findParent(el,type){var p=el.parentNode;if(!p)return false;if(p.tagName&&p.tagName.toLowerCase()==type)return p;else return findParent(p,type);}function handleOptionalTxt(el){if(el.type!="radio")return;var f=findParent(el,"form");if(f){var e=f.elements;for(var i=0;i<e.length-1;i++){if(e[i].type=="radio"&&e[i+1].className=="OPTIONALTEXTBOX"){e[i+1].disabled=!e[i].checked;}}}}function SwitchSection(){firstSection.style.display="none";lastSection.style.display="block";SwitchSurveyLink(0);var i=0;var count=0;for(i=0;i<g_kbvisited.length;i++){if(g_kbvisited.charAt(i)=='|')
count++;}if(count>=g_maxKBsInCookie){var index=g_kbvisited.indexOf("|",1);g_kbvisited=g_kbvisited.substring(index,g_kbvisited.Length);}g_kbvisited=g_kbvisited+"|"+g_currentContent;srch_setcookieval("kbvisited",g_kbvisited);}function SurveyMNPAdjust(){RemoveMsviGlobalSearch();var globalSearch=document.getElementById("msviGlobalSearch");if(globalSearch!=null)
globalSearch.style.display='block';
var localToolbar=document.getElementById("msviLocalToolbar");if(localToolbar!=null)
localToolbar.style.display="none";MNPResizeFix();}function getMsgElement(e){var p=e.previousSibling;if(!p||p.name!="FMSError"){p=document.createElement("div");p.name="FMSError";p.className="QUESTIONREQUIRED";p.innerHTML=e.failmsg;p.style.display="none";e.parentNode.insertBefore(p,e);}return p;}function validateAll(){var e=document.forms["frmSurveyMain"].elements;for(var i=0;i<e.length;i++){if(isVisible(e[i])&&!validate(e[i]))return false;}return true;}function isVisible(e){if(e.style&&e.style.display=="none")return false;if(!e.parentNode)return true;return isVisible(e.parentNode);}function resetFailMsgs(){var e=document.forms["frmSurveyMain"].elements;var ps;for(var i=0;i<e.length;i++){ps=e[i].previousSibling;if(ps&&ps.name=="FMSError")ps.style.display="none";}}function validate(e,ev){var m=getMsgElement(e);if(m&&!passesFilter(e)&&isVisible(e)){m.style.display="block";m.style.visibility="visible";e.focus();return false;}m.style.visibility="hidden";return true;}function passesFilter(e){if(!e.pattern)return true;var rx=new RegExp(e.pattern);return rx.test(e.value);}function getLatestElement(){var e=document.body;while(e.lastChild)e=e.lastChild;while(!e.tagName)e=e.parentNode;return e;}function getSurveyParams(){var v,p=new Array();for(var i=0;i<10;i++){v=queryString['p'+i];if(!v)v="";p.push(v);}return p;}