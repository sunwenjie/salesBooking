$(function() {
	var tTip =  
	    "<div class='tip'>" +  
	        "<div class='tipMid'>"    +  
	        "</div>" +  
	        "<div class='tipBtm'></div>" +  
	    "</div>";
	var $slideMe = $(tTip)
                    .css({ position : 'absolute' , top : -43, left : -14,'text-align':'center',color:"white"})
                   	.hide();


	$( "#slider-range-min" ).slider({
		range: "min",
		value: 1,
		min: 1,
		max: 7,
		slide: function( event, ui ) {
			$( ".slider_result" ).val( ui.value );
			$(this).find('.tipMid').text(ui.value);
		}
	}).find(".ui-slider-handle")
		                .append($slideMe)
		                .hover(function()
		                        { $slideMe.show()}, 
		                       function()
		                        { $slideMe.hide();$(this).blur();}
		                );
	$( ".slider_result" ).val( $( "#slider-range-min" ).slider( "value" ) );
	$( "#slider-range-min" ).find('.tipMid').text($( "#slider-range-min" ).slider( "value" ));
	$(".slider_result").on("change",function(event){
		$( "#slider-range-min" ).slider( "option", "value", $( ".slider_result" ).val() );
	});
});