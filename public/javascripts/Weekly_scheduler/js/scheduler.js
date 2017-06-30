var data_size = 7*24;/* 7 days x 24 hrs*/
var click = false; 
var cn_day = ["周日","周一","周二", "周三","周四","周五","周六"];
var eng_day = ["SUN","MON","TUE", "WED","THU","FRI","SAT"];
var cn_time =["上午十二","下午十二","上午十二"];
var eng_time =["12 am","12 pm","12 am"];
var cn_all = "全选";
var eng_all = "All time";


var scheduler_init = function( values, lang ){
	
	var default_time;
	var default_day;
	if(lang === "cn"){
		default_time = cn_time;
		default_day = cn_day;
		$('.cal_all_time_txt').html(cn_all);		
	}else{
		default_time = eng_time;
		default_day = eng_day;
		$('.cal_all_time_txt').html(eng_all);
	}
	var i = 0;
	$('.header_time').each(function(){
		$(this).html(default_time[i++]);
	});
	
	i = 0;
	$('.day_name').each(function(){
		$(this).html(default_day[i++]);
	});
	
	var len = values.length;
	if(len < data_size){
		for(var i = len; i < data_size; i++){
			values += "0";
		}
	}
	var data2 = "0";
	var select_value = "";
	var tmp_row = 0;
	var tmp_col = 0;
	for (var row = 0; row < 7; row++) {
	     for (var col = 0; col < 24; col++) {
		 	select_value = values.substr(row * 24 + col , 1  );
            if(select_value === "1"){
				tmp_row = row + 3;
				tmp_col = col + 1;
				if(tmp_row % 2 == 0)
					$($("#calendar_body").children().children()[tmp_row].children[tmp_col]).addClass("chosen_odd");
				else
					$($("#calendar_body").children().children()[tmp_row].children[tmp_col]).addClass("chosen_even");
		    }
	    }
	}

	$('#scheduler_data').val(values);
	$("#calendar_body").disableTextSelect();
	$("#calendar_body").on("mousedown", ".select_box", function() {
		update_selected(this);

	  click = true;
	});

	$("#calendar_body").on("mouseenter", ".select_box", function() {
	  if (click ){
		update_selected(this);
	  }

	});

	$("#calendar_body").on("mouseup", ".select_box", function() {
	  click = false;
	});

	$("#calendar_body").on("mouseleave", "", function() {
		click = false;
	});
	$('#cal_all_time').on("click", function(){
		select_all_toggle($(this).is(':checked'));
		// add this code for jquery validate plugin
		// please do not delete this
		// thank u by orichi
		if ($(this).attr('checked') == 'checked'){
			$('#scheduler_data').trigger('blur');
		}
	});
}


var update_selected = function( item ){
	var is_selected = false;
	if (($(item).parent().parent().children().index(item.parentNode)-3)%2 == 0){
     	    $(item).toggleClass("chosen_even");
	}else{
	    $(item).toggleClass("chosen_odd");
	}
	is_selected = $(item).hasClass("chosen_even");
	if (!is_selected){
	    is_selected = $(item).hasClass("chosen_odd");
	}
	var column = $(item).parent().children().index(item)-1;
	var row = $(item).parent().parent().children().index(item.parentNode)-3;
	var current_value = $('#scheduler_data').val(); 
	var data1 = current_value.substr(0,row * 24 + column );
	var data2 = current_value.substr(row * 24 + column +1, data_size -(row * 24 + column +1)  );
	current_value = "" ;
	current_value += data1;
	current_value += is_selected?"1":"0";
	current_value += data2;
	$('#scheduler_data').val(current_value);
	$('#cal_all_time').attr("checked",null);
}

var select_all_toggle =function(is_all){
	var value ="";
	for (var row = 0; row < 7; row++) {
	     for (var col = 0; col < 24; col++) {
				tmp_row = row + 3;
				tmp_col = col + 1;
				if (is_all){
					value += "1";
					if(tmp_row % 2 == 0)
						$($("#calendar_body").children().children()[tmp_row].children[tmp_col]).addClass("chosen_odd");
					else
						$($("#calendar_body").children().children()[tmp_row].children[tmp_col]).addClass("chosen_even");
				}else{
					value += "0";
					if(tmp_row % 2 == 0)
						$($("#calendar_body").children().children()[tmp_row].children[tmp_col]).removeClass("chosen_odd");
					else
						$($("#calendar_body").children().children()[tmp_row].children[tmp_col]).removeClass("chosen_even");
				}
				
	    }
	}
	$('#scheduler_data').val(value);
}


