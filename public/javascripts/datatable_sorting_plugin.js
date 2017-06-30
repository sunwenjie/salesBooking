// for auto detect currency type
jQuery.fn.dataTableExt.aTypes.push(  
    function ( sData )  
    {  
        var sValidChars = "0123456789.+-,";  
        var Char;  
          
        /* Check the numeric part */  
        for ( i=1 ; i<sData.length ; i++ )   
        {   
            Char = sData.charAt(i);   
            if (sValidChars.indexOf(Char) == -1)   
            {  
                return null;  
            }  
        }  
          
        /* Check prefixed by currency */  
        if ( sData.charAt(0) == '$' || sData.charAt(0) == '£' )  
        {  
            return 'currency';  
        }  
        return null;  
    }  
);

jQuery.fn.dataTableExt.oSort['currency-asc'] = function(a,b) {
	
	a = a.substring(1);
	b = b.substring(1);
	
	var x = (a == "-" || a == "") ? 0 : a.replace( /,/g, "" );
	var y = (b == "-" || b == "") ? 0 : b.replace( /,/g, "" );
	
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	
	return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['currency-desc'] = function(a,b) {
	
	a = a.substring(1);
	b = b.substring(1);

	var x = (a == "-" || a == "") ? 0 : a.replace( /,/g, "" );
	var y = (b == "-" || b == "") ? 0 : b.replace( /,/g, "" );
	
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	
	return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oSort['percent-asc']  = function(a,b) {
	var x = (a == "-") ? 0 : a.replace( /%/, "" );
	var y = (b == "-") ? 0 : b.replace( /%/, "" );
	x = parseFloat( x );
	y = parseFloat( y );
	return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['percent-desc'] = function(a,b) {
	var x = (a == "-") ? 0 : a.replace( /%/, "" );
	var y = (b == "-") ? 0 : b.replace( /%/, "" );
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oSort['string-asc']  = function(a,b) {
	var x = a.replace( /<.*?>/g, "" ).toLowerCase();
	var y = b.replace( /<.*?>/g, "" ).toLowerCase();
	return ((x < y) ? -1 : ((x > y) ? 1 : 0));
};

jQuery.fn.dataTableExt.oSort['string-desc'] = function(a,b) {
	var x = a.replace( /<.*?>/g, "" ).toLowerCase();
	var y = b.replace( /<.*?>/g, "" ).toLowerCase();
	return ((x < y) ? 1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oSort['percent-with-sign-asc']  = function(a,b) {
	p = />(.*?)</;
	a = (a.match(p) == null) ? a : a.match(p)[1];
	b = (b.match(p) == null) ? b : b.match(p)[1];
	var x = (a == "-") ? 0 : a.replace( /%/, "" ).replace( /\+/, "" );
	var y = (b == "-") ? 0 : b.replace( /%/, "" ).replace( /\+/, "" );
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['percent-with-sign-desc'] = function(a,b) {
	p = />(.*?)</;
	a = (a.match(p) == null) ? a : a.match(p)[1];
	b = (b.match(p) == null) ? b : b.match(p)[1];
	var x = (a == "-") ? 0 : a.replace( /%/, "" ).replace( /\+/, "" );
	var y = (b == "-") ? 0 : b.replace( /%/, "" ).replace( /\+/, "" );
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oSort['currency-with-sign-html-asc']  = function(a,b) {
	p = />(.*?)</;
	a = (a.match(p) == null) ? a : a.match(p)[1];
	b = (b.match(p) == null) ? b : b.match(p)[1];
	a = a.replace( /\$/, "" );
	b = b.replace( /\$/, "" );
	var x = (a == "-" || a == "") ? 0 : a.replace( /,/g, "" );
	var y = (b == "-" || b == "") ? 0 : b.replace( /,/g, "" );
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['currency-with-sign-html-desc'] = function(a,b) {
	p = />(.*?)</;
	a = (a.match(p) == null) ? a : a.match(p)[1];
	b = (b.match(p) == null) ? b : b.match(p)[1];
	a = a.replace( /\$/, "" );
	b = b.replace( /\$/, "" );
	var x = (a == "-" || a == "") ? 0 : a.replace( /,/g, "" );
	var y = (b == "-" || b == "") ? 0 : b.replace( /,/g, "" );
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oSort['numeric-comma-asc']  = function(a,b) {
	var x = (a == "-") ? 0 : a.replace( /,/, "." );
	var y = (b == "-") ? 0 : b.replace( /,/, "." );
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['numeric-comma-desc'] = function(a,b) {
	var x = (a == "-") ? 0 : a.replace( /,/, "." );
	var y = (b == "-") ? 0 : b.replace( /,/, "." );
	x = isNaN(parseFloat(x)) ? 0 : parseFloat(x);
	y = isNaN(parseFloat(y)) ? 0 : parseFloat(y);
	return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oSort['formatted-num-asc'] = function(x,y){
 x = x.replace(/[^\d\-\.\/]/g,'');
 y = y.replace(/[^\d\-\.\/]/g,'');
 if(x.indexOf('/')>=0)x = eval(x);
 if(y.indexOf('/')>=0)y = eval(y);
 x = x == "-" ? 0 : x;
 y = y == "-" ? 0 : y;
 return x/1 - y/1;
}
jQuery.fn.dataTableExt.oSort['formatted-num-desc'] = function(x,y){
 x = x.replace(/[^\d\-\.\/]/g,'');
 y = y.replace(/[^\d\-\.\/]/g,'');
 if(x.indexOf('/')>=0)x = eval(x);
 if(y.indexOf('/')>=0)y = eval(y);
 x = x == "-" ? 0 : x;
 y = y == "-" ? 0 : y;
 return y/1 - x/1;
}

jQuery.fn.dataTableExt.oSort['file-size-asc'] = function(x,y){
 unit = 1024;
 x = x.toLowerCase();
 y = y.toLowerCase();
 a = parseFloat(x);
 b = parseFloat(y);
 x = x.indexOf("bytes")>=0 ? a : (x.indexOf("kb")>=0 ? a * unit : (x.indexOf("mb")>=0 ? a * unit * unit : (x.indexOf("gb")>=0 ? a * unit * unit * unit : a * unit * unit * unit * unit)));
 y = y.indexOf("bytes")>=0 ? b : (y.indexOf("kb")>=0 ? b * unit : (y.indexOf("mb")>=0 ? b * unit * unit : (y.indexOf("gb")>=0 ? b * unit * unit * unit : b * unit * unit * unit * unit)));
 return ((x < y) ?  -1 : ((x > y) ? 1 : 0));;
}

jQuery.fn.dataTableExt.oSort['file-size-desc'] = function(x,y){
 unit = 1024;
 x = x.toLowerCase();
 y = y.toLowerCase();
 a = parseFloat(x);
 b = parseFloat(y);
 x = x.indexOf("bytes")>=0 ? a : (x.indexOf("kb")>=0 ? a * unit : (x.indexOf("mb")>=0 ? a * unit * unit : (x.indexOf("gb")>=0 ? a * unit * unit * unit : a * unit * unit * unit * unit)));
 y = y.indexOf("bytes")>=0 ? b : (y.indexOf("kb")>=0 ? b * unit : (y.indexOf("mb")>=0 ? b * unit * unit : (y.indexOf("gb")>=0 ? b * unit * unit * unit : b * unit * unit * unit * unit)));
 return ((x < y) ?  1 : ((x > y) ? -1 : 0));;
}


jQuery.fn.dataTableExt.oSort['num-case-asc']  = function(x,y) {
  if(isNaN(parseFloat(x))){x = $(x).text()}
  if(isNaN(parseFloat(y))){y = $(y).text()}
    return jQuery.fn.dataTableExt.oSort['formatted-num-asc'](x,y);
};
 
jQuery.fn.dataTableExt.oSort['num-case-desc'] = function(x,y) {
  if(isNaN(parseFloat(x))){x = $(x).text()}
  if(isNaN(parseFloat(y))){y = $(y).text()}
    return jQuery.fn.dataTableExt.oSort['formatted-num-desc'](x,y);
};

jQuery.fn.dataTableExt.oSort['num-with-currency-asc']  = function(x,y) {
  x = x.replace(/[^\d|^\,|^\.]*/ig,"");
  y = y.replace(/[^\d|^\,|^\.]*/ig,"");
    return jQuery.fn.dataTableExt.oSort['formatted-num-asc'](x,y);
};
 
jQuery.fn.dataTableExt.oSort['num-with-currency-desc'] = function(x,y) {
  x = x.replace(/[^\d|^\,|^\.]*/ig,"");
  y = y.replace(/[^\d|^\,|^\.]*/ig,"");
    return jQuery.fn.dataTableExt.oSort['formatted-num-desc'](x,y);
};

$.fn.dataTableExt.afnSortData['dom-checkbox'] = function ( oSettings, iColumn )
{
    var aData = [];
    $( 'td:eq('+iColumn+') input', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
        aData.push( this.checked==true ? "1" : "0" );
    } );
    return aData;
};



// start for ad exchange group && sem dashboard total sorting   
// for string    
jQuery.fn.dataTableExt.oSort['adx-string-asc']  = function(a,b) {
	if(a.indexOf("ZZZZZZZZZZZZZZZZZZZZZ")>=0)
		{a = a.replace(/ZZZZZZZZZZZZZZZZZZZZZ/, "                     ")}
	else{if(a.indexOf("                     ")>=0)
		{a = a.replace(/                     /, "ZZZZZZZZZZZZZZZZZZZZZ")}};
	if(b.indexOf("ZZZZZZZZZZZZZZZZZZZZZ")>=0)
		{b = b.replace(/ZZZZZZZZZZZZZZZZZZZZZ/, "                     ");}
	else{if(b.indexOf("                     ")>=0)
		{b = b.replace(/                     /, "ZZZZZZZZZZZZZZZZZZZZZ")};}
		;
	// if(a.indexOf("                     ")>=0){aa = a.replace(/                     /, "ZZZZZZZZZZZZZZZZZZZZZ")};
	// if(b.indexOf("                     ")>=0){bb = b.replace(/                     /, "ZZZZZZZZZZZZZZZZZZZZZ")};
	var x = a.replace( /<.*?>/g, "" ).toLowerCase();
	var y = b.replace( /<.*?>/g, "" ).toLowerCase();
	return ((x < y) ? -1 : ((x > y) ? 1 : 0));
};

jQuery.fn.dataTableExt.oSort['adx-string-desc'] = function(a,b) {
	var x = a.replace( /<.*?>/g, "" ).toLowerCase();
	var y = b.replace( /<.*?>/g, "" ).toLowerCase();
	return ((x < y) ? 1 : ((x > y) ? -1 : 0));
};


jQuery.fn.dataTableExt.oSort['group-string-asc']  = function(a,b) {
	var sa = a.split("--");
	a = sa.pop();
	var stringa = sa.join("--");
	var sb = b.split("--");
	b = sb.pop();
	var stringb = sb.join("--");
	if(stringa.indexOf("ZZZZZZZZZZZZZZZZZZZZZ")>=0)
		{stringa = stringa.replace(/ZZZZZZZZZZZZZZZZZZZZZ/, "                     ")}
	else{if(a.indexOf("                     ")>=0)
		{stringa = stringa.replace(/                     /, "ZZZZZZZZZZZZZZZZZZZZZ")}};
	if(stringb.indexOf("ZZZZZZZZZZZZZZZZZZZZZ")>=0)
		{stringb = stringb.replace(/ZZZZZZZZZZZZZZZZZZZZZ/, "                     ");}
	else{if(stringb.indexOf("                     ")>=0)
		{stringb = stringb.replace(/                     /, "ZZZZZZZZZZZZZZZZZZZZZ")};}
		;
	result = jQuery.fn.dataTableExt.oSort['string-asc'](stringa,stringb);
	if(result == 0){
		return jQuery.fn.dataTableExt.oSort['string-asc'](a,b);
	}
	else{
		return 0;
	}
};

jQuery.fn.dataTableExt.oSort['group-string-desc'] = function(a,b) {
	var sa = a.split("--");
	a = sa.pop();
	var stringa = sa.join("--");
	var sb = b.split("--");
	b = sb.pop();
	var stringb = sb.join("--");
	result = jQuery.fn.dataTableExt.oSort['string-desc'](stringa,stringb);
	if(result == 0){
		return jQuery.fn.dataTableExt.oSort['string-desc'](a,b);
	}
	else{
		return 0;
	}
};

// for currency  only group
jQuery.fn.dataTableExt.oSort['group-currency-asc'] = function(a,b) {
	a = a.replace( /<.*?>/g, "" )
	b = b.replace( /<.*?>/g, "" );
	var sa = a.split("--");
	a = sa.pop();
	var stringa = sa.join("--");
	var sb = b.split("--");
	b = sb.pop();
	var stringb = sb.join("--");
	if(stringa.indexOf("ZZZZZZZZZZZZZZZZZZZZZ")>=0){stringa = stringa.replace(/ZZZZZZZZZZZZZZZZZZZZZ/, "");stringa = stringa.substr(0, stringa.length - 1);};
	if(stringb.indexOf("ZZZZZZZZZZZZZZZZZZZZZ")>=0){stringb = stringb.replace(/ZZZZZZZZZZZZZZZZZZZZZ/, "");stringb = stringb.substr(0, stringb.length - 1);};
	result = jQuery.fn.dataTableExt.oSort['string-asc'](stringa,stringb);
	if(result == 0){
		return jQuery.fn.dataTableExt.oSort['currency-asc'](a,b);
	}
	else{
		return 0;
	}
		
};

jQuery.fn.dataTableExt.oSort['group-currency-desc'] = function(a,b) {
	a = a.replace( /<.*?>/g, "" )
	b = b.replace( /<.*?>/g, "" );
	var sa = a.split("--");
	a = sa.pop();
	var stringa = sa.join("--");
	var sb = b.split("--");
	b = sb.pop();
	var stringb = sb.join("--");
	result = jQuery.fn.dataTableExt.oSort['string-desc'](stringa,stringb);
	if(result == 0){
		return jQuery.fn.dataTableExt.oSort['currency-desc'](a,b);
	}
	else{
		return 0;
	}
};

// for number
jQuery.fn.dataTableExt.oSort['group-formatted-num-asc'] = function(a,b) {
	a = a.replace( /<.*?>/g, "" )
	b = b.replace( /<.*?>/g, "" );
	var sa = a.split("--");
	a = sa.pop();
	var stringa = sa.join("--");
	var sb = b.split("--");
	b = sb.pop();
	var stringb = sb.join("--");
	if(stringa.indexOf("ZZZZZZZZZZZZZZZZZZZZZ")>=0)
		{stringa = stringa.replace(/ZZZZZZZZZZZZZZZZZZZZZ/, "");stringa = stringa.substr(0, stringa.length - 1);}
	else if(stringa.indexOf("                     ")>=0)
		{stringa = stringa.replace(/                     /, "ZZZ");};
	if(stringb.indexOf("ZZZZZZZZZZZZZZZZZZZZZ")>=0)
		{stringb = stringb.replace(/ZZZZZZZZZZZZZZZZZZZZZ/, "");stringb = stringb.substr(0, stringb.length - 1);}
	else if(stringb.indexOf("                     ")>=0)
		{stringb = stringb.replace(/                     /, "ZZZ");};
	result = jQuery.fn.dataTableExt.oSort['string-asc'](stringa,stringb);
	if(result == 0){
		return jQuery.fn.dataTableExt.oSort['formatted-num-asc'](a,b);
	}
	else{
		return 0;
	}
		
};

jQuery.fn.dataTableExt.oSort['group-formatted-num-desc'] = function(a,b) {
	a = a.replace( /<.*?>/g, "" )
	b = b.replace( /<.*?>/g, "" );
	var sa = a.split("--");
	a = sa.pop();
	var stringa = sa.join("--");
	var sb = b.split("--");
	b = sb.pop();
	var stringb = sb.join("--");
	result = jQuery.fn.dataTableExt.oSort['string-desc'](stringa,stringb);
	if(result == 0){
		return jQuery.fn.dataTableExt.oSort['formatted-num-desc'](a,b);
	}
	else{
		return 0;
	}
};

// for num-with-currency only sem dashboard
jQuery.fn.dataTableExt.oSort['group-num-with-currency-asc']  = function(a,b) {
  a = a.replace( /<.*?>/g, "" )
  b = b.replace( /<.*?>/g, "" );
  var sa = a.split("--");
  a = sa.pop();
  var stringa = sa.join("--");
  var sb = b.split("--");
  b = sb.pop();
  var stringb = sb.join("--");
  if(stringa.indexOf("                     ")>=0){stringa = stringa.replace(/                     /, "ZZZ");};
  if(stringb.indexOf("                     ")>=0){stringb = stringb.replace(/                     /, "ZZZ");};
  result = jQuery.fn.dataTableExt.oSort['string-asc'](stringa,stringb);
  if(result == 0)
  {
	x = a.replace(/[^\d|^\,|^\.]*/ig,"");
    y = b.replace(/[^\d|^\,|^\.]*/ig,"");
	return jQuery.fn.dataTableExt.oSort['formatted-num-asc'](x,y);
  }
  else{ return 0;};
};
 
jQuery.fn.dataTableExt.oSort['group-num-with-currency-desc'] = function(a,b) {
  a = a.replace( /<.*?>/g, "" )
  b = b.replace( /<.*?>/g, "" );
  var sa = a.split("--");
  a = sa.pop();
  var stringa = sa.join("--");
  var sb = b.split("--");
  b = sb.pop();
  var stringb = sb.join("--");
  result = jQuery.fn.dataTableExt.oSort['string-desc'](stringa,stringb);
  if(result == 0){
    x = a.replace(/[^\d|^\,|^\.]*/ig,"");
    y = b.replace(/[^\d|^\,|^\.]*/ig,"");
	return jQuery.fn.dataTableExt.oSort['formatted-num-desc'](a,b);
  }
  else{
	return 0;
  }
};

// for percent only semdashboard
jQuery.fn.dataTableExt.oSort['group-percent-asc']  = function(a,b) {
  a = a.replace( /<.*?>/g, "" )
  b = b.replace( /<.*?>/g, "" );
  var sa = a.split("--");
  a = sa.pop();
  var stringa = sa.join("--");
  var sb = b.split("--");
  b = sb.pop();
  var stringb = sb.join("--");
  if(stringa.indexOf("                     ")>=0){stringa = stringa.replace(/                     /, "ZZZ");};
  if(stringb.indexOf("                     ")>=0){stringb = stringb.replace(/                     /, "ZZZ");};
  result = jQuery.fn.dataTableExt.oSort['string-asc'](stringa,stringb);
  if(result == 0)
  {
	return jQuery.fn.dataTableExt.oSort['percent-asc'](a,b);
  }
  else{ return 0;};
};

jQuery.fn.dataTableExt.oSort['group-percent-desc'] = function(a,b) {
  a = a.replace( /<.*?>/g, "" )
  b = b.replace( /<.*?>/g, "" );
  var sa = a.split("--");
  a = sa.pop();
  var stringa = sa.join("--");
  var sb = b.split("--");
  b = sb.pop();
  var stringb = sb.join("--");
  result = jQuery.fn.dataTableExt.oSort['string-desc'](stringa,stringb);
  if(result == 0)
  {
	return jQuery.fn.dataTableExt.oSort['percent-desc'](a,b);
  }
  else{ return 0;};
};
