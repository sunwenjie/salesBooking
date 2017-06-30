   //for nav
$(function() {
 $('.load-box').each(function(index,ele){
 	var src = $(ele).attr('data-src');
 	$(ele).load(src,DOC.loadCallback);
 	// $.ajax({
 	// 	url : '/'+src,
 	// 	success : function(data){
 	// 	console.info(data)
 	// 		$(ele).html(data);
 	// 		DOC.loadCallback();
 	// 	}
 	// })
 });
 DOC.loadCallback.itemLength = $('.load-box').length;

 // window.prettyPrint && prettyPrint();
 // $(".chzn-select").chosen();

})

DOC = {}
DOC.init = function(){
 	// make code pretty
	DOC.pretty();
    $('#page_header li').on("activate",function(){
        var id = $(this).children('a').attr('href');
        DOC.init.subId  = id;
        var subNavItems = $(id).find('.subNavItem');
        var box = $('#affix-sidebar ul').html('');
        if(subNavItems.length > 1){
        	subNavItems.each(function(index,element){
        		var id = DOC.init.subId  + '_'+index;
        		var html = $(element).text();
        		$(element).attr('id',id.split('#')[1]);
        		box.append('<li><a href="'+id+'">' + html + '</a></li>');
        	})
        	$('#affix-sidebar').fadeIn(400);
    		$('[data-spy="scroll"]').each(function () {
		    	var $spy = $(this).scrollspy('refresh')
		    });
        }else{
        	$('#affix-sidebar').hide()
        }
    });

	$('body').scrollspy();
	$('[data-spy="scroll"]').each(function () {
    	var $spy = $(this).scrollspy('refresh')
    });
    $(window).scroll(function(e){
    	var index = $('#page_header li').index($('#page_header li.active'));
    	if(DOC.init.index != index){
    		$('#page_header li.active').first().trigger('activate');
			DOC.init.index = index;
    	}
    })
	$('#page_header li.active').first().trigger('activate');
	// $('#affix-sidebar').hover(function(){
	// 	$(this).stop(true,true).fadeTo(400,1);
	// },function(){
	// 	$(this).stop(true,true).fadeTo(400,0.6);
	// })
    // 
}
DOC.init.index = 0;
DOC.init.subId = 'current';
DOC.header = function(){

}
DOC.pretty = function(){
 $('pre').each(function(index,element){
    var html = $(element).html();
    $(element).html(html.replace(/</g,'&lt;').replace(/>/g,'&gt;'));
 });
 window.prettyPrint && prettyPrint();

}
DOC.loadCallback = function(){
	DOC.loadCallback.count++;
	if(DOC.loadCallback.count == DOC.loadCallback.itemLength){
		DOC.init();
	}
}
DOC.loadCallback.count = 0;