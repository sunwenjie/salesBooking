(function(){
	function opxEvalInnerHTML(url){
		// define variable .
		var DOMScripts    = document.getElementsByTagName("script");
		var scriptTotal   = DOMScripts.length ;
		var scriptElement = null;
		while(scriptTotal){
			scriptElement = DOMScripts[scriptTotal-1];
			if(null != scriptElement.getAttribute("src") && -1 != scriptElement.src.indexOf(url)){
				if(scriptElement.getAttribute("processed") != "processed"){
                    eval(scriptElement.innerHTML);
                    opxLoadAdsvanaJs(opxAdsPARAM);
                    scriptElement.setAttribute("processed", "processed");
				}
				else{
				}
			}
			scriptTotal--;
		}
	}

	function opxLoadAdsvanaJs(opxAdsPARAM){
        var opxHOST = (("https:" == document.location.protocol ) ? "https://adsvana.optimix.asia/bid_result?t=1" : "http://adsvana.optimix.asia/bid_result?t=1");
        var param = opxAdsPARAM.split(";");
        for (i = 0; i < param.length; i++) {
            if (param[i].indexOf("opxReferrer") < 0) {
                opxHOST = opxHOST + '&' + param[i];
            }
        }
        var img = document.createElement("img");
        var rnum = Math.random() * 1000000000000000;
        img.width = 1;
        img.height = 1;
        img.src = opxHOST + "&opxReferrer=" + encodeURIComponent(document.referrer) + "&rnum=" + rnum;
        var body = document.getElementsByTagName("body")[0];
        body.appendChild(img);
	}
	opxEvalInnerHTML("adsvana_tracking.js");

})();