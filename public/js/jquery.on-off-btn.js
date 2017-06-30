(function($) {  
  var LANG = 'CN';
  if($('#nav_right .underscore').html() == 'English'){
  	LANG = 'EN';
  }
  var statusObj = {
    on : 'off',
    off : 'on'
  };
  var changeStatus = function(This){
      var _this = This || this;
      var status = $(_this).attr('status');
      var  classAdd= 'btn-'+ statusObj[status] +'-'+LANG.toLowerCase();
      var classRemoved = 'btn-'+ status +'-'+LANG.toLowerCase();
      $(_this).attr('status',statusObj[status]).removeClass(classRemoved).addClass(classAdd);
  }
  $.fn.onOffBtn = function() {
      return this.each(function(){
          var $this = $(this);
          $this.click(function(){
            if($this.attr('data-disable') == null || $this.attr('data-disable') == "no") changeStatus(this);
          });
          var status = $this.attr('status');
          var classRemoved = 'btn-'+ status +'-'+LANG.toLowerCase();
          var classAdd = 'btn-'+ status +'-'+LANG.toLowerCase();
          $this.removeClass(classRemoved).addClass(classAdd);
      });
  };
  $.fn.getOnOffBtnStatus = function(){
	   var a = {on:true,off:false};
  	 return a[$(this).attr('status')];
  };
  $.fn.onOffBtnStatusChange = changeStatus;
// 闭包结束
})(jQuery); 