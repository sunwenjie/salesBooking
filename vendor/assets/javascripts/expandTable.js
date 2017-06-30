var xmo = xmo||{};
(function(xm){
	var tools =xm.tools = {
		mul:function (v){
			return (v+"").replace(/\d+?(?=(?:\d{3})+$)/img, "$&,");
		},
		toNum:function (v){
			return parseInt(v.replace( /,/g,""));
		}
	};
	xm.expandTable = function(option){
		var self = this;
		self.settings = $.extend({

		},option||{});

		self.current="";
		self.selecteds=[];
		self.table = option.table;
		self.subtable = option.subtable;
		self.addBtn =option.addBtn;
		self.api = window.mediaSelected.api(); //new
		self.firApi =window.medialist.api();//new
		//self.table.on("focus",".pv_value",function(e){
		//	//self.focused.call(this,self);
		//}).on("blur",".pv_value",function(e) {
		//	self.blured.call(this,self);
		//}).on("keyup",".pv_value",function(e){
		//	self.keyuped.call(this,self);
		//});
		////add pv
		//self.addBtn.on("click",function(){
		//	self.addTr.call(this,self);
		//});
		////delete
		//self.subtable.on("click","i",function(){
		//	self.removeItem.call(this,self);
		//});
		////show group
		//self.table.on("click",".area_all",function(e){
		//	self.showGroup.call(this);
		//});

	};
	xm.expandTable.prototype={
		init:function(){ // new
			 var self = this;
			 var tr = self.api.rows().nodes(),isem=self.subtable.find(".dataTables_empty");
			 self.firApi =window.medialist.api();//new
			 if(tr.length>0 && isem.length ==0){
			 	for(var i=0;i<tr.length;i++){
			 		var td = $(tr).eq(i).find("td");
			 		self.current = $(self.firApi.rows().nodes()).find("#"+td.eq(td.length-1).find("i").attr("alt")).data("isbuy",true);
			 		self.setMax(td.eq(td.length-3).text());
			 	}
			 }
		},

		showGroup:function(){
			var self = this;
			var temp = $(self).attr("data-target");
			if(!$(temp).data("isshow")){
				$(self).find(".icon-arrow-right").addClass('icon-arrow-down');
				$(temp).data("isshow",true).show();
			}else{
				$(self).find(".icon-arrow-right").removeClass('icon-arrow-down');
				$(temp).data("isshow",false).hide();
			}
		},
		//返回当前td值和最大值
		getcv:function(tr){ //new
			var self = this;
			var td = self.getTd(),temp,max,cur;
			if(td.length>0){
				//temp = td.eq(td.length-1).find("input"),
				temp = td.eq(td.length-2).find("input"),
				max = parseInt(tools.toNum(temp.attr("max"))),
				cur = parseInt(tools.toNum(temp.val()));
			}
			return {max:max,cur:cur};
		},
		//获取当前行所有td
		getTd:function(obj){
			var self = this;
			obj = obj ||self.current;
			td = $(obj).parent().parent().find("td");
			return td;
		},
		//获取地域dom
		getTdom:function(){
			var self = this;
			var temp ,tdom;
			temp = $(self.current).attr("id");
			tdom = $("input[alt ="+temp+"]");
			return tdom;
		},
		getTemp :function(){
			var self = this,temp,tdom;
			temp = $(self.current).attr("alt");
			if(temp){
				tdom = $("input[alt = "+temp+"]");
			}
			return {temp:temp,tdom:tdom};
		},
		getBuyCount:function(){ //new
			var self = this,v = 0, tr = self.api.rows().nodes();
			var items=[];
			for(var i=0;i<tr.length;i++){
				var item ={},td = $(tr).eq(i).find("td"),input = td.eq(td.length-1);
				item.id = input.find("div").attr("alt");
				item.value = tools.toNum(input.find("div").text());
				v += item.value;
				items.push(item);
			}
			return {items:items,total:v};
		},
		//是否可以填写
		firShow:function(isShow){
			var self= this,temp = self.getTemp();
			if($("#"+temp.temp).length>0){
				$("#"+temp.temp)[0].disabled = isShow;
			}
		},
		subShow:function(isShow){
			var self = this,tdom=self.getTdom();
			for (var i = 0; i < tdom.length; i++) {
				tdom[i].disabled = isShow;
			}
		},
		subCount:function(tdom){
			var tval = 0;
			for (var i = 0; i < tdom.length; i++) {
				tval += parseInt($(tdom[i]).val()||0);
			}
			return tval;
		},
		setPv:function(index,v){
			var self = this;
			self.getTd().eq(index).text(tools.mul(v));
		},

		setTotal:function(){
			var self = this;
			self.subtable.find("#buyTotal").html(tools.mul(self.getBuyCount().total));
		},
		setSelected:function(v,isadd) {
			var self = this,index = $.inArray(v,self.selecteds);
			//alert("v:"+ v);
			//alert("setSelected_index:"+index);
			if(index == -1){
				self.selecteds.push(v);
			}
			if(!isadd){
				self.selecteds.splice(index,1);
			}
		},
		difvalue:function  (isDif,v) {
			var self = this;
			var td = self.getTd(),cv = self.getcv(),v,
			//max = cv.max,b= v||cv.cur;
			//max = cv.max,b= v||cv.cur;
			 max = 10000,b= v||cv.cur;


			if(isDif){
				v = max-b;
			}else{
				v = max+b;
			}
			if(v>=0){
				self.setPv(td.length-3,v);
				self.setSelected(self.current,true);
			}else{

				self.setSelected(self.current,false);
			}

		},
		setMax:function(v){
			var self = this;
			if(v){
				$(self.current).attr("max",tools.toNum(v));
				var t = $(self.current).parent().parent().find("td");
				//alert("t.eq(t.length-2)[0]:"+t.eq(t.length-2)[0]);
				if(t.eq(t.length-2)[0])t.eq(t.length-2).text(tools.mul(v));
			}else{
				var td = self.getTd();
				var	last = $(self.current).attr("max",tools.toNum(td.eq(td.length-2).text()));
			}
		},
		popfn:function(){
			$('.icon-remove').popover({
				placement: 'right',
				trigger: 'hover'
			});
		},
		getId:function(id){ //new
			return id.split("_")[id.split("_").length-1];
		},
		creatItem:function (){ //new
			var self = this;
			var item=[],td=self.getTd(),ct;
			for(var i=1;i<td.length;i++){
				if(i<td.length-2){
					if(i==1){
						ct = td.eq(i).text();
					}
					item.push('<td class="align_left">'+td.eq(i).text()+'</td>');
				}else{
					var input = td.eq(i).find("input");
					//item.push('<td class="align_left"><div style="float:left;"> '+tools.mul(input.val())+' </div> <input type="hidden" name="booking_pvs[]" value="'+ct.replace(/[\r\n]/g,"").replace(/(^\s*)|(\s*$)/g, "")+','+self.getId(input.attr("id"))+','+input.val()+'"/></td>');
					item.push('<td class="align_left"><div style="float:left;"> '+tools.mul(input.val())+' </div>')
					input.val("");
				}
			}
			self.api.row.add(item).draw();
		},
		medify:function(){//new
			var self = this,td = self.getTd(),
			subtd = self.subtable.find("tbody tr").find('i[alt='+$(self.current).attr("id")+']').parent().parent().parent().find("td"),
			  	fir = td.length-2,sub = td.length-1;

			 subtd.eq(fir).text(td.eq(fir).text());
			 var o = subtd.eq(sub).find("div").eq(0),
			 	oinput = subtd.eq(sub).find("input"),
			 	ov = tools.toNum(o[0].innerText),
			 	ev = tools.toNum(td.eq(sub).find("input").val());
		 	o.text(tools.mul(ov+ev));
		 	//修改的时候会修改input hidden 里的值
		 	var iv = oinput.val().split(",");
		 	iv[2] = tools.mul(ov+ev);
		 	oinput.val(iv.join(","));
		 	//end
			td.eq(sub).find("input").val("");

		},
		removeItem:function(obj){ //new
			if($(this).attr("class") == "icon-remove"){
				//回滚计算
				var v = parseInt(tools.toNum(($(this).parent().parent()).text()));
				obj.current = $("#"+$(this).attr("alt"));
				obj.difvalue(false,v);
				obj.setMax();
				//删除购买
				$(this).trigger("mouseout");
				var tr = $(this).parents('tr');
    			obj.api.row(tr).remove().draw();
				obj.current.data("isbuy",false);
				obj.setSelected(obj.current,false);
				obj.setTotal();
				if(!obj.getIsBuy()){
					var temp =obj.getTemp();
					if(temp.temp){
						obj.firShow(false);
					}else{
						obj.subShow(false);
					}
				}
				//添加隐藏域 value
				var dl = $(this).attr("data-delete"),dv;
				if(dl){
					dv = $("#delete_pvs");
					dv.val(dv.val()?dv.val()+","+dl:dl);
				}
			}
		},
		addTr:function(obj){ //new
			var tdom = obj.selecteds,indexs="",n=0;
			for(var i=0;i<tdom.length;i++){
				var isbuy = $(tdom[i]).data("isbuy");
				isbuy = false;
				//alert("isbuy:"+isbuy);
				obj.current = tdom[i];
				obj.setMax();
				if(isbuy){
					alert("medify");
					//修改已购买的
					obj.medify();
				}else{
					//alert("createItem");
					$(tdom[i]).data("isbuy",true);
					obj.creatItem(n);
					n+=1;
				}
			}
			obj.popfn();
			obj.setTotal();
			obj.selecteds = [];
		},
		deepBuy:function(temp){
			var isbdom = $("input[alt="+temp+"]");
			for(var i=0;i<isbdom.length;i++){
				if(isbdom.eq(i).data("isbuy")){
					$("#"+temp)[0].disabled = true;
					return true;
				}
			}
			return false;
		},
		getIsBuy:function(){
			var self = this,temp = self.getTemp(),isbdom;
			if(temp.temp){
				return self.deepBuy(temp.temp);
			}else{
				isbdom = self.deepBuy($(self.current).attr("id"));
				if(!isbdom){
					isbdom = $(self.current).data("isbuy");
				}
				return isbdom;
			}
		},
		focused:function(obj){
			obj.current = this;
			var temp = $(this).attr("alt"),tdom,
				isbuy = obj.getIsBuy();
			if(!isbuy){
				if(temp){
					obj.firShow(true);
				}else{
					obj.subShow(true);
				}
			}
		},
		blured:function(obj){
			obj.current = this;
			//判断是否显示输入框
			var temp = obj.getTemp(),tval=0,tdom;
			var isbuy = obj.getIsBuy();
			if(!isbuy){
				if(temp.temp){
					tval = obj.subCount(temp.tdom);
					if(tval==0){
						//obj.firShow(false);
					}
				}else{
					tval = parseInt($(this).val()||0);
					if(tval == 0){
						obj.subShow(false);
					}
				}
			}
			//计算剩余pv
			obj.difvalue(true);
		},
		keyuped:function(obj){
			obj.current = this;
			var  cv = obj.getcv(),v=cv.cur,max = cv.max;
			$(this).attr({
					"data-toggle":"popover" ,
					"data-trigger":"manual",
					"data-placement":"right",
					"data-content":"超过最大值"
			});
			if(max<v || !max){
				$(this).addClass("have_error").popover('show');
				$("#addPv")[0].disabled = true;
			}else{
				$(this).removeClass("have_error").popover('hide');
				$("#addPv")[0].disabled = false;
			}
		}
	};
})(xmo);