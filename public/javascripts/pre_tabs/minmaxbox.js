/*
Add few feature for this.
overMax: when value over max value
underMin: when value is under min value
invalidText: when value is not number

Setup it in options value
*/

function isNumber(n) {
  	var RE = /^-{0,1}\d*\.{0,1}\d+$/;
	    return (RE.test(n));
}
(function($){
	
	$.fn.minmaxbox = function( options ){
		var defaults ={
			min:0,
			max:100,
			step:1,
			value:0,
			error_class: 'have_error',
			overMax:  function ( event, current_val, max_val,value_box ){
					value_box.value = max_val;
			},	

		 	underMin: function ( event,current_val, min_val,value_box ){
		 		value_box.value = min_val;
			},
			invalidText: function(event,current_val,value_box){
				value_box.value = opts.min;
			}
		};
		var opts = $.extend(defaults, options);



		return this.each(function(){
			$(this).bind('minmaxbox.overMax',opts.overMax);
			$(this).bind('minmaxbox.underMin',opts.underMin);
			$(this).bind('minmaxbox.invalidText',opts.invalidText);
			var obj = $(this);
			var val_obj = obj.find(".value")[0];
			if (val_obj.value ==='') {val_obj.value = opts.value;}
			

			obj.find(".minus").bind('click',function(event){
				if( isNumber(val_obj.value)){
					var value= parseFloat(val_obj.value);
					value -= opts.step;
					if( value >= opts.min && value <= opts.max){
						val_obj.value = value 
					}
				}
				return false;
			});

			obj.find(".plus").bind('click',function(event){
				if( isNumber(val_obj.value)){
					var value= parseFloat(val_obj.value);
					value += opts.step;
					if( value >= opts.min && value <= opts.max){
						val_obj.value = value ;
					}
				}
				return false;
			});

			obj.find(".value").blur(function(event){
				if( isNumber(val_obj.value)){
					var value= parseFloat(val_obj.value);
					if( value >= opts.min && value <= opts.max){
						$(this).removeClass(opts.error_class);
					}else if( value < opts.min){
						$(this).focus();
						$(this).addClass(opts.error_class);
						$(this).trigger('minmaxbox.underMin',[val_obj.value,opts.min,val_obj]);
					}else if( value > opts.max){
						$(this).focus();
						$(this).addClass(opts.error_class);
						$(this).trigger('minmaxbox.overMax',[val_obj.value,opts.max,val_obj]);
					}
				}else{
					$(this).focus();
					$(this).addClass(opts.error_class);
					$(this).trigger('minmaxbox.invalidText',[val_obj.value,val_obj]);
				}
				
			}).keypress(function(event){
				var code = event.keyCode ? event.keyCode : event.which ;
				if(code == 13)
					return false;
			});
		});

	}
	
})(jQuery);

