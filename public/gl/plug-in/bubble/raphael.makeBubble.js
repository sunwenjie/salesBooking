	Raphael.fn.bubbleDefaults = {
		  		colors:[["#77a6d6","#6a94bf"], ["#f5b034", "#e6a531"], ["#ff6600","#ffffff"], ["#95d132","#88bf2e"], ["#f5b034", "#e6a531"], ["#ff6600","#ffffff"], ["#95d132","#88bf2e"], ["#f5b034", "#e6a531"], ["#ff6600","#ffffff"], ["#95d132","#88bf2e"], ["#f5b034", "#e6a531"], ["#ff6600","#ffffff"], ["#95d132","#88bf2e"]],
				stroke:3,
				speed:90,
				texts: '#bubbletexts',
				dataClass: 'bubbledata',
				labelClass: 'bubblelabel'
		  	};
	var xmo_circles = [];
	Raphael.fn.makeBubble = function(dataObj,originx, originy, rad, color, delay, data, label, dataClass, labelClass, strong) {
		var circle, a, width, top, left, labelsize, fontsize;
		circle = paper.circle(originx, originy);
		xmo_circles.push(circle);
		circle.attr("fill", this.bubbleDefaults.colors[color][0]);
		circle.attr("opacity","0.5");
		circle.data("data",dataObj);
		if(xmo_circles.length == 1){
			circle.attr("stroke-width", this.bubbleDefaults.stroke);
			circle.attr("z-index", 1000);
		}else{
			circle.attr("stroke-width", 0);
		}
		circle.attr("stroke", '#026cea');
		a = Raphael.animation({'r':rad}, 700, 'elastic');
		circle.animate(a.delay(this.bubbleDefaults.speed * delay));
		width = rad * 2 * 0.75;
		top = originy - (rad * 0.25);
		left = originx - rad + (rad * 0.25);
		labelsize = Math.sqrt(width) * 1.1;
		fontsize = Math.sqrt(width) * 1.2;
		if(strong) fontsize *= 1.5;
		d = $("<div />")
			.addClass(dataClass)
			.addClass(this.bubbleDefaults.dataClass)
			.hide()
			.css('position','absolute')
			.css('textAlign','center')
			.css('width', width)
			.css('top', top)
			.css('left', left)
			.css('fontSize', fontsize + 'px')
			.html(label)
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
			.html(format_number(data))
			.appendTo(this.bubbleDefaults.texts);
		var eventName = 'mouse.under.'+new Date().getTime();
		circle.click(function(){
			clickFunc(circle);
		})
		d.click(function(){
			clickFunc(circle);
		})
		l.click(function(){
			clickFunc(circle);
			// eve(eventName);
		})

		setTimeout($.proxy(function(){ $(this.d).fadeIn('slow'); $(this.l).fadeIn('slow'); }, {d:d,l:l}), this.bubbleDefaults.speed * delay);
		return [circle,eventName];
	}