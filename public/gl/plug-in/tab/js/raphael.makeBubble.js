
	Raphael.fn.bubbleDefaults = {
  		colors:["#ebebeb","#f2cb57","#f29c50","#d95a2b","#a61b1b","#f2cb57","#f29c50","#d95a2b","#a61b1b","#f2cb57","#f29c50","#d95a2b","#a61b1b","#f2cb57","#f29c50","#d95a2b","#a61b1b","#f2cb57","#f29c50","#d95a2b","#a61b1b","#f2cb57","#f29c50","#d95a2b","#a61b1b","#f2cb57","#f29c50","#d95a2b","#a61b1b","#f2cb57","#f29c50","#d95a2b","#a61b1b"],
		stroke:0,
		speed:90,
		texts: '#bubbletexts',
		dataClass: 'bubbledata',
		labelClass: 'bubblelabel'
	};
	Raphael.fn.makeBubble = function(dataObj,originx, originy, rad, index, delay, _data, label, dataClass, labelClass, strong) {
		var a, width, top, left, labelsize, fontsize,l,d,isTip;
		var circle = paperBubble.circle(originx, originy);
		if(initOver) delay = 0;
		circle.attr("fill", this.bubbleDefaults.colors[index]);
		circle.attr("opacity","0.8");
		circle.data("data",dataObj);
		if(xmoCircles.length == 1){
			circle.attr("stroke-width", 0)//this.bubbleDefaults.stroke);
			circle.attr("z-index", 1000);
		}else{
			circle.attr("stroke-width", 0);
		}
		// circle.attr("stroke", '#026cea');
		a = Raphael.animation({'r':rad}, 700, 'elastic');
		circle.animate(a.delay(this.bubbleDefaults.speed * delay));
		width = rad * 2 * 0.75;
		top = originy - (rad * 0.25);
		left = originx - rad + (rad * 0.25);
		labelsize = Math.sqrt(width) * 1.1;
		fontsize = Math.sqrt(width) * 1.2;
		if(strong) fontsize *= 1.5;
		var _label = label.split(/[,，]/)[0];
		if(_label.length != label.length){
			_label+='...';
			isTip = true;
		}
		d = $("<div />")
			.addClass(this.bubbleDefaults.dataClass)
			.hide()
			.css('position','absolute')
			.css('textAlign','center')
			.css('width', width)
			.css('top', top)
			.css('left', left)
			.css('fontSize', fontsize + 'px')
			.html(_label)
			.appendTo(this.bubbleDefaults.texts);
		top = originy + (rad * 0.12);
		
		l = $("<div />")
			.addClass(labelClass)
			.addClass(this.bubbleDefaults.labelClass)
			.hide()
			.css('position','absolute')
			.css('textAlign','center')
			.css('width', width)
			.css('top', top)
			.css('left', left)
			.css('fontSize', labelsize + 'px')
			.html(format_number(_data))
			.appendTo(this.bubbleDefaults.texts);
		var eventName = 'mouse.under.'+new Date().getTime();
			var circleData = {
				circle : circle,
				l : l,
				d : d,
				index : index
			}
			
			circle.click(function(){
				// console.info(circleData)
				clickChoose(circleData,'circle');
				mousemove(circleData);
				showTips(circleData);
				funClick(circleData);
				// console.info('ok')
			})
			d.click(function(){
				clickChoose(circleData,'circle');
				mousemove(circleData);
				showTips(circleData);
				funClick(circleData);
			})
			l.click(function(){
				clickChoose(circleData,'circle');
				mousemove(circleData);
				showTips(circleData);
				funClick(circleData)
			})
			circle.mouseout(function(){
				mouseout(circleData);
			})
			circle.mousemove(function(ele){
				mousemove(circleData);
				if(isTip)showTooltips(circleData,ele);
			})
			d.mousemove(function(ele){
				mousemove(circleData);
				if(isTip)showTooltips(circleData,ele);
			})
			l.mousemove(function(ele){
				mousemove(circleData);
				if(isTip)showTooltips(circleData,ele);
			})

			l.mouseover(function(ele){
				if(isTip)showTooltips(circleData,ele);
			})
			d.mouseover(function(ele){
				if(isTip)showTooltips(circleData,ele);
			})
			circle.mouseover(function(ele){
				if(isTip)showTooltips(circleData,ele);
			})
			circleData.label = label;
		if(dataObj.point_1){
			var path = [
				"M",dataObj.point_1.x,dataObj.point_1.y,
				"Q",dataObj.point_2.x,dataObj.point_2.y,dataObj.point_3.x,dataObj.point_3.y,
				"Q",dataObj.point_4.x,dataObj.point_4.y,dataObj.point_5.x,dataObj.point_5.y,
				"Q",dataObj.point_6.x,dataObj.point_6.y,dataObj.point_7.x,dataObj.point_7.y,
				"Q",dataObj.point_8.x,dataObj.point_8.y,dataObj.point_1.x,dataObj.point_1.y,
			]
			circleData._path = path;
			circleData.circle = circle;
			xmoCircles.push(circleData);
			overFunc(dataObj.index);
		}else{
			circleDataCenter = circleData;
			xmoCircles.push(circleData);
		}
		setTimeout($.proxy(function(){
			if(dataBubble.length > 10&&dataObj.point_1){
				$(l).hide();
			}else{
				$(l).fadeIn('slow');
			}
			$(d).fadeIn('slow');
		},{d:d,l:l}), this.bubbleDefaults.speed * delay);
		return [circle,eventName];
	}