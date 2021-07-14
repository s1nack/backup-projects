var obj;
var act = 0;

var clrOrg;
var TimerID;

var pasR = 102	// non-active link Red
var pasG = 102	// non-active link Green
var pasB = 102	// non-active link Blue

var actR = 204	// active link Red
var actG = 153	// active link Green
var actB = 153	// active link Blue

var curR = pasR	// active link Red
var curG = pasG	// active link Green
var curB = pasB	// active link Blue

document.onmouseover = doColor;
document.onmouseout = stopColor;

function doColor()
{
	if ( act != 1) {
		obj = event.srcElement;

		while ( obj.tagName != 'A' && obj.tagName != 'BODY' ) {
			obj = obj.parentElement;
			if ( obj.tagName == 'A' || obj.tagName == 'BODY' )
				break;
		}

		if (obj.tagName == 'A' && obj.href != '') {

			curR = pasR;
			curG = pasG;
			curB = pasB;

			act = 1;
			clrOrg = obj.style.color;
			TimerID = setInterval( "ChangeColor()", 16 );
		}
	}
}



function stopColor()
{
	if ( act == 1 ) {
		if ( obj.tagName == 'A' ) {
			obj.style.color = clrOrg;

			curR = pasR
			curG = pasG
			curB = pasB

			clearInterval(TimerID);

			act = 0;
		}
	}
}

function ChangeColor()
{
	if ( act == 1) {
        if ( curR == actR ) {
			clearInterval(TimerID);
		}
		else {
			if ( curR < actR )
				curR = curR + 1;

			if ( curG < actG )
				curG = curG + 1;

			if ( curB < actB )
				curB = curB + 1;

			obj.style.color = '#' + curR.toString(16) + curG.toString(16) + curB.toString(16);
		}
	}
}
