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
			value:0
		};
		var opts = $.extend(defaults, options);

		return this.each(function(){
			var obj = $(this);
			var val_obj = obj.find(".value");
			 if (val_obj.val() ==='') {val_obj.val(opts.value);}
			
			obj.find(".plus").click(function(event){
				if( isNumber(val_obj.val())){
					var value= parseFloat(val_obj.val());
					value += opts.step;
					if( value >= opts.min && value <= opts.max){
						obj.find(".value").val(value);
					}
				}
				return false;
			});
			obj.find(".minus").click(function(event){
				if( isNumber(val_obj.val())){
					var value= parseFloat(val_obj.val());
					value -= opts.step;
					if( value >= opts.min && value <= opts.max){
						obj.find(".value").val(value);
					}
				}
				return false;
			});
			obj.find(".value").blur(function(event){
				if( isNumber(val_obj.val())){
					var value= parseFloat(val_obj.val());
					if( value >= opts.min && value <= opts.max){
						$(this).removeClass('have_error');
					}else{
						$(this).focus();
						$(this).addClass('have_error');
					}
				}else{
					$(this).focus();
					$(this).addClass('have_error');
				}
				
			});
		});

	}
	
})(jQuery);

