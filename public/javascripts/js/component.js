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

var  selectable_with_all = function(ele_id, all_val){
  var option_all_selected = true;
  $(ele_id).change(function(){
    var is_all = false;
    $(ele_id + " option:selected").each(function(i , l){
        if($(l).val() == all_val) is_all = true;
    });

    if($(ele_id + " option:selected").length == 1){
        $(ele_id).trigger("liszt:updated");
        option_all_selected = is_all;
        return false;
    }

    if(option_all_selected && is_all){
      $(ele_id +" option[value=" + all_val + "]").removeAttr('selected');
        option_all_selected = false;
      }else if(!option_all_selected && is_all){
          $(ele_id + " option:selected").each(function(i, l) {
              if ($(l).val() != all_val) { $(l).removeAttr('selected'); }
          });
          option_all_selected = true;
      }
      $(ele_id).trigger("liszt:updated");
      //$(ele_id).valid();
  });
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