var multiple_chosen = function(selector, select_button, onchange_function){
	// try{
		var item = $(selector).chosen().change(function(){
			// $(document).click();
			if (onchange_function != undefined && onchange_function != null ){
				onchange_function();
			}
		});
		$(select_button).live({
			mousedown:function(){
				item.next().trigger('mousedown');
				return false;
			},
			click:function(evt){
				 evt.stopPropagation();
				return false;
			}
		});
	// }catch(e){
	// 	if(typeof console === "object"){
	// 		console.log("missing parameter selector:"+selector +" select_button:"+select_button);
	// 	}
	// }
}

var messageClose = function(me, level,id,message_name,lang,display, action){
	var message = "";
	if (lang == "en"){
		message ="Remind me later?";
	}else{
		message ="以后再提醒?";
	}
	if(confirm(message)){
		if (me.parentNode){
    		me.parentNode.style.display= "none";

	    }else{
	    	me.parentElement.style.display = "none";
    	}
    	$.post("/"+lang+'/config/update_show_message_status',{"level":level,"id":id,"message_name":message_name,"display":display});
	}
	if(action && typeof action === 'function'){
		action();
	}
}