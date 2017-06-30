function multilayer (options) {
	var _this = this;
	_this.values=options['values'];
	_this.container=options['container'];
	_this.result=options['result'];
	_this.lang_opt = options["lang"] || "CN";
	_this.selectIds = options["selected"] || "";
	_this.callBack = options["callback"];
	_this.parent_layer = new Date().getTime();
	_this.child_layer=new Date().getTime()+999;
	_this.html="";
	_this.selectArr=[];
	_this.layer_init();
}
multilayer.prototype.layer_init = function() {
	var _this = this;
	_this.renderHtml();
	_this.selectIds && _this.setSelected();
};
multilayer.prototype.forTree = function(o){
	var _this = this;
	var lang = _this.lang_opt=="CN"?"":"_en";
	for(var i=0;i<o.length;i++){
		var url,str = "";
		var id=o[i]["audience_id"];

		try{
			if(typeof o[i]["url"] == "undefined"){
				urlstr = "<li><span id='"+id+"' title='"+ o[i]["name"+lang] +"'>&nbsp;"+ o[i]["name"+lang] +"</span><ul class='line'>";
			}else{
				urlstr = "<li><span id='"+id+"' title='"+ o[i]["name"+lang] +"'><a href="+ o[i]["url"] +">&nbsp;"+ o[i]["name"+lang] +"</a></span><ul>";	
			}
			_this.html += urlstr;
			if(o[i]["children"] != null && o[i]["children"].length>0){
				_this.forTree(o[i]["children"]);
			}
			_this.html += "</ul></li>";
		}catch(e){}
	}
	//console.log(_this.html);
	return _this.html;
}
multilayer.prototype.menuTree = function(){
	var _this = this;
	//给有子对象的元素加[+-]
	$(".tree ul",_this.container).each(function(index, element) {
		var ulContent = $(element).html();
		var spanContent = $(element).siblings("span").html();
        if(ulContent){
			$(element).siblings("span").html('<i  class="button switch center_close"></i>' + spanContent)	;
		}else{
			$(element).siblings("span").html(spanContent)	;
		}
    });
	
	$(".tree",_this.container).on("click","li span" , function(){
		var that = this;
		var ul = $(that).siblings("ul");
		var spanStr = $(that).html();
		//var spanContent = spanStr.substr(3,spanStr.length);
		if($(that).parents(".tree").attr("id")==_this.parent_layer && !$(that).hasClass("selected")){
		//	if(!$(that).hasClass("select")) $(".select",_this.container).removeClass("select");//单选
			if($(that).find("i").length>0) {//多选
				$(that).hasClass("select")?$(that).siblings().find("span:not('.selected')").removeClass("select"):$(that).siblings().find("span:not('.selected')").addClass("select");
				var parent_select = [];
				//找到所有父节点
				$(that).parent().parent().parents("li").each(function(){
					var ti=this;
					$(ti).find("span").first().each(function(){
						parent_select.push($(this).attr("id"));
					})
				});
				//遍历父节点找到对应子节点，如果有未选中的则对应父节点也是未选中
				for (var i = 0; i < parent_select.length; i++) {
					var $parentSelectDom=$(_this.container).find("#"+_this.parent_layer).find("#"+parent_select[i]);
					!$parentSelectDom.hasClass("selected") && $parentSelectDom.addClass("select");
					$parentSelectDom.next().find("span").each(function(){
						$(this).attr("id")!=$(that).attr("id") && !$(this).hasClass("selected") && !$(this).hasClass("select") && $parentSelectDom.removeClass("select");
					})
				};
			}else{
				if($(that).hasClass("select")){
					//只会往上影响，不会影响树形下面的
					$(that).parent().parent().parents("li").each(function(){
						var ti=this;
						$(ti).find("span").first().each(function(){
							$(this).attr("id")!=$(that).attr("id") && !$(this).hasClass("selected") && $(this).find("i").length>0 && $(this).removeClass("select");
						})
					});
				}else{
					var allSelect = true;
					var parent_select = [];
					//找到所有父节点
					$(that).parent().parent().parents("li").each(function(){
						var ti=this;
						$(ti).find("span").first().each(function(){
							//$(this).attr("id")!=$(that).attr("id") && !$(this).hasClass("selected") && $(this).find("i").length==0 && !$(this).hasClass("select") && (allSelect =false);
							parent_select.push($(this).attr("id"));
						})
					});
					if (allSelect) {
						//遍历父节点找到对应子节点，如果有未选中的则对应父节点也是未选中
						for (var i = 0; i < parent_select.length; i++) {
							var $parentSelectDom=$(_this.container).find("#"+_this.parent_layer).find("#"+parent_select[i]);
							!$parentSelectDom.hasClass("selected") && $parentSelectDom.addClass("select");
							$parentSelectDom.next().find("span").each(function(){
								$(this).attr("id")!=$(that).attr("id") && !$(this).hasClass("selected") && !$(this).hasClass("select") && $parentSelectDom.removeClass("select");
							})
						};
						/*
						$(that).parent().parent().parents("li").each(function(){
							var ti=this;
							$(ti).find("span").each(function(){
								$(this).attr("id")!=$(that).attr("id") && !$(this).hasClass("selected") && $(this).find("i").length>0  && $(this).addClass("select");
							})
						});
						*/
					};
				}
			}
			$(this).toggleClass("select");
		}
		//全选情况下再点击主菜单就取消全选且展开；未全选情况下点击主菜单变成全选且收缩
		if($(this).find("i").length>0 ){
			$(this).find("i").remove();
			if(ul.find("li").html() != null){
				if(ul.css("display") == "none" ){
					ul.show(300);
					$(this).prepend('<i  class="button switch center_open"></i>');
				}else{
					ul.hide(300);
					$(this).prepend('<i  class="button switch center_close"></i>');
				}
			}
		}
		
		
	})
	$(".button_layer",_this.container).on("click","a",function(){
		$(".select",_this.container).each(function(){
			_this.addChild($(this).attr("id"));
		});
		//回调
		_this.callBack && typeof(_this.callBack)==="function" && _this.callBack(_this.selectIds);
	});
	$(_this.container).on("click",".delete",function(){
		var that = this;
		var id = $(that).siblings("span").attr("id");
		var oldClass=[];
		$(_this.container).find("#"+_this.parent_layer).find("#"+id).removeClass("selected");
		$(_this.container).find("#"+_this.parent_layer).find("#"+id).siblings().find("span").removeClass("selected");
		//获取原始的样式
		$(_this.container).find("#"+_this.parent_layer).find("#"+id).parent().siblings().find("span").each(function(){
			oldClass.push($(this).attr("class"));
		})
		//更新所有span样式，通过id寻找所有带+/-的span
		$(_this.container).find("#"+_this.parent_layer).find("#"+id).parents("li").each(function(){
			var ti=this;
			$(ti).find("span").each(function(){
				if($(this).attr("id")!=$(that).parent())
					$(this).find("i").length>0 && $(this).removeClass("selected");
			})
		});
		//将不需要更新的同级li下的span还原成原来样式
		$(_this.container).find("#"+_this.parent_layer).find("#"+id).parent().siblings().find("span").each(function(i,o){
			$(o).attr("class",oldClass[i]);
		})
		$("#"+_this.child_layer).find("li").hide();
		$(_this.container).find("#"+_this.parent_layer).find(".selected").each(function(){
			_this.showChild($(this).attr("id"));
		})
		

		_this.sum();
		//回调
		_this.callBack && typeof(_this.callBack)==="function" && _this.callBack(_this.selectIds);
	});

}
multilayer.prototype.addChild = function(id){
	var _this = this;
	$(_this.container).find("#"+_this.parent_layer).find("#"+id).removeClass("select").addClass("selected");
	$(_this.container).find("#"+_this.parent_layer).find("#"+id).siblings().find("span").addClass("selected");


	_this.showChild(id);
	_this.sum();
}
multilayer.prototype.showChild = function(id){
	var _this = this;
	var length = 0;
	$(_this.container).find("#"+_this.child_layer).find("#"+id).parent().show();
	$(_this.container).find("#"+_this.child_layer).find("#"+id).siblings().find("li").show();
	$(_this.container).find("#"+_this.child_layer).find("#"+id).parent().parents("li").show();
	$(_this.container).find("#"+_this.parent_layer).find("#"+id).parent().parent().find("span:not(.selected)").each(function(){
		$(this).find("i").length==0 && length++;
	});
	if(length==0){
		$(_this.container).find("#"+_this.parent_layer).find("#"+id).parent().parent().prev().addClass("selected");
	}
}
multilayer.prototype.renderHtml = function(){
	var _this = this;
	var label_lang = _this.lang[_this.lang_opt]["pLabel"];
	var $parentHtml = $("<div class='parent_layer'><ul class='pannel'><span>"+label_lang[0]+"</span></ul><ul id='"+_this.parent_layer+"' class='tree'></ul></div>");
	var $childHtml = $("<div class='child_layer'><ul class='pannel'><span>"+label_lang[1]+"<b style='color:red'>0</b>"+label_lang[2]+"</span></ul><ul id='"+_this.child_layer+"' class='tree'></ul></div>");
	var $button = $('<div class="button_layer"><label ><a href="javascript:;">'+label_lang[3]+' > </a></label></div>');
	$('<div id="multi_layer" class="clearfloat"></div>').append($parentHtml).append($button).append($childHtml).appendTo(_this.container);
	var str= _this.forTree(_this.values);
	$("#"+_this.parent_layer,_this.container).append(str);
	$("#"+_this.child_layer,_this.container).append(str);
	$("#"+_this.child_layer,_this.container).find("li").hide();
	_this.menuTree();
	$("#"+_this.child_layer,_this.container).find("ul").show();
	$("#"+_this.child_layer,_this.container).find("li").append("<label class='delete'><img src='/images/shared/components/btn_del.png' /></label>");
	_this.curzt(_this.child_layer,"<i  class='button switch center_open'></i>");
	/*
	$('.tree',_this.container).hover(
    function(){
        $('body').css('overflow', 'hidden');
    },
    function(){
        $('body').css('overflow', 'auto');
    })
	*/
}
multilayer.prototype.curzt = function(id,v){
	var _this = this;
	$("#"+id,_this.container).find("span").each(function(index, element) {
		var ul = $(this).siblings("ul");
        var spanStr = $(this).html();
		//var spanContent = spanStr.substr(3,spanStr.length);
		$(this).find("i").remove();
		if(ul.find("li").html() != null){
			$(this).prepend(v);
		}
    });	
}
multilayer.prototype.sum = function(){
	var _this = this,lenspan=0,leni=0;
	_this.selectArr=[];
	var $span = $(_this.container).find("#"+_this.child_layer).find("span");
	$span.each(function(){
		if ($(_this.container).find("#"+_this.parent_layer).find("#"+$(this).attr("id")).hasClass("selected")) {
			lenspan++;
			if($(this).find("i").length>0){
				leni++;
			}else{
				_this.selectArr.push($(this).attr("id"));
			}
		};
	})
	_this.selectIds = _this.selectArr.join(",");
	$(_this.result).val(_this.selectIds);
	$(_this.container).find("b").text(lenspan-leni);
	
}
multilayer.prototype.setSelected = function(){
	var _this = this,l=_this.selectIds.length,selected = _this.selectIds,length=0;
	for (var i = 0,j = l; i < j; i++) {
		_this.addChild(selected[i]);
	};
	//父节点颜色变成不可选。子节点全部处理完后才能进行判断。
	for (var i = 0,j = l; i < j; i++) {
		$(_this.container).find("#"+_this.parent_layer).find("#"+selected[i]).parent().parent().find("span:not(.selected)").each(function(){
			$(this).find("i").length==0 && length++;
		});
		if(length==0){
			$(_this.container).find("#"+_this.parent_layer).find("#"+selected[i]).parent().parent().prev().addClass("selected");
		}
	};
	
	
	//回调
	_this.callBack && typeof(_this.callBack)==="function" && _this.callBack(_this.selectIds);
}
multilayer.prototype.lang = {
	'CN' : {
			pLabel : ["兴趣标签","已选择 ", " 个兴趣标签","添加"]
		},
	'EN' : {
		pLabel : ["Interests","You Have Selected ", " Interests","Add"]
		
	}
}