$(function () {
var LANG = 'CN';
if($('#nav_right .underscore').html() == 'English'){
  LANG = 'EN';
}
// extent jquery validator plugin rules for pretargeting
   
// jQuery.validator.addMethod("show_required", function (value, element) {
//    var v = true;
//    var ele = $(element);
//    if (isSelectDisplay() && ele.val() == "" ) {
//      v = false;
//    }
//    return v;
// },"<%= t('.start_date_cant_be_blank') %>");

if(LANG == 'CN'){
  jQuery.extend(jQuery.validator.messages, {
    required: "不能为空",
    remote: "字段重复",
    email: "不是正确格式的电子邮件",
    url: "不是合法的网址",
    date: "不是合法的日期",
    dateISO: "不是合法的日期 (ISO).",
    number: "必须是合法的数字",
    digits: "必须为整数",
    creditcard: "请输入合法的信用卡号",
    equalTo: "请再次输入相同的值",
    accept: "请输入拥有合法后缀名的字符串",
    maxlength: jQuery.validator.format("请输入一个 长度最多是 {0} 的字符串"),
    minlength: jQuery.validator.format("请输入一个 长度最少是 {0} 的字符串"),
    rangelength: jQuery.validator.format("请输入 一个长度介于 {0} 和 {1} 之间的字符串"),
    range: jQuery.validator.format("请输入一个介于 {0} 和 {1} 之间的值"),
    max: jQuery.validator.format("请输入一个最大为{0} 的值"),
    min: jQuery.validator.format("请输入一个最小为{0} 的值")
  });
}else{
  jQuery.extend(jQuery.validator.messages, {
    required: " cannot be blank"
  });
}
});
$.validator.setDefaults({
   onkeyup : false,//失去焦点后才触发验证
   highlight : function (element, errorClass, validClass) {
    var _this = this;
    if ($(element).attr("dis_wiget")) {
      $($(element).attr("dis_wiget")).addClass(errorClass).removeClass(validClass);
    } else if (element.type === 'radio') {
      this.findByName(element.name).addClass(errorClass).removeClass(validClass);
    }else if($(element).hasClass('chzn-done')){
      //for chosen
      var id = $(element).attr('id'),
        selectArea = $(element).next();
      if(selectArea.hasClass('chzn-container')) {
        $('#' + id +'_chzn').addClass(errorClass);
      }
      $('#'+id).change(function(){
        if(_this.element(element)){
          $('#' + id +'_chzn').removeClass(errorClass);
        }else{
          $('#' + id +'_chzn').addClass(errorClass);
        }
      })
      return false;
    } else {
      $(element).addClass(errorClass).removeClass(validClass);
    }
  },
  unhighlight :function (element, errorClass, validClass) {
    if ($(element).attr("dis_wiget")) {
      $($(element).attr("dis_wiget")).removeClass(errorClass).addClass(validClass);
    } else if (element.type === 'radio') {
      this.findByName(element.name).removeClass(errorClass).addClass(validClass);
    }else if($(element).hasClass('chzn-done')){
       //for chosen
      var id = $(element).attr('id'),
        selectArea = $(element).next();
      if(selectArea.hasClass('chzn-container')) {
        $('#' + id +'_chzn').removeClass(errorClass);
      }
    } else {
      $(element).removeClass(errorClass).addClass(validClass);
    }
  }
});

$.validator.addRequireTag = function(element){
  $(element).each(function(index,ele){
      var html = $(ele).html();
      if(html.lastIndexOf('*') == html.length-1){return false;}
      $(ele).html(html+'*');
  })
}
$.validator.removeRequireTag = function(element){
  $(element).each(function(index,ele){
      var html = $(ele).html();
      if(html.lastIndexOf('*') == html.length-1){
        $(ele).html(html.substring(0,html.length-1));
      }
  })
}
$.validator.prototype.showLabel = function(element, message) {
  var label = this.errorsFor( element );
  var id = $(element).attr('id');
  //add
  var disname = $(element).attr('disname');
  if(disname == undefined){
    disname = '';
    var labels = $(element).parents('.control-group').find('label');
    labels.each(function(index,element){
      if($(element).attr('for') == id){
         disname = $(element).text();
      }
    });
    disname = $.trim(disname);
  };
  if(!!message){message = disname+message;};
  //add

  if ( label.length ) {
    // refresh error/success class
    label.removeClass().addClass( this.settings.errorClass );

    // check if we have a generated label, replace the message then
    label.attr("generated") && label.html(message);
  } else {
    // create label
    label = $("<" + this.settings.errorElement + "/>")
      .attr({"for":  this.idOrName(element), generated: true})
      .addClass(this.settings.errorClass)
      .html(message || "");
    if ( this.settings.wrapper ) {
      // make sure the element is visible, even in IE
      // actually showing the wrapped element is handled elsewhere
      label = label.hide().show().wrap("<" + this.settings.wrapper + "/>").parent();
    }
    if ( !this.labelContainer.append(label).length )
      this.settings.errorPlacement
        ? this.settings.errorPlacement(label, $(element) )
        : label.insertAfter(element);
  }
  if ( !message && this.settings.success ) {
    label.text("");
    typeof this.settings.success == "string"
      ? label.addClass( this.settings.success )
      : this.settings.success( label );
  }
  this.toShow = this.toShow.add(label);
}
