function RGB2Color(r,g,b)
{
  return '#' + byte2Hex(r) + byte2Hex(g) + byte2Hex(b);
}
function byte2Hex (n)
{
  var nybHexString = "0123456789ABCDEF";
  return String(nybHexString.substr((n >> 4) & 0x0F,1)) + nybHexString.substr(n & 0x0F,1);
}

var colorSpliter = function(r,g,b, diffVal, noOfSpliter,isHex){
    isHex = typeof isHex !== 'undefined' ? isHex : false;
    diffVal = typeof diffVal !== 'undefined' ? diffVal : 200 ;
    noOfSpliter = typeof noOfSpliter !== 'undefined' ? noOfSpliter : 100 ;
    var result = new Array(noOfSpliter);
    var eachOne = Math.round(diffVal/noOfSpliter);
    for (var i=0;i<= noOfSpliter;i++){
	
		var rgb = [r,g,b];
        
        if( isHex ){
             result[i]= RGB2Color(r,g,b);       
        }else{
            result[i]= rgb;
        }
        r+=eachOne;
        g+=eachOne;
        b+=eachOne;
        r=r>255 ? 255:r;
        g=g>255 ? 255:g;
        b=b>255 ? 255:b;
        
    }
    return result;
};