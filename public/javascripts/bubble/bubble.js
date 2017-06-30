var dataBubble = [];
var dataOrigin = [];
var dataCenter = [];
var paperBubble,circleDataCenter;
var initOver;
var isOver = false;
var tipBoxWidth = 120;
var isOverFuncAry = [];
var StageWidth = 500;
var StageHeight = 500;
var radioCenter = StageWidth/8;
var maxRadio = StageWidth/8;
var minRadio = StageWidth/13;
var minVal = 0;
var maxVal = 0;
var centerX = StageWidth/2;
var centerY = StageHeight/2;
var xmoCircles = [];
var currentLabel = '';
var bubbleOpacityShow = 0.9;
var bubbleOpacityHide = 0.5;
var bubbleOpacityNone = 0.02;

function showCircle(circleData,hidePath,_opacity){
	// var opacity = _opacity||'0.6'
	circleData.circle.attr('opacity',bubbleOpacityShow);
	if(!hidePath){
		circleData.path&&circleData.path.attr('opacity',"0.2");
	}else{
		circleData.path&&circleData.path.attr('opacity',bubbleOpacityNone);
	}
	if(dataBubble.length > 10){
		$(circleData.d).fadeTo(0,1);
	}
}
function hideCircle(circleData,iscircle,isPath){
	iscircle&&circleData.circle.attr('opacity',bubbleOpacityHide);
	isPath&&circleData.path.attr('opacity',bubbleOpacityNone);
}
function mousemove(circleData){
	var data = circleData.circle.data("data");
	var opacity = circleData.index == 0 ? '1':bubbleOpacityShow;
	if(circleData.index == 0) {
		circleData.circle.attr('opacity',opacity);
		$(circleData.l).addClass('blod');
		$(circleData.d).addClass('blod');
		return;
	}
	if(data['item']['name'] != dataCenter['name'] || true){
		for (var i = xmoCircles.length - 1; i >= 0; i--){
			var _item = xmoCircles[i];
			hideCircle(_item,true,true);
		};
		showCircle(circleData);
		$(circleData.l).fadeTo(0,1);
		xmoCircles[xmoCircles.length-1].circle.attr('opacity',opacity);
	}
}
function showTooltips(circleData,event,labelCenter){
	var label = circleData['label'];
	if(labelCenter){
		label += ' & '+labelCenter;
	}
	var html = '<div class="xmo-tips-out"><div class="xmo-tips">'+label+'</div><div class="xmo-tips-arrow">▲</div></div>';
	$('.xmo-tips-out').remove();
	$('body').append(html);
	$('.xmo-tips-out').css({width:tipBoxWidth,top:event.clientY+10+$(window).scrollTop(),left:event.clientX-tipBoxWidth/2});
}
function pathIn(){
	for (var i = xmoCircles.length - 1; i >= 0; i--){
		var _item = xmoCircles[i];
		_item.circle.attr('opacity',bubbleOpacityHide);
	};
}
function hideAll(){
	for (var i = xmoCircles.length - 1; i >= 0; i--){
		var _item = xmoCircles[i];
		hideCircle(_item,true,true);
	};
}
function highLightCurrent(circleData){
	if(circleData.label != currentLabel.label){ return}
	hideAll();
	if(currentLabel.type == 'path'){
		circleData.path.attr('opacity',bubbleOpacityShow);		
		circleData.path.attr('stroke-width',"2");
		showTips(circleData,true);
	}
	if(currentLabel.type == 'circle'){
		circleData.circle.attr('opacity',bubbleOpacityShow);		
		circleData.circle.attr('stroke-width',"2");
		showTips(circleData);
	}
	$('div.blod').removeClass('blod');
}
function mouseout(){
	$('.xmo-tips-out').remove();
	for (var i = xmoCircles.length - 1; i >= 0; i--){
		var _item = xmoCircles[i];
		// showCircle(_item,true);
		highLightCurrent(_item);
	};
	if(dataBubble.length > 10){
		$('.bubblelabel').hide();
		$(circleDataCenter.l).show();
	}
}
function removeStroke(){
	for (var i = xmoCircles.length - 1; i >= 0; i--){
		var _item = xmoCircles[i];
		_item.circle.attr("stroke-width", 0);
		_item.path.attr("stroke-width", 0);
	};
}
function funClick(circleData){
	removeStroke();
	circleData.circle.attr("stroke", "#646464");
	circleData.circle.attr("stroke-width", 2);
	// if(!circleData.index) return;
}
function clickChoose(circleData,type){
	currentLabel = {
		label : circleData.label,
		type : type
	};
	var isFocus = type == 'path' ? true : false;
	showTips(circleData,isFocus);
	$(circleData.l).fadeTo(0,1);
}
function addPath(item,i){
	if(!item) return;
	var color = Raphael.fn.bubbleDefaults.colors[i+1];
	var path = paperBubble.path(item._path).attr({"stroke-width":0,"stroke":'#646464','fill':color,'opacity':0.01});  
	xmoCircles[i]["path"] = path;
	path.mouseover(function(ele){
		mousemove(xmoCircles[i]);
		// showTooltips(xmoCircles[i],ele,xmoCircles[0]['label']);
		pathIn(xmoCircles[i]);
		path.attr('opacity',bubbleOpacityShow);
	})
	path.click(function(ele){
		removeStroke();
		clickChoose(xmoCircles[i],'path');
		// mouseout(xmoCircles[i]);
		pathIn(xmoCircles[i]);
		path.attr('stroke-width',"2");
	})
	path.mouseout(function(ele){
		mouseout(xmoCircles[i]);
		path.attr('opacity',bubbleOpacityNone);
	})
}
function overFunc(index){
	if(index != dataBubble.length - 1){return;}
	var center = paperBubble.makeBubble({item:dataCenter},centerX, centerY, radioCenter, 0, 5, dataCenter['total'], dataCenter['name']);
	// center.mousemove(function(ele){
	// 	mousemove(circleData);
	// 	showTooltips(circleData,ele);
	// })
	for (var i = xmoCircles.length - 1; i >= 0; i--) {
		var item = xmoCircles[i];
		addPath(item,i);
	};
}
function format_number(n){
   var b=parseInt(n).toString();
   var len=b.length;
   if(len<=3){return b;}
   var r=len%3;
   return r>0?b.slice(0,r)+","+b.slice(r,len).match(/\d{3}/g).join(","):b.slice(r,len).match(/\d{3}/g).join(",");
}
function getDataByName(name){
	for (var i = dataOrigin.length - 1; i >= 0; i--) {
		if(name == dataOrigin[i][0]){
			return dataOrigin[i];
		}
	};
}
function getOriginDataByName(label){
	for (var i = 0; i < dataOrigin.length; i++) {
		if(label == dataOrigin[i][0]) return dataOrigin[i];
	};
}
function showTips(circleData,isFocus){
	
	var dataItemOrigin = getOriginDataByName(circleData.label);//dataOrigin[circleData['index']];//getDataByName(circleData.label);
	var data = circleData.circle.data("data");
	var title,audience,val;
	if(!isFocus){
		XMO_Band.initTab(dataItemOrigin[1]);
		title = dataItemOrigin[0];
		audience = format_number(dataItemOrigin[1]['audience']);
		val = dataItemOrigin[1]['id'];
	}else{
		XMO_Band.initTab(dataItemOrigin[2]);
		title = dataOrigin[0][0] + ' & ' + dataItemOrigin[0];
		audience = format_number(dataItemOrigin[2]['audience']);
		val = dataItemOrigin[2]['id'];
	}
	$('#brand-id').val(val);
	$('#audience-name').html(title);
	$('#audience-total').html(audience);
	$('#bubble-data-show').show();
}
function bubble_init(_data){
	dataOrigin = _data;
	$('#listBubble').html('');
	$('#bubble-data-show').hide();
	dataCenter = {
		name : _data[0][0],
		total : _data[0][1]['audience']
	}
	for(var i = 1; i < _data.length; i++){
		var item = _data[i];
		$('#listBubble').append('<li><input data-name="'+ item[0] +'" data-total="'+ item[1]['audience'] +'" data-common="'+ item[2]['audience'] +'" type="checkbox" checked><span>'+ item[0].split(/[,，]/)[0] +'</span></li>')
	}
	$('#listBubble input').change(function(){
		if($('#listBubble input:checked').length==0){
			this.checked = true;
			return;
		}
		refreshData();
	});
	$('#listBubble li span').hover(function(){
		var input = $(this).siblings('input');
		if(input[0].checked){
			var text = $(this).text();
			for (var i = xmoCircles.length - 1; i >= 0; i--) {
				var item = xmoCircles[i];
				if(item.label == text){
					mousemove(xmoCircles[i]);
				}
			};
		}
	},function(){
		mouseout();
	});
	$('#listBubble li span').click(function(){
		var input = $(this).siblings('input');
		if(input[0].checked){
			var text = $(this).text();
			for (var i = xmoCircles.length - 1; i >= 0; i--) {
				var item = xmoCircles[i];
				if(item.label == text){
					mousemove(xmoCircles[i]);
					showTips(xmoCircles[i]);
				}
			};
		}
	})
	refreshData();
}
function refreshData(){
	$('#bubbles,#bubbletexts').html('');
	$('#bubbles_wrapper').css({width:StageWidth,height:StageHeight});
	// $('#bubbletexts').css({width:StageWidth,height:StageHeight});

	paperBubble = Raphael(document.getElementById('bubbles'), StageWidth, StageHeight);
	dataBubble = [dataCenter];
	circleData = [];
	xmoCircles = [];
	$('#listBubble input').each(function(){
		var data_item = {};
		if(this.checked){
			data_item['name'] = $(this).attr('data-name');
			data_item['total'] = parseInt($(this).attr('data-total'));
			data_item['common'] = parseInt($(this).attr('data-common'));
			dataBubble.push(data_item);
		}
	})
	stage_init();
	highLightCheck();
}
function highLightCheck(){
	for (var i = xmoCircles.length - 1; i >= 0; i--){
		var _item = xmoCircles[i];
		highLightCurrent(_item);
	};
}
function getRadio(val){
	var levels = 36;
	var levelVal = (maxVal - minVal)/levels;
	var index;
	for(index = 0;index < levels; index++){
		if(minVal+index*levelVal >= val){
			return maxRadio - (levels-index)*(maxRadio-minRadio)/levels;
		}
	}
	return maxRadio;
}
function selectRadius(){
	// for(var i = 1; i < dataBubble.length; i++){
	// 	var itemVal = dataBubble[i][1];
	// 	data_total += itemVal;
	// 	if(minVal > itemVal) minVal = itemVal;
	// 	if(maxVal < itemVal) maxVal = itemVal;
	// }
}
function setR(){
	if(dataBubble.length == 1){
		return;
	}
	var multiple = 1;
	var isContinue = true;
	while(isContinue){
		// console.info(multiple)
		multiple += 0.001;
		for(var i = 1; i < dataBubble.length; i++){
			var item = dataBubble[i];
			var R = item['len']//(item['radius'] + radioCenter)*multiple;
			// console.info(dataBubble[i]['name']+R)
			// angleTotalHalf + 0.5*halfAngleThis
			var ra = item['angleTotalHalf']// + 0.5*item['halfAngleThis'];
			var x = (Math.abs(Math.cos(ra*Math.PI/180)*R)+item['radius'])*multiple;
			var y = (Math.abs(Math.sin(ra*Math.PI/180)*R)+item['radius'])*multiple;
			// console.info(x);
			if(x > StageWidth/2|| y > StageHeight/2){
				// console.info('x:'+x);
				// console.info(StageWidth/2);
				// console.info('y:'+y);
				// console.info('y:'+StageHeight/2);
				// console.info(dataBubble[i]['name'])
				isContinue = false;
				return;
			}
			// dataBubble[i]['radius'] = multiple*item['radius'];
		}
		for(var i = 1; i < dataBubble.length; i++){
			// var item = dataBubble[i];
			dataBubble[i]['radius'] = multiple*dataBubble[i]['radius'];
			dataBubble[i]['len'] = multiple*dataBubble[i]['len'];
		}
		radioCenter = radioCenter*multiple;
		// console.info('radioCenter2'+':'+radioCenter)
	}
}
function stage_init(){
	// radioCenter = dataBubble[0]['radius'];
	// radioCenter = 
	// console.info(dataBubble)
	var area_total = 0;
	var angle_total = 0;
	minVal = 0;
	maxVal = 0;
	paperBubble.clear();
	minVal = dataCenter['total'];
	// 计算cookie总数量
	for(var i = 1; i < dataBubble.length; i++){
		var itemVal = dataBubble[i]['total'];
		if(minVal > itemVal) minVal = itemVal;
		if(maxVal < itemVal) maxVal = itemVal;
	}
	// 获取半径
	for(var i = 0; i < dataBubble.length; i++){
		var item = dataBubble[i];
		var radius = getRadio(item['total']);
		dataBubble[i]['radius']=radius;
		if(i == 0){
			radioCenter = radius;
			continue;
		}
		area_total += radius*radius;
	}
	// 获取偏移角度
	for(var i = 1; i < dataBubble.length; i++){
		var item = dataBubble[i];
		var radius = item['radius'];
		var per = radius*radius/area_total;
		var angleThis = 360*per;
		angle_total += angleThis;
		// 求和中心圆的面积比例
		var per_common = item['total']*item['total']/dataCenter['total']*dataCenter['total'];
		var angleOut = per_common*120;
		angleOut = angleOut > radioCenter ? radioCenter : angleOut;
		angleOut = angleOut < 50  ? 60 : angleOut;
		// angleOut = 60
		var angleOutHalf = angleOut/2;
		var l2 = radius*Math.cos(angleOutHalf*Math.PI/180);
		var l3 = radius*Math.sin(angleOutHalf*Math.PI/180);
		var l1 = Math.sqrt(radioCenter*radioCenter - l3*l3);
		if(item.common == 0){
			l1 = radioCenter;
			l2 = radius;
		}
		var len = l1 + l2;
		var halfAngleThis = Math.atan(l3/l1)/Math.PI*180;
		var angleInHalf = angleThis/2;
		dataBubble[i]['len'] = len;
		dataBubble[i]['angleOut'] = angleOut;
		dataBubble[i]['angleOutHalf'] = angleOutHalf;
		dataBubble[i]['angleThis'] = angleThis;
		dataBubble[i]['angleTotalThis'] = angle_total;
		dataBubble[i]['halfAngleThis'] = halfAngleThis;
		dataBubble[i]['angleTotalHalf'] = angle_total-angleInHalf;
	}
	// 半径最大化
	// console.info(radioCenter)
	setR();
	// console.info(radioCenter)
	/*
		1，计算分布角度
		2，计算位置
		3，计算重合点
	*/ 
	for(var i = 1; i < dataBubble.length; i++){
		var item = dataBubble[i];
		var dataObj = {};
		// 求公共部分占用比例
		var radius = item['radius'];
		var angleOut = item['angleOut'];
		// 求外圆圆心坐标
		var angleThis = item['angleThis'];
		var angleOutHalf = item['angleOutHalf'];
		var len = item['len'];
		dataObj.angleOut = angleOut;
		angleTotalThis = item['angleTotalThis'];
		var angleInHalf = angleThis/2;
		var angleTotalHalf = angleTotalThis-angleInHalf;
		var x_out = centerX + Math.cos(angleTotalHalf*Math.PI/180)*len;
		var y_out = centerY - Math.sin(angleTotalHalf*Math.PI/180)*len;
		// 求交点坐标
		// -- 大半角度数
		var halfAngleThis = item['halfAngleThis'];
		var anglePointTop = angleTotalHalf + halfAngleThis;
		var anglePointBottom = angleTotalHalf - halfAngleThis;
		var r_out =radioCenter/Math.cos(0.5*halfAngleThis*Math.PI/180);
		var r_in = len - radius/Math.cos(0.5*angleOutHalf*Math.PI/180);

		dataObj.point_1 = {
			x : centerX + Math.cos((angleTotalHalf + halfAngleThis)*Math.PI/180)*radioCenter,
			y : centerY - Math.sin((angleTotalHalf + halfAngleThis)*Math.PI/180)*radioCenter,
		}
		// 外部二次曲线参考点
		dataObj.point_2 = {
			x : centerX + Math.cos((angleTotalHalf + 0.5*halfAngleThis)*Math.PI/180)*r_out,
			y : centerY - Math.sin((angleTotalHalf + 0.5*halfAngleThis)*Math.PI/180)*r_out,
		}

		dataObj.point_3 = {
			x : centerX + Math.cos(angleTotalHalf*Math.PI/180)*radioCenter,
			y : centerY - Math.sin(angleTotalHalf*Math.PI/180)*radioCenter,
		}

		dataObj.point_4 = {
			x : centerX + Math.cos((angleTotalHalf - 0.5*halfAngleThis)*Math.PI/180)*r_out,
			y : centerY - Math.sin((angleTotalHalf - 0.5*halfAngleThis)*Math.PI/180)*r_out,
		}
		// 外部二次曲线参考点
		dataObj.point_5 = {
			x : centerX + Math.cos((angleTotalHalf - halfAngleThis)*Math.PI/180)*radioCenter,
			y : centerY - Math.sin((angleTotalHalf - halfAngleThis)*Math.PI/180)*radioCenter,
		}
		var l4 = len - radius;
		var l5 = radius*Math.tan(0.5*angleOutHalf*Math.PI/180);
		var angleLast = Math.atan(l5/l4)/Math.PI*180;
		var lenLast = Math.abs(Math.sqrt(l4*l4+l5*l5));
		dataObj.point_6 = {
			x : centerX + Math.cos((angleTotalHalf-angleLast)*Math.PI/180)*lenLast,
			y : centerY - Math.sin((angleTotalHalf-angleLast)*Math.PI/180)*lenLast,
		}
		dataObj.point_7 = {
			x : centerX + Math.cos(angleTotalHalf*Math.PI/180)*l4,
			y : centerY - Math.sin(angleTotalHalf*Math.PI/180)*l4,
		}
		dataObj.point_8 = {
			x : centerX + Math.cos((angleTotalHalf+angleLast)*Math.PI/180)*lenLast,
			y : centerY - Math.sin((angleTotalHalf+angleLast)*Math.PI/180)*lenLast,
		}
		dataObj.index = i;
		dataObj.item = item;
		paperBubble.makeBubble(dataObj,x_out,y_out, radius, i, i+8, item['total'], item['name']);
	}
	initOver = true;
}
$(function(){
	setTimeout(function(){
		var circleData = xmoCircles[xmoCircles.length-1];
		clickChoose(circleData,'circle');
		mousemove(circleData);
		showTips(circleData);
		funClick(circleData);
	},500)
})



