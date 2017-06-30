/*
 * 初始化 入口方法
 *  
 */ 
var pageExample = {
	/*
	 * 初始化 入口方法
	 *  
	 */ 
	init : function(dataObj){
		this.init_ajax();
		this.init_html();
		this.init_event_bind();
	},
	/*
	 * 事件绑定
	 *  
	 */ 
	init_event_bind : function(){
		var _this = this;
		$(document).on('click','id class dom ...',function(e){
			_this.event1($(this),e);
		})
	},
	/*
	 * 需要通过ajax初始化的数据
	 *  
	 */ 
	init_ajax : function(){
		
	},
	/*
	 * 需要动态初始化的DOM
	 *  
	 */ 
	init_html : function(){
		
	},
	event1 : function($this,e){
		var _this = this;
	}
}
/*
 * 初始化 入口方法
 *  
 */ 
$(function(){
	In.use('');
	pageExample.init(data);
})