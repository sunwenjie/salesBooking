var iclickIcon = window.iclickIcon || {};
iclickIcon.i = "./i.jpg";
iclickIcon.i_logo = "./i_logo.jpg";
iclickIcon.ihref = "http://www.baidu.com";
iclickIcon.addIcon = function(wrapperId){
	var icon = document.createElement('div');
	icon.setAttribute('class','iclick_i_box');
	var wrapperBox = document.getElementById(wrapperId);
	wrapperBox.style.cssText = 'position:relative;';
	icon.innerHTML = '<style type="text/css">.iclick_i_box{position: absolute;top: 4px;right: 4px;z-index: 100000;}.iclick_i_box .iclick_i_a{display: block;height: 15px;}.iclick_i_box .iclick_i_a img{display: inline;}.iclick_i_box .iclick_i_a .iclick_i_logo{display: none;}.iclick_i_box .iclick_i_a:hover .iclick_i_logo{display: inline;}</style><a class="iclick_i_a" href="'+ iclickIcon.ihref +' target="_blank"><img class="iclick_i_logo" src="'+this.i_logo+'"/><img class="iclick_i" src="'+this.i+'"/></a>';
	wrapperBox.appendChild(icon);
}
iclickIcon.addIcon('ad_img');
iclickIcon.addIcon('ad_video');


