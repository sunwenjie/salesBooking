var iclickIcon = window.iclickIcon || {};
iclickIcon._v = window.mv_icon_v || "./v1.png";
iclickIcon._mv = window.mv_icon_mv || "./v_b1.png";
iclickIcon._vhref = window.mv_icon_c || "http://www.baidu.com";
iclickIcon.setBgStyle = function(j) {
	if (!iclickIcon.r_w) {
		var f = document.getElementById("banner_" + window.mv_bid);
		if (!f) {
			setTimeout(function() {
				iclickIcon.setBgStyle(j)
			},
			100);
			return
		}
		var b = f.offsetWidth,
		d = f.offsetHeight
	} else {
		var b = iclickIcon.r_w,
		d = iclickIcon.r_h
	}
	var c = window.mv_bg_width || b,
	g = window.mv_bg_height || d;
	var i = (c - b) / 2;
	var a = (g - d) / 2;
	document.getElementById(j).style.cssText = "background:#f1f1f1;width:" + (c - i) + "px;height:" + (g - a) + "px;padding:" + a + "px 0 0 " + i + "px"
};
iclickIcon.lisenClick = function(i, a) {
	var b = function(m, l) {
		var n = new RegExp("(^|&)" + l + "=([^&]*)(&|$)", "i");
		var o = m.substr(1).match(n);
		if (o != null) {
			return unescape(o[2])
		}
		return null
	};
	var g = function(o, n) {
		var r, m, q, p = document.documentElement,
		l = document.body;
		m = o.pageX || o.clientX + (p && p.scrollLeft || l && l.scrollLeft || 0);
		q = o.pageY || o.clientY + (p && p.scrollTop || l && l.scrollTop || 0);
		r = k(n);
		return {
			top: Math.round(q - r.top),
			left: m - r.left
		}
	};
	var k = function(n) {
		var m = document.documentElement,
		l = document.body,
		o = {
			top: 0,
			left: 0
		};
		if (typeof n.getBoundingClientRect !== undefined) {
			o = n.getBoundingClientRect()
		}
		return {
			top: o.top + (window.pageYOffset || m.scrollTop || l.scrollTop),
			left: o.left + (window.pageXOffset || m.scrollLeft || l.scrollLeft)
		}
	};
	var f = decodeURIComponent(window["mvcu_" + mv_bid]);
	var h = g(i, a);
	var d = "http://view.iclickIcon.com/v?type=12&db=iclickIcon";
	var j = b(f, "oimpid") || b(f, "impid");
	pub = b(f, "pub"),
	cus = b(f, "cus"),
	width = a.offsetWidth,
	height = a.offsetHeight;
	d = d + "&dimpid=" + j + "&impid=" + j + "&pub=" + pub + "&cus=" + cus + "&wh=" + width + "x" + height + "&x=" + h.left + "&y=" + h.top;
	var c = new Image();
	c.onload = c.onerror = window[pub + "_mv_" + (new Date() - 0)] = function() {};
	c.src = d
};
iclickIcon.meover = function() {
	var c = arguments[0];
	var d = arguments[1];
	document.getElementById(c).style.display = "none";
	document.getElementById(d).style.display = ""
};
iclickIcon.meout = function() {
	var c = arguments[0];
	var d = arguments[1];
	document.getElementById(c).style.display = "";
	document.getElementById(d).style.display = "none"
};
function mvflash_make_button(B, r, v, p, s, C, z, y) {
	var o = "";
	iclickIcon.r_w = B;
	iclickIcon.r_h = r;
	if (o == "body") {
		o = (document.compatMode && document.compatMode != "BackCompat") ? document.documentElement: document.body
	}
	var A = "mv_swf_" + C || (new Date() - 0);
	var z = z || "Opaque";
	var u = !window.XMLHttpRequest;
	if (u) {
		var w = iclickIcon._v;
		var x = iclickIcon._mv
	} else {
		var w = iclickIcon._v;
		var x = iclickIcon._mv
	}
	var q = "<OBJECT id=" + A + ' codeBase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7" classid=clsid:D27CDB6E-AE6D-11cf-96B8-444553540000 width=' + B + " height=" + r + ' type=application/x-shockwave-flash><PARAM NAME="Movie" VALUE="' + v + '"><PARAM NAME="FlashVars" VALUE="mv_clickurl=' + escape(s) + (y ? "&" + y: "") + '"><PARAM NAME="WMode" VALUE="' + z + '"><PARAM NAME="Quality" VALUE="High"><PARAM NAME="AllowScriptAccess" VALUE="always"><PARAM NAME="Scale" VALUE="ShowAll"><PARAM NAME="AllowNetworking" VALUE="all"><PARAM NAME="AllowFullScreen" VALUE="false"><embed id="' + A + '" width="' + B + 'px" height="' + r + 'px" src="' + v + '" quality="High" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="' + z + '" allowscriptaccess="always" FlashVars="mv_clickurl=' + escape(s) + (y ? "&" + y: "") + '"></embed></OBJECT>';
	if (p == 1) {
		var t = '<div style="position: relative; z-index: 1; width:' + B + "px; height:" + r + 'px;"><div style="position: absolute; left: 0px; top: 0px; z-index: 2; width:' + B + "px; height:" + r + 'px;">';
		t += q;
		t += '</div><a id="mvclicka" target="_blank" href="' + iclickIcon._vhref + '"><img id="v616_' + A + '" onmouseover="iclickIcon.meover(\'v616_' + A + "','mv616_" + A + '\')" border="0" style="position: absolute; left: ' + (B - 19) + "px; top: " + (r - 15) + 'px; z-index: 4; width:19px;height:15px;" src="' + w + '"/><img id="mv616_' + A + '" onmouseout="iclickIcon.meout(\'v616_' + A + "','mv616_" + A + '\')" border="0" style="display:none;position: absolute; left: ' + (B - 76) + "px; top: " + (r - 15) + 'px; z-index: 4; width:76px;height:15px;" src="' + x + '"/></a></div>'
	} else {
		var t = '<div style="position: relative; z-index: 1; width:' + B + "px; height:" + r + 'px;"><div style="position: absolute; left: 0pt; top: 0pt; z-index: 2; width:' + B + "px; height:" + r + 'px;">';
		t += q;
		t += '</div><a id="mvclicka" target="_blank" href="' + s + '"><img border="0" style="position: absolute; left: 0px; top: 0px; z-index: 3; width:' + B + "px;height:" + r + 'px;" src="http://static.iclickIcon.com/1x1.gif"/></a><a target="_blank" href="' + iclickIcon._vhref + '"><img id="v616_' + A + '" onmouseover="iclickIcon.meover(\'v616_' + A + "','mv616_" + A + '\')" border="0" style="position: absolute; left: ' + (B - 19) + "px; top: " + (r - 15) + 'px; z-index: 4; width:19px;height:15px;" src="' + w + '"/><img id="mv616_' + A + '" onmouseout="iclickIcon.meout(\'v616_' + A + "','mv616_" + A + '\')" border="0" style="display:none;position: absolute; left: ' + (B - 76) + "px; top: " + (r - 15) + 'px; z-index: 4; width:76px;height:15px;" src="' + x + '"/></a></div>'
	}
	if (o == "") {
		document.write(t)
	} else {
		o.innerHTML = t
	}
}
iclickIcon.format = function(i, g) {
	i = String(i);
	var f = Array.prototype.slice.call(arguments, 1),
	h = Object.prototype.toString;
	if (f.length) {
		f = f.length == 1 ? (g !== null && (/\[object Array\]|\[object Object\]/.test(h.call(g))) ? g: f) : f;
		return i.replace(/#\{(.+?)\}/g,
		function(c, a) {
			var b = f[a];
			if ("[object Function]" == h.call(b)) {
				b = b(a)
			}
			return ("undefined" == typeof b ? "": b)
		})
	}
	return i
};
iclickIcon.makeImage = function(p, v, w, m, u) {
	var x = "";
	iclickIcon.r_w = w;
	iclickIcon.r_h = m;
	var t = "mv_swf_" + u || (new Date() - 0);
	var o = iclickIcon.format('<a href="#{0}" target="_blank"><img src="#{1}" alt="" border="" width="#{2}" height="#{3}"></img></a>', v, p, w, m);
	var q = !window.XMLHttpRequest;
	if (q) {
		var r = iclickIcon._v;
		var s = iclickIcon._mv
	} else {
		var r = iclickIcon._v;
		var s = iclickIcon._mv
	}
	var n = '<div style="position: relative; z-index: 1; width:' + w + "px; height:" + m + 'px;"><div style="position: absolute; left: 0px; top: 0px; z-index: 2; width:' + w + "px; height:" + m + 'px;">';
	n += o;
	n += '</div><a id="mvclicka" target="_blank" href="' + iclickIcon._vhref + '"><img id="v616_' + t + '" onmouseover="iclickIcon.meover(\'v616_' + t + "','mv616_" + t + '\')" border="0" style="position: absolute; left: ' + (w - 19) + "px; top: " + (m - 15) + 'px; z-index: 4; width:19px;height:15px;" src="' + r + '"/><img id="mv616_' + t + '" onmouseout="iclickIcon.meout(\'v616_' + t + "','mv616_" + t + '\')" border="0" style="display:none;position: absolute; left: ' + (w - 76) + "px; top: " + (m - 15) + 'px; z-index: 4; width:76px;height:15px;" src="' + s + '"/></a></div>';
	if (x) {
		x.innerHTML = n
	} else {
		document.write(n)
	}
};
iclickIcon.makeFlash = mvflash_make_button;
iclickIcon.G = function(a) {
	return document.getElementById(a)
};
if (window.mv_render_ad) {
	var id = "mv_bg_wrap" + window.mv_bid;
	document.write("<div id='" + id + "'>");
	mv_render_ad();
	document.write("</div>");
	if (window.mv_bg_width) {
		setTimeout(function() {
			iclickIcon.setBgStyle(id)
		},
		100)
	}
	mv_render_ad = null
}
try {
	setTimeout(function() {
		var a = iclickIcon.G("mv_bg_wrap" + window.mv_bid);
		a.onclick = function(b) {
			b = b || event;
			iclickIcon.lisenClick(b, this)
		}
	},
	0)
} catch(e) {};