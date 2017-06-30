//===============================================
//    # MODULE : CREATE NAMESPACE FUNCTION
//===============================================
var XMO = window.XMO || {};

/**
 * @ description - create namespace for XMO top level object.
 * @ param  {String} nameSpace - name space contact with '.'
 */

XMO.createNameSpace = function(nameSpace){

	if(!nameSpace || !nameSpace.length){
		return null;
	}
	var names = nameSpace.split(".");
	var nameObj = XMO;
	for(var nameIndex = (names[0] == "XMO") ? 1 : 0 ; nameIndex < names.length ; nameIndex++){
		nameObj[names[nameIndex]] = nameObj[names[nameIndex]] || {};
		nameObj = nameObj[names[nameIndex]];
	}
	return nameObj;
}; 

XMO.createNameSpace("XMO.LANG");

//===============================================
//    # MODULE : LANGUAGE CONFIGURATION
//===============================================
jQuery.extend(XMO.LANG,{
	AJAX_CONSOLE : {
		ZH : {
			T_301     : '',
			T_302     : '',
			T_404     : '资源未找到',
			T_500     : '内部服务器错误',
			T_200     : '加载完成',
			LOADING   : '正在加载 ... '
		},
		EN : {
			T_301     : '',
			T_302     : '',
			T_404     : 'Source Not Found',
			T_500     : 'Internal Server Error',
			T_200     : 'Success Loaded',
			LOADING   : 'loading ... '
		}
	}
});

//==========================================
//    # MODULE : AJAX GLOBAL CONSOLE
//==========================================
jQuery(function(){
	
	// create XMO.AJAX namespace.
	XMO.AJAX = XMO.createNameSpace("XMO.AJAX");
	
	// scope variables.
	var _$console = null , _$info = null;
	
	// ajax set up configuration.
	var _conf = {
		duration  : 500,
		text  : {
			loading : XMO.LANG.AJAX_CONSOLE.ZH.LOADING,
			t_404   : XMO.LANG.AJAX_CONSOLE.ZH.T_404,
			t_500   : XMO.LANG.AJAX_CONSOLE.ZH.T_500
		},
		className : {
			c_console  : 'ajax-console',
			c_info     : 'ajax-console-content',
			c_404    : 'ajax-console-code-404',
			c_500    : 'ajax-console-code-500',
			c_301    : 'ajax-console-code-301',
			c_302    : 'ajax-console-code-302'
		}
	}
	
	// extend XMO.AJAX.
	jQuery.extend(XMO.AJAX,{
		
		_getConsole : function(){
			if(_$console == null){
				
				_$console = $("<div/>",{css:{display:"none"}}).addClass(_conf.className.c_console);
				_$info = $("<div/>",{text : ""}).addClass(_conf.className.c_info);
				
				_$console.append(_$info);
				$("body").append(_$console);
			}
			return _$console;
		},
		
		_removeConsole : function(){
			if(_$console.css("display") != 'none'){
				_$console.fadeOut(_conf.duration,function(){
					_$info.removeClass().addClass(_conf.className.c_info);
				})
			}
		},
		
		_addInfo : function(info){
			
			this._getConsole();
			_$info.empty().text(info);
			
			if(_$console.css("display") == "none"){
				_$console.fadeIn(_conf.duration);
			}
		},
		
		onStart : function(){
			var _ctx = this;
			$("body").ajaxStart(function(){
				_ctx._addInfo(_conf.text.loading);
			});
		},
		
		onComplete  : function(){
			var _ctx = this;
			
			$("body").ajaxComplete(function(){
				_ctx._removeConsole();
			});
		},
		
		onStop : function(){
			
			var _ctx = this;
			
			$("body").ajaxStop(function(){
				_ctx._removeConsole();
			});
		},
		
		config  : function(){
			var _ctx = this;
			$.ajaxSetup({
				statusCode : {
					 404 : function(xhr){  // server problem.
						_ctx._addInfo(_conf.text.t_404);
						_$info.addClass(_conf.className.c_404);
						
					 },
					 500 : function(xhr){
						_ctx._addInfo(_conf.text.t_500);
						_$info.addClass(_conf.className.c_500);
					 },
					 301 : function(xhr){
					 	// redirect.
					 	var lang = window.location.pathname.split('/')[1];
					 	var back_url = unescape(window.location.href);
					 	var _url = window.location.protocol+'//'+window.location.host+'/'+lang+'/admin/login?back_url='+back_url;
					 	window.location.href = _url;
					 },
					 302 : function(xhr){
					 	// redirect.
					 }
				}
			});
		}
	});
	
	// XMO on Ajax start event 
	XMO.AJAX.config();

	XMO.AJAX.onStart();
	
	//XMO.AJAX.onComplete();
	
	XMO.AJAX.onStop();
	
});