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
					opxLoadTanxJs();
					scriptElement.setAttribute("processed", "processed");
				}
				else{
				}
			}
			scriptTotal--;
		}
	}
	function opxLoadTanxJs(){
         var script = document.createElement("script");
         script.src = (("https:" == document.location.protocol) ? "https:" : "http:") + "//cdn.tanx.com/t/tanxclick.js";
         script.type = "text/javascript";
         document.getElementsByTagName("head")[0].appendChild(script);
         var body = document.getElementsByTagName("body")[0];
         body.appendChild(script);
	}
	opxEvalInnerHTML("render_tanx_click.js");

})();