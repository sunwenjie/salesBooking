function xmoCalendar(options){
  var _this = this;
  var date_now = new Date();
  _this.today = _this.addZero(date_now);
  _this.isShow = true;
  _this.boxId = date_now.getTime();
  _this.inputId = options['inputId'];
  _this.lang_opt = options['lang'] || 'EN';
  _this.exclude = typeof options['exclude'] == 'undefined' ? true : options['exclude'];
  _this.inputObj = $(_this.inputId);
  _this.monthAry = [];
  _this.submitCallback = options['submitCallback'] || null;
  // 动态保存from 和 to的值
  _this.dateFrom = '';
  _this.dateTo = '';
  // from 和 to是否都已经选择
  _this.selectedDone = false;
  _this.selected_foot_Done = false;
  // 日历中所显示当前年月
  _this.currentFirstYear = 0;
  _this.currentFirstMonth = 0;
  // 位置调整
  _this.offsetLeft = options['offsetLeft'] || 0;

  _this.initTime = _this.dateToAry(new Date((options['initTime'] || _this.today).replace(/-/g, '/')));
  // 设定可用的时间范围
  _this.startTime = _this.dateToAry(new Date((options['startTime'] || '1980-12-11').replace(/-/g, '/')));
  _this.endTime = _this.dateToAry(new Date((options['endTime'] || '3000-12-11').replace(/-/g, '/')));
  _this.startTimeOld = '';
  _this.endTimeOld = '';
  _this.compareFrom = '';
  _this.compareTo = '';
  // 被删除的时间
  _this.removed = {};
  _this.exclude_dates_obj = _this.inputObj.parent().find('.exclude_dates')
  _this.exclude_dates_obj.length > 0 ? '' : _this.exclude_dates_obj=$('<input/>');
  _this.iconTrigger = options['iconTrigger'] || '.icon_trigger';
  _this.menu = options['menu'] || ['range'];
  _this.type = options['type'] || 'default';
  _this.compareCheckbox = false;
  //被禁用的时间
  _this.disabledDate=options["disabledDate"] || [];
  _this.disabledJs={};
  //是否可以取消中间的值
  _this.canCancel = options['canCancel'] || false;
  // 初始化数据
  _this.init();
}

xmoCalendar.prototype.selecteOver = function(){
  var _this = this;
  _this.selectedDone = true;
  _this.wrapperBox.removeClass('inputingBox');
  $('.xmoCalendarMainHead input',_this.wrapperBox).removeClass('inputing');
  $('.xmoCalendarTableTips',_this.wrapperBox).html('');
  $('.xmoCalendarMainHead input',_this.wrapperBox).blur();
}

xmoCalendar.prototype.selecting = function(){
  var _this = this;
  _this.selectedDone = false;
  $('.inputing',_this.wrapperBox).removeClass('inputing');
  _this.wrapperBox.addClass('inputingBox');
  $('.xmoCalendarTableTips',_this.wrapperBox).html('');
}

xmoCalendar.prototype.selecting_foot = function(){
  var _this = this;
  _this.selected_foot_Done = false;
  $('.inputing',_this.wrapperBox).removeClass('inputing');
  _this.wrapperBox.addClass('inputingBox');
  $('.xmoCalendarTableTips',_this.wrapperBox).html('');
}

xmoCalendar.prototype.init_html = function(){
  var _this = this;
  var lang = _this.lang[_this.lang_opt],
      menuHtml = '',
      boxClass = '',
      CompositeAllHtml = '';
  for (var i = 0; i < _this.menu.length; i++) {
    var itemMenu = _this.menu[i];    
    if(itemMenu == 'range'){
      menuHtml += '<dd data-type="'+ itemMenu +'" class="current">'+ lang[itemMenu] + '</dd>';
    }else{
      menuHtml += '<dd data-type="'+ itemMenu +'">'+ lang[itemMenu] + '</dd>';
    }
  };
  if(_this.type == 'CompositeAll'){
    var inputDateOriginLength = $(_this.inputId).val().split('~').length;
    if(inputDateOriginLength == 2){
      CompositeAllHtml = '<div class="cle"></div><div class="CompositeAllBox"> <div class="CompositeAllBox_1"> <span> <input type="checkbox"/>'+ lang['CompareTo'] +'</span> <select class="CompareType"><option value="previous">'+ lang['previous'] +'</option><option value="range">'+ lang['range'] +'</option></select></div><div class="row xmoCalendarMainFoot"><div class="span"><label class="sub_txt2">'+lang['from']+'<input type="text" class="xmoCalendarFrom" placeholder="YYYY-MM-DD"></label></div><div class="span r_margin_5"><label class="sub_txt2">'+lang['to']+'<input type="text" placeholder="YYYY-MM-DD" class="xmoCalendarTo"></label></div></div></div>';
    }else{
      CompositeAllHtml = '<div class="cle"></div><div class="CompositeAllBox"> <div class="CompositeAllBox_1"> <span> <input type="checkbox"/>'+ lang['CompareTo'] +'</span> <select class="CompareType"><option value="range">'+ lang['range'] +'</option></select></div><div class="row xmoCalendarMainFoot"><div class="span"><label class="sub_txt2">'+lang['from']+'<input type="text" class="xmoCalendarFrom" placeholder="YYYY-MM-DD"></label></div><div class="span r_margin_5"><label class="sub_txt2">'+lang['to']+'<input type="text" placeholder="YYYY-MM-DD" class="xmoCalendarTo"></label></div></div></div>';
    }
  }
  // 初始化html结构
  var excludeClass = ' xmoCalendarTableEclude';
  if(_this.exclude) excludeClass = ''
  var baseHtml = '<div class="xmoCalendarWraper'+ excludeClass +' xmoCalendar'+ _this.type +'" id="'+ _this.boxId +'"><svg class="svg-triangle" style="margin-left:'+(-_this.offsetLeft)+'px" version="1.1" xmlns="http://www.w3.org/2000/svg"><polygon style="fill:#fff; stroke:#EEEEEE;stroke-width:1" points="0,9 6,0 12,9 "/><polygon style="fill:#fff; stroke:#fff;stroke-width:1" points="0,9 12,9 "/></svg><div class="xmoCalendarInner"><div class="xmoCalendarDataRange"><dl>'+ menuHtml +'</dl></div><div class="xmoCalendarMainArea"><div class="row xmoCalendarMainHead"><div class="span"><label class="sub_txt2">'+lang['from']+'<input type="text" class="xmoCalendarFrom" placeholder="YYYY-MM-DD"></label></div><div class="span r_margin_5"><label class="sub_txt2">'+lang['to']+'<input type="text" placeholder="YYYY-MM-DD" class="xmoCalendarTo"></label></div><div class="xmoCalendarError"></div></div><div class="cle"></div><div class="xmoCalendarTitle"><table><tr><td class="xmoCalendarMonth"></td><td class="xmoCalendarMonth"></td><td class="xmoCalendarMonth"></td></tr></table><div class="xmoCalendarPrev"></div><div class="xmoCalendarNext"></div></div><div class="xmoCalendarList"><div class="xmoCalendarTableWraper xmoCalendarTableWraperLast"></div><div class="cle"></div></div><div class="pull-left t_padding_10 xmoCalendarTableTips"></div>'+ CompositeAllHtml +'<div class="outer_submit"><input value="'+ lang['submit'] +'" class="submit" type="button"></div><div class="xmoCalendarClear"></div></div><div class="cle"></div></div></div>';
  $('body').append(baseHtml);
  _this.wrapperBox = $('#' + _this.boxId);
  _this.xmoCalendarList = $('.xmoCalendarList',_this.wrapperBox);
  _this.btnLeft = $('.xmoCalendarPrev',_this.wrapperBox);
  _this.btnRight = $('.xmoCalendarNext',_this.wrapperBox);
 
  var xmoCalendarList = _this.getDataTable(_this.initTime[0],_this.initTime[1]);
  _this.xmoCalendarList.html(xmoCalendarList);
  _this.refreshDisabled();
}

xmoCalendar.prototype.closeBox = function(){
    this.wrapperBox.hide();
    $('#mask').remove();
}

xmoCalendar.prototype.last_7_days = function(){
  var _this = this;
  var now = new Date().getTime()-1*24*60*60*1000;
  var _last_7_days = now - 6*24*60*60*1000;   //星期日
  return _this.backdate(_last_7_days,now);
}
xmoCalendar.prototype.last_30_days = function(){
  var _this = this;
  var now = new Date().getTime()-1*24*60*60*1000;
  var last_30_days = now - 29*24*60*60*1000;   //星期日
  return _this.backdate(last_30_days,now);
}

xmoCalendar.prototype.getThisWeek = function(){
  var _this = this;
  var now = new Date();
  var currentWeek = now.getDay();
  if(currentWeek == 0){currentWeek = 7;}
  var monday = now.getTime() - (currentWeek-1)*24*60*60*1000;   //星期一
  var sunday = now.getTime() + (7-currentWeek)*24*60*60*1000;   //星期日
  return _this.backdate(monday,sunday);
}

xmoCalendar.prototype.getLastWeek = function(){
  var _this = this;
  var now = new Date();
  var currentWeek = now.getDay();
  if(currentWeek == 0){currentWeek = 7;}
  var monday = now.getTime() - (currentWeek-1+7)*24*60*60*1000;   //星期一
  var sunday = now.getTime() + (7-currentWeek - 7)*24*60*60*1000;   //星期日
  return _this.backdate(monday,sunday);
}

xmoCalendar.prototype.getThisYear = function(){
  var _this = this;
  var firstDate = new Date();
  firstDate.setDate(1); //第一天
  firstDate.setMonth(0); //第一天
  var endDate = new Date(firstDate);
  endDate.setMonth(12);
  endDate.setDate(0);
  return _this.backdate(firstDate,endDate);
}

xmoCalendar.prototype.getThisMonth = function(){
  var _this = this;
  var firstDate = new Date();
  firstDate.setDate(1); //第一天
  var endDate = new Date(firstDate);
  endDate.setMonth(firstDate.getMonth()+1);
  endDate.setDate(0);
  return _this.backdate(firstDate,endDate);
}

xmoCalendar.prototype.getLastMonth = function(){
  var _this = this;
  var firstDate = new Date();
  var month = firstDate.getMonth();
  month--;
  var year = firstDate.getFullYear();
  if(month < 0) {month = 11,year--};
  firstDate.setMonth(month);
  firstDate.setYear(year);
  firstDate.setDate(1); //第一天
  var endDate = new Date(firstDate);
  endDate.setMonth(month+1);
  endDate.setDate(0);
  return _this.backdate(firstDate,endDate);
}

xmoCalendar.prototype.getLast_Month = function(num){
  var _this = this;
  var firstDate = new Date();
  var month = firstDate.getMonth();
  var year = firstDate.getFullYear();
  firstDate.setDate(1); //第一天
  var endDate = new Date(firstDate);
  endDate.setMonth(month + 1);
  endDate.setDate(0);
  month -= num;
  month += 1;
  if(month < 0) {month = 12 + month,year--};
  firstDate.setMonth(month);
  firstDate.setYear(year);
  return _this.backdate(firstDate,endDate);
}

xmoCalendar.prototype.backdate = function (day1,day2){
  var day1 = this.dateToAry(day1);
  var day2 = this.dateToAry(day2);
  return day1[0] + '-' + day1[1] + '-' + day1[2] + ' ~ ' + day2[0] + '-' + day2[1] + '-' + day2[2];
}
xmoCalendar.prototype.init_Event = function(){
  var _this = this;
  var lang = _this.lang[_this.lang_opt];
  $(_this.inputId).addClass('xmoCalendarInputSchedule');
  $("body").on("focusin",_this.inputId,function(){
     _this.showCalendar();
      return false;
  });
  $(_this.inputId).parent().on("click",_this.iconTrigger,function(e){
     _this.showCalendar();
     return false;
  });
  _this.btnLeft.click(function(e){
    _this.btnLeftFunc();
    e.preventDefault();
    e.stopPropagation();
    this.focus();
    return false;
  });

  _this.btnRight.click(function(){
    _this.btnRightFunc();
  });

  $('.xmoCalendarDataRange dd',_this.wrapperBox).click(function(){
    var type = $(this).attr('data-type');
    switch(type){
      case 'none':
        _this.inputObj.val('');
        break;
      case 'today':
        _this.inputObj.val(_this.today);
        break;
      case 'last_7_days':
        _this.inputObj.val(_this.last_7_days());
        break;
      case 'last_30_days':
        _this.inputObj.val(_this.last_30_days());
        break;
      case 'this_week':
        _this.inputObj.val(_this.getThisWeek());
        break;
      case 'this_month':
        _this.inputObj.val(_this.getThisMonth());
        break;
      case 'this_yeah':
        _this.inputObj.val(_this.getThisYear());
        break;
      case 'last_week':
        _this.inputObj.val(_this.getLastWeek());
        break;
      case 'last_month':
        _this.inputObj.val(_this.getLastMonth());
        break;
      case 'last_3_month':
        _this.inputObj.val(_this.getLast_Month(3));
        break;
      case 'last_12_month':
        _this.inputObj.val(_this.getLast_Month(12));
        break;
    }
    _this.closeBox();
  });

  $('#' + _this.boxId + ' .xmoCalendarMainHead input').focusin(function(){
    _this.selecting();
    $(this).addClass('inputing');
  }).change(function(){
    var date = $(this).val();
    if(date.length == 0) return false;
    var isExist = _this.checkDateExist(date);
    // 如果日期合法
    if(isExist){
      var val = _this.addZero(date);
      $(this).val(val);
      var dateCanBeUse = true;
      if($(this).hasClass('xmoCalendarFrom')){
        _this.dateFrom = val;
        dateCanBeUse = _this.checkDate(date,'from');
      }else{
        _this.dateTo = val;
        dateCanBeUse = _this.checkDate(date,'to');
      }
      if(dateCanBeUse){
        $('.xmoCalendarMainHead input',_this.wrapperBox).removeClass('inputing');
      }
      _this.focusCheck();
      _this.setCurrentDay(_this.dateFrom == '' ? _this.dateTo : _this.dateFrom);
      _this.updateRemoved();
      _this.reTableList();
    }else{
      var lang = _this.lang[_this.lang_opt];
      _this.errorTip(lang['dateFormatUncorrect']);
    }
  });

  $('#' + _this.boxId + ' .xmoCalendarMainFoot input').focusin(function(){
    _this.selecting_foot();
    $(this).addClass('inputing');
  }).change(function(){
    var date = $(this).val();
    if(date.length == 0) return false;
    var isExist = _this.checkDateExist(date);
    // 如果日期合法
    if(isExist){
      var val = _this.addZero(date);
      $(this).val(val);
      var dateCanBeUse = true;
      if($(this).hasClass('xmoCalendarFrom')){
        _this.compareFrom = val;
        dateCanBeUse = _this.checkDateFoot(date,'from');
      }else{
        _this.compareTo = val;
        dateCanBeUse = _this.checkDateFoot(date,'to');
      }
      if(dateCanBeUse){
        $('.xmoCalendarMainFoot input',_this.wrapperBox).removeClass('inputing');
      }
      _this.focusCheckFoot();
      _this.reTableList();
    }else{
      var lang = _this.lang[_this.lang_opt];
      _this.errorTip(lang['dateFormatUncorrect']);
    }
  });

  $(document).on('click','#' + _this.boxId + ' table td a:not(.disabled)',function(){
      var date = $(this).attr('title');
      var targetInput = $('.inputing',_this.wrapperBox);
      var dateFrom = $('.xmoCalendarMainHead .xmoCalendarFrom',_this.wrapperBox);
      var dateTo = $('.xmoCalendarMainHead .xmoCalendarTo',_this.wrapperBox);
      // 如果正在选择对比日期
      if(targetInput.closest('.row').hasClass('xmoCalendarMainFoot')){
        targetInput.val($(this).attr('title'));
        _this.compareCheckbox = $('.CompositeAllBox_1 input')[0].checked;
        _this.compareFrom = $('.xmoCalendarMainFoot .xmoCalendarFrom',_this.wrapperBox).val();
        _this.compareTo = $('.xmoCalendarMainFoot .xmoCalendarTo',_this.wrapperBox).val();
        _this.focusCheckFoot();
        if(_this.compareFrom.length > 0 && _this.compareTo.length > 0){
          _this.reTableList();
        }
        return;
      }

      $('.xmoCalendarTableTips',_this.wrapperBox).html('');

      if(_this.type == 'OnlySelectDate'){
        _this.inputObj.val($(this).attr('title'));
        _this.closeBox();
        return false;
      }
      // 判断选择是否完成
      // 没有选择范围之前，焦点要么在from要么在to
      // 要检查数据的合法性
      // 1.选择已经完成
      var dateCanBeUse = true;
      if(targetInput.hasClass('xmoCalendarFrom')){
          dateCanBeUse = _this.checkDate(date,'from');
      }else if(targetInput.hasClass('xmoCalendarTo')){
          dateCanBeUse = _this.checkDate(date,'to');
      }
      if(!dateCanBeUse) {
        _this.selecteOver();
        return false;
      }
      if(_this.selectedDone){
          // 判断是否在范围中 且已经选择
          // 删除一个日期
          var index = $(this).closest('tr').find('td').index($(this).parent());
          if(_this.exclude&&$(this).hasClass('selected')){
             if(!_this.canCancel) return;
            _this.tipsExcludeOneDayInEveryMonth(date,index);
            _this.removed[date] = true;
          }
          // 反删除一个日期
          if($(this).hasClass('removed')){
             if(!_this.canCancel) return;
            _this.tipsSelectOneDayInEveryMonth(date,index);
            delete _this.removed[date];
          }
      }else{
      // 1.选择没有完成
          targetInput.val(date).removeClass('inputing');
          if(targetInput.hasClass('xmoCalendarTo')){
            _this.dateTo = date;
          }else{
            _this.dateFrom = date;
          }
          _this.focusCheck();
      }
      _this.updateRemoved();
      targetInput.blur();
      _this.reTableList();
  })
  $(document).on('mouseover','#' + _this.boxId + ' table th a',function(){
      var index = $(this).attr('index');
      var selected = $(this).parents('table').first().find('a.selected[week="'+ index +'"]');
      var removed = $(this).parents('table').first().find('a.removed[week="'+ index +'"]');
      // 如果全部被删除了
      if(selected.length == 0 && removed.length > 0){
        $(this).attr('class','thSelectAllHover');
      }else if(selected.length > 0){
        $(this).attr('class','thRemoveAllHover');
      }
  })
  $(document).on('mouseout','#' + _this.boxId + ' table th a',function(){
         $(this).attr('class','');
  })

  $(document).on('click','#' + _this.boxId + ' table th a',function(){
     if(!_this.canCancel) return;
      if(!_this.exclude) return;
      var index = $(this).attr('index');
      index = parseInt((index),10);
      var className = $(this).attr('class');
      _this.focusCheck();
      if(className && className.indexOf('thRemoveAllHover') >= 0 && _this.selectedDone){
          _this.tipsAllWeekSelect(index,this);
      }else if(className && className.indexOf('thSelectAllHover') >= 0 && _this.selectedDone){
          _this.tipsAllWeekUnselect(index,this);
      }
  })

  $(document).on('click','#' + _this.boxId + ' .submit',function(e){
      var dateFrom = $.trim(_this.dateFrom);
      var dateTo = $.trim(_this.dateTo);
      var result = '';
      if(dateFrom.length > 0 && dateTo.length > 0){
        result = dateFrom + ' ~ ' + dateTo;
      }else{
        _this.focusCheck();
        return false;
      }
      var dateCanBeUse = _this.isInRange(dateTo,'1977-01-01',dateFrom);
      if(dateCanBeUse && dateTo != dateFrom){
        var lang = _this.lang[_this.lang_opt];
        _this.errorTip(lang['err_2']);
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
      $(_this.inputId).val(result);
      _this.updateRemoved(true);
      _this.submitCallback && _this.submitCallback(_this);
      _this.closeBox();
  })
  $(document).on('change','#' + _this.boxId + ' .CompositeAllBox .CompareType',function(e){
    var checked = $('.CompositeAllBox_1 input',_this.wrapperBox)[0];
    var CompareType = $(this).val();
    _this.compareCheckbox = checked;
    if(checked && CompareType == 'previous'){
      _this.compareFrom = _this.startTimeOld;
      _this.compareTo = _this.endTimeOld;
      _this.reTableList();
      $('.xmoCalendarMainFoot .xmoCalendarFrom',_this.wrapperBox).attr('disabled',true).val(_this.startTimeOld);
      $('.xmoCalendarMainFoot .xmoCalendarTo',_this.wrapperBox).attr('disabled',true).val(_this.endTimeOld)
    }else if(checked && CompareType == 'range'){
      _this.compareFrom = $('.xmoCalendarMainFoot .xmoCalendarFrom',_this.wrapperBox).attr('disabled',false).val();
      _this.compareTo = $('.xmoCalendarMainFoot .xmoCalendarTo',_this.wrapperBox).attr('disabled',false).val();
      if(_this.compareFrom.length > 0 && _this.compareTo.length > 0){
        _this.reTableList();
      }
    }else{
        _this.compareCheckbox = false;
        _this.focusCheckFoot();
        _this.reTableList();
    }
  })
  $(document).on('change','#' + _this.boxId + ' .CompositeAllBox_1 input',function(e){
    var checked = this.checked;
    var CompareType = $('.CompareType',_this.wrapperBox).val();
    _this.compareCheckbox = checked;
    if(checked && CompareType == 'previous'){
      _this.compareFrom = _this.startTimeOld;
      _this.compareTo = _this.endTimeOld;
      _this.reTableList();
      $('.xmoCalendarMainFoot .xmoCalendarFrom',_this.wrapperBox).attr('disabled',true).val(_this.startTimeOld);
      $('.xmoCalendarMainFoot .xmoCalendarTo',_this.wrapperBox).attr('disabled',true).val(_this.endTimeOld)
    }else if(checked && CompareType == 'range'){
      _this.compareFrom = $('.xmoCalendarMainFoot .xmoCalendarFrom',_this.wrapperBox).attr('disabled',false).val();
      _this.compareTo = $('.xmoCalendarMainFoot .xmoCalendarTo',_this.wrapperBox).attr('disabled',false).val();
      if(_this.compareFrom.length > 0 && _this.compareTo.length > 0){
        _this.reTableList();
      }
    }else{
        _this.compareCheckbox = false;
        _this.focusCheckFoot();
        _this.reTableList();
    }
  })

}

xmoCalendar.prototype.init = function(){
  var _this = this;
  _this.init_html();
  _this.initDate();
  _this.init_Event();
}

xmoCalendar.prototype.errorTip = function(msg){
  var _this = this,
      tipBox = _this.tipBox || (_this.tipBox = $('.xmoCalendarError',_this.wrapperBox));
  tipBox.html(msg);
  clearInterval(_this.errorTipInterval);
  _this.errorTipInterval = setInterval(function(){
      tipBox.html('');
  },4000);
}

xmoCalendar.prototype.checkDateExist = function(date){
  var _this = this;
  var dateAry = _this.dateToAry(date);
  if(dateAry.length != 3) return false;
  var dateOneMonth = _this.getMonthData(dateAry[0],dateAry[1]);
  for (var i = 0; i < dateOneMonth.length; i++) {
    var item = dateOneMonth[i];
    for (var j = 0; j < item.length; j++) {
      var day = item[j] ;
       if(day['year'] == dateAry[0] && day['month'] == dateAry[1] && day['day'] == dateAry[2]) 
        {
          return true;
        }
    };
  };
  return false;
}

xmoCalendar.prototype.showCalendar = function(month, year){
  var _this = this;
  var $input = $(_this.inputId);
  var top = $input.offset().top + $input.outerHeight();
  var left = $input.offset().left;
  if(_this.type == 'CompositeFastSelect'){
    left += 68
  }
  left += _this.offsetLeft;
  _this.wrapperBox.show().css({top : top,left:left,"z-index":100001});
  // _this.wrapperBox.show().css({top : top,left:left,"z-index":100000});
 
    var mask = $('<div id="mask"></div>').css({"z-index":100000,height:$(document).height(),width:$(document).width()}).click(function(){
      _this.wrapperBox.hide();
      $(this).remove();
    });
    $('body').append(mask);
  
  
  _this.initDate();
  _this.focusCheck();
}

xmoCalendar.prototype.initDate = function(){
  var _this = this;
  var inputDateOrigin = $(_this.inputId).val();
  if(_this.type == 'OnlySelectDate'){
    _this.dateFrom = inputDateOrigin;
    _this.reTableList();
    _this.wrapperBox.addClass('inputingBox');
    return false;
  }
  var inputDateOriginAry = inputDateOrigin.split(' ~ ');
  if(inputDateOriginAry.length == 0) inputDateOriginAry = inputDateOrigin.split('~');
  if(inputDateOriginAry.length == 2){
    _this.dateFrom = inputDateOriginAry[0];
    _this.dateTo = inputDateOriginAry[1];
    _this.startTimeOld = inputDateOriginAry[0];
    _this.endTimeOld = inputDateOriginAry[1];
    $('.xmoCalendarMainHead .xmoCalendarFrom',_this.wrapperBox).val(_this.dateFrom);
    $('.xmoCalendarMainHead .xmoCalendarTo',_this.wrapperBox).val(_this.dateTo);
    _this.setCurrentDay(_this.dateFrom);
    var romovedAry = _this.exclude_dates_obj.val().split(',');
    _this.removed = {};
    for(var i =0; i < romovedAry.length; i++){
      if(_this.exclude) _this.removed[romovedAry[i]] = true;
    }
    _this.selecteOver();
    _this.updateRemoved();
    _this.reTableList();
  }else{
    _this.dateFrom = '';
    _this.dateTo = '';
    // from 和 to是否都已经选择
    _this.removed = {};
    $('.xmoCalendarMainHead .xmoCalendarFrom',_this.wrapperBox).val('');
    $('.xmoCalendarMainHead .xmoCalendarTo',_this.wrapperBox).val('');
    _this.setCurrentDay(_this.today);
    _this.selecting();
    _this.updateRemoved();
    _this.reTableList();
  }
}

xmoCalendar.prototype.setCurrentDay = function(date){
    var _this = this;
    var todayAry = _this.dateToAry(date);
    _this.currentFirstYear = todayAry[0];
    _this.currentFirstMonth = todayAry[1];
}

xmoCalendar.prototype.reTableList = function(){
  var _this = this;
  var xmoCalendarList = _this.getDataTable();
  _this.xmoCalendarList.html(xmoCalendarList);
  _this.setMonth();
  _this.refreshDisabled();
}

// 周的选择
xmoCalendar.prototype.tipsAllWeekUnselect = function(index,element){
  var _this = this;
  var lang = _this.lang[_this.lang_opt];
  var tableEle = $(element).parents('table').first();
  var tableEleIndex = $('.xmoCalendarTableWraper table',_this.wrapperBox).index(tableEle);
  var headMsg = $('.xmoCalendarTitle tr td',_this.wrapperBox).eq(tableEleIndex).html();
  // 首先取消当前周的
  tableEle.find('tbody tr').each(function(){
    var target = $(this).find('td').eq(index);
    var target = target.find('a');
    if(target.length == 1){
      var date = target.attr('title');
      var isInrange = _this.isInRange(date);
      if(isInrange) delete _this.removed[date];
    }
  })
  _this.reTableList();
  var dateFrom = _this.dateFrom;
  var dateTo = _this.dateTo;
  var dateFromAry = _this.dateToAry(dateFrom);
  var dateToAry = _this.dateToAry(dateTo);
  var flag = true;
  var year = dateFromAry[0];
  var month = dateFromAry[1];
  var list = [];
  var len = 0;
  while(flag){
    if(month == 13){
      month = 01;
      year++;
    }
    if(year == dateToAry[0] && month == dateToAry[1]) flag = false;

    var monthData = _this.getMonthData(year,month);
    for (var i = 0; i < monthData.length; i++) {
      var weekData = monthData[i];
      var item = weekData[index];
      if(item.day > 0){
        var thisDay = item.year+ '-' + _this.pad(item.month,2)+ '-' + _this.pad(item.day,2);
        var isInrange = _this.isInRange(thisDay);
        var isRemoved = _this.removed[thisDay];
        if(isInrange && isRemoved){
          list.push(thisDay);
        }
      }
    };
    month = _this.pad(++month,2);
  }
  var tipStr = '<strong>' +  headMsg + ' ' + lang['aLongWeekStr'][index + 1] + lang['allWeekStrUnselect1'][0] + '</strong>';
  $('.xmoCalendarTableTips',_this.wrapperBox).html('').html(tipStr);
  if(list.length > 0){
    if(dateToAry[0] - dateFromAry[0] > 0 || dateToAry[1] - dateFromAry[1] > 0){
      $('.xmoCalendarTableTips',_this.wrapperBox).append('<br/>'+lang['allWeekStrUnselect1'][1] + lang['aLongWeekStr'][index + 1] + lang['allWeekStrUnselect1'][2]+'<span class="tipsAllWeekUnselect" index="'+ index +'">' + lang['yes'] + '</span>');
    }
    $('.tipsAllWeekUnselect',_this.wrapperBox).click(function(){
      $('.xmoCalendarTableTips',_this.wrapperBox).html('');
      for (var i = 0; i < list.length; i++) {
        var item = list[i];
        delete _this.removed[item]
      };
      _this.reTableList();
      return false;
    }).hover(function(){
      var index = $(this).attr('index');
      $('a.selected[week="'+ index +'"]',_this.wrapperBox).addClass('aHover');
      $('a.removed[week="'+ index +'"]',_this.wrapperBox).addClass('aHover');
    },function(){
      var index = $(this).attr('index');
      $('a.selected[week="'+ index +'"]',_this.wrapperBox).removeClass('aHover');
      $('a.removed[week="'+ index +'"]',_this.wrapperBox).removeClass('aHover');
    })
  }
}

// 周的取消
xmoCalendar.prototype.tipsAllWeekSelect = function(index,element){
  // 首先取消当前周的
  var _this = this;
  var lang = _this.lang[_this.lang_opt];
  var tableEle = $(element).parents('table').first();
  var tableEleIndex = $('.xmoCalendarTableWraper table',_this.wrapperBox).index(tableEle);
  var headMsg = $('.xmoCalendarTitle tr td',_this.wrapperBox).eq(tableEleIndex).html();
  tableEle.find('tbody tr').each(function(){
    var target = $(this).find('td').eq(index);
    var target = target.find('a');
    if(target.length == 1){
      var date = target.attr('title');
      var isInrange = _this.isInRange(date);
      if(isInrange) _this.removed[date] = true;
    }
  })
  _this.reTableList();
  // 然后取消询问是否取消其它周的
  var tipStr = '<strong>' +  headMsg + ' ' + lang['aLongWeekStr'][index + 1] + lang['allWeekStr1'][0] + '</strong>';
  var len = 0;
  var dateFrom = _this.dateFrom;
  var dateTo = _this.dateTo;
  var dateFromAry = _this.dateToAry(dateFrom);
  var dateToAry = _this.dateToAry(dateTo);

  var flag = true;
  var year = dateFromAry[0];
  var month = dateFromAry[1];
  var list = [];
  while(flag){
    if(month == 13){
      month = 01;
      year++;
    }
    if(year == dateToAry[0]&&month == dateToAry[1]) flag = false;
    var monthData = _this.getMonthData(year,month);
    for (var i = 0; i < monthData.length; i++) {
      var weekData = monthData[i];
      var item = weekData[index];
      if(item.day > 0){
        var thisDay = item.year+ '-' + _this.pad(item.month,2)+ '-' + _this.pad(item.day,2);
        var isInrange = _this.isInRange(thisDay);
        var isRemoved = _this.removed[thisDay];
        if(isInrange && !isRemoved){
          list.push(thisDay);
        }
      }
    };
    month = _this.pad(++month,2);
  }
  $('.xmoCalendarTableTips',_this.wrapperBox).html('').html(tipStr);
  if(list.length > 1){
    if(dateToAry[0] - dateFromAry[0] > 0 || dateToAry[1] - dateFromAry[1] > 0){
      $('.xmoCalendarTableTips',_this.wrapperBox).append('<br/>'+lang['allWeekStr1'][1] + lang['aLongWeekStr'][index + 1] + lang['allWeekStr1'][2]+'<span class="tipsAllWeekSelect" index="'+ index +'">' + lang['yes'] + '</span>');
    }
    $('#' + _this.boxId + ' .tipsAllWeekSelect').click(function(){
      for (var i = 0; i < list.length; i++) {
        var item = list[i];
        _this.removed[item] = true;
      };
    $('.xmoCalendarTableTips',_this.wrapperBox).html('')
      _this.reTableList();
      return false;
    }).hover(function(){
      var index = $(this).attr('index');
      $('a.selected[week="'+ index +'"]',_this.wrapperBox).addClass('aHover');
      $('a.removed[week="'+ index +'"]',_this.wrapperBox).addClass('aHover');
    },function(){
      var index = $(this).attr('index');
      $('a.selected[week="'+ index +'"]',_this.wrapperBox).removeClass('aHover');
      $('a.removed[week="'+ index +'"]',_this.wrapperBox).removeClass('aHover');
    })
  }
}

xmoCalendar.prototype.addZero = function(date){
  return this.dateToAry(date).join('-');
}

xmoCalendar.prototype.tipsSelectOneDayInEveryMonth = function(date,weekIndex){
  var _this = this;
  var lang = _this.lang[_this.lang_opt];
  var index = weekIndex;
  // 如果在已经选择的日子中 存在多个这样的 没有被删除的日子 那么就显示提示
  var len = 0;
  var dateFrom = _this.dateFrom;
  var dateTo = _this.dateTo;
  var dateFromAry = _this.dateToAry(dateFrom);
  var dateToAry = _this.dateToAry(dateTo);
  var dateAry = _this.dateToAry(date);
  var tipStr = '<strong>' + _this.dateFormatToShow(date) + lang['allWeekStrUnselect1'][0] + '</strong>';
  //var tipStr = '<strong>'+ lang['allWeekStrUnselect'][0] + ' ' + date +lang['period'] +  '</strong>';
  var day = dateAry[2];
  var flag = true;
  var year = dateFromAry[0];
  var month = dateFromAry[1];
  var list = [];
  while(flag){
    if(month == 13){
      month = 01;
      year++;
    }
    if(year == dateToAry[0] && month == dateToAry[1]) flag = false;

    var monthData = _this.getMonthData(year,month);
    for (var i = 0; i < monthData.length; i++) {
      var weekData = monthData[i];
      var item = weekData[index];
      if(item.day > 0){
        var thisDay = item.year+ '-' + _this.pad(item.month,2)+ '-' + _this.pad(item.day,2);
        var isInrange = _this.isInRange(thisDay);
        var isRemoved = _this.removed[thisDay];
        if(isInrange && isRemoved){
          list.push(thisDay);
        }
      }
    };
    month = _this.pad(++month,2);
  }
  $('.xmoCalendarTableTips',_this.wrapperBox).html('').html(tipStr);
  if(list.length > 1){
    if(dateToAry[0] - dateFromAry[0] > 0 || dateToAry[1] - dateFromAry[1] > 0){
      $('.xmoCalendarTableTips',_this.wrapperBox).append('<br/>'+lang['allWeekStrUnselect1'][1] + lang['aLongWeekStr'][weekIndex + 1] + lang['allWeekStr1'][2]+'<span class="tipsAllWeekUnselect" index="'+ weekIndex +'">' + lang['yes'] + '</span>');
    }
    $('.tipsAllWeekUnselect',_this.wrapperBox).click(function(){
      $('.xmoCalendarTableTips',_this.wrapperBox).html('');
      for (var i = 0; i < list.length; i++) {
        var item = list[i];
        delete _this.removed[item]
      };
      _this.updateRemoved();
      _this.reTableList();
      return false;
    }).hover(function(){
      var index = $(this).attr('index');
      $('a.selected[week="'+ index +'"]',_this.wrapperBox).addClass('aHover');
      $('a.removed[week="'+ index +'"]',_this.wrapperBox).addClass('aHover');
    },function(){
      var index = $(this).attr('index');
      $('a.selected[week="'+ index +'"]',_this.wrapperBox).removeClass('aHover');
      $('a.removed[week="'+ index +'"]',_this.wrapperBox).removeClass('aHover');
    })
  }
  // if(len.length > 1){
  //   $('.xmoCalendarTableTips',_this.wrapperBox).html(tipStr);
  // }
  // $('.tipsSelectOneDayInEveryMonth',_this.wrapperBox).click(function(){
  //   for (var i = 0; i < list.length; i++) {
  //     var item = list[i];
  //     item = _this.addZero(item);
  //     delete _this.removed[item];
  //   };
  //   $('.xmoCalendarTableTips',_this.wrapperBox).html('')
  //   _this.reTableList();
  //   return false;
  // }).hover(function(){
  //   var day = $(this).attr('day');
  //   $('a.selected[day="'+ day +'"]',_this.wrapperBox).addClass('aHover');
  //   $('a.removed[day="'+ day +'"]',_this.wrapperBox).addClass('aHover');
  // },function(){
  //   var day = $(this).attr('day');
  //   $('a.selected[day="'+ day +'"]',_this.wrapperBox).removeClass('aHover');
  //   $('a.removed[day="'+ day +'"]',_this.wrapperBox).removeClass('aHover');
  // })
}
xmoCalendar.prototype.dateFormatToShow =  function(date,week){
  var _this = this;
  var lang = _this.lang[_this.lang_opt];
  var dateAry = _this.dateToAry(date);
  var monthIndex = parseInt((dateAry[1]),10)-1;
  if(_this.lang_opt == 'EN'){
      return lang['aLongMonStr'][monthIndex] + ' ' + dateAry[2] + ', '+ dateAry[0];
  }
  if(_this.lang_opt == 'CN'){

      return dateAry[0] + '年' + dateAry[1] + '月' + dateAry[2] + '日';
  }
}
Date.prototype.dateFormatNew = function (fmt) {
  var o = {
    "M+": this.getMonth() + 1, //月份
    "d+": this.getDate(), //日
    "h+": this.getHours(), //小时
    "m+": this.getMinutes(), //分
    "s+": this.getSeconds(), //秒
    "q+": Math.floor((this.getMonth() + 3) / 3), //季度
    "S": this.getMilliseconds() //毫秒
  };
  if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
  for (var k in o)
    if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
  return fmt;
}

xmoCalendar.prototype.tipsExcludeOneDayInEveryMonth = function(date,weekIndex){
  var _this = this;
  var lang = _this.lang[_this.lang_opt];
  // 如果在已经选择的日子中 存在多个这样的 没有被删除的日子 那么就显示提示
  var len = 0;
  var dateFrom = _this.dateFrom;
  var dateTo = _this.dateTo;
  var dateFromAry = _this.dateToAry(dateFrom);
  var dateToAry = _this.dateToAry(dateTo);
  var dateAry = _this.dateToAry(date);

  var tipStr = '<strong>' + _this.dateFormatToShow(date) + lang['allWeekStr1'][0] + '</strong>';
  var day = dateAry[2];

  var index = weekIndex;
  var flag = true;
  var year = dateFromAry[0];
  var month = dateFromAry[1];
  var list = [];
  while(flag){
    if(month == 13){
      month = 01;
      year++;
    }
    if(year == dateToAry[0]&&month == dateToAry[1]) flag = false;
    var monthData = _this.getMonthData(year,month);
    for (var i = 0; i < monthData.length; i++) {
      var weekData = monthData[i];
      var item = weekData[index];
      if(item.day > 0){
        var thisDay = item.year+ '-' + _this.pad(item.month,2)+ '-' + _this.pad(item.day,2);
        var isInrange = _this.isInRange(thisDay);
        var isRemoved = _this.removed[thisDay];
        if(isInrange && !isRemoved){
          list.push(thisDay);
        }
      }
    };
    month = _this.pad(++month,2);
  }
  $('.xmoCalendarTableTips',_this.wrapperBox).html('').html(tipStr);

  if(list.length > 1){
    if(dateToAry[0] - dateFromAry[0] > 0 || dateToAry[1] - dateFromAry[1] > 0){
      $('.xmoCalendarTableTips',_this.wrapperBox).append('<br/>'+lang['allWeekStr1'][1] + lang['aLongWeekStr'][weekIndex + 1] + lang['allWeekStr1'][2]+'<span class="tipsAllWeekSelect" index="'+ weekIndex +'">' + lang['yes'] + '</span>');
    }
    $('#' + _this.boxId + ' .tipsAllWeekSelect').click(function(){
      for (var i = 0; i < list.length; i++) {
        var item = list[i];
        _this.removed[item] = true;
      };
    $('.xmoCalendarTableTips',_this.wrapperBox).html('')
      _this.reTableList();
      return false;
    }).hover(function(){
      var index = $(this).attr('index');
      $('a.selected[week="'+ index +'"]',_this.wrapperBox).addClass('aHover');
      $('a.removed[week="'+ index +'"]',_this.wrapperBox).addClass('aHover');
    },function(){
      var index = $(this).attr('index');
      $('a.selected[week="'+ index +'"]',_this.wrapperBox).removeClass('aHover');
      $('a.removed[week="'+ index +'"]',_this.wrapperBox).removeClass('aHover');
    })
  }

  // var flag = true;
  // var year = dateFromAry[0];
  // var month = dateFromAry[1];
  // var list = [];
  // while(flag){
  //   if(month == 13){
  //     month = 1;
  //     year++;
  //   }
  //   if(year == dateToAry[0] && month == dateToAry[1]) flag = false;
  //   var dateTest = [year,month,day].join('-');
  //   var isInrange = _this.isInRange(dateTest);
  //   var isRemoved = _this.removed[dateTest];
  //   var isExist = _this.checkDateExist(dateTest);
  //   if(isInrange && !isRemoved && isExist){
  //     len++
  //     list.push(dateTest);
  //   }
  //   month = _this.pad(++month,2);
  // }
  // if(len > 1){
  //   $('.xmoCalendarTableTips',_this.wrapperBox).html(tipStr);
  // }
  // $('.tipsExcludeOneDayInEveryMonth',_this.wrapperBox).click(function(){
  //   for (var i = 0; i < list.length; i++) {
  //     var item = list[i];
  //     item = _this.addZero(item);
  //     _this.removed[item] = true;
  //   };
  //   $('.xmoCalendarTableTips',_this.wrapperBox).html('')
  //   _this.reTableList();
  //   return false;
  // }).hover(function(){
  //   var day = $(this).attr('day');
  //   $('a.selected[day="'+ day +'"]',_this.wrapperBox).addClass('aHover');
  //   $('a.removed[day="'+ day +'"]',_this.wrapperBox).addClass('aHover');
  // },function(){
  //   var day = $(this).attr('day');
  //   $('a.selected[day="'+ day +'"]',_this.wrapperBox).removeClass('aHover');
  //   $('a.removed[day="'+ day +'"]',_this.wrapperBox).removeClass('aHover');
  // })
}
/*
  自动补零
  pad(100, 4);  // 输出：0100  
*/
xmoCalendar.prototype.pad = function(num) {
  var n = parseInt((num),10);
  if(n < 10) n = '0' + n;
  return n;
}
/*
*检查From 和 To日期
*
*
*/ 
xmoCalendar.prototype.checkDate = function(date,type) {
  var _this = this;
  var lang = _this.lang[_this.lang_opt];

  if(type == 'from'){
    if(_this.dateTo == '' || date == _this.dateTo) return true
    var isInrange = _this.isInRange(date,'1977-01-01',_this.dateTo);
    if(!isInrange){
      // _this.errorTip(lang['err_1']);
      _this.dateTo = '';
      _this.removed = {};
      $('.xmoCalendarMainHead .xmoCalendarTo',_this.wrapperBox).val('');
      _this.updateRemoved();
      return true;
    }
  }else if(type == 'to'){
    if(_this.dateFrom == '' ||  date == _this.dateFrom) return true
    var isInrange = _this.isInRange(date,'1977-01-01',_this.dateFrom);
    if(isInrange){
      _this.errorTip(lang['err_2']);
      return false;
    }
  }
  return true;
}

xmoCalendar.prototype.checkDateFoot = function(date,type) {
  var _this = this;
  var lang = _this.lang[_this.lang_opt];

  if(type == 'from'){
    if(_this.compareTo == '' || date == _this.compareTo) return true;
    var isInrange = _this.isInRange(date,'1977-01-01',_this.compareTo);
    if(!isInrange){
      _this.compareTo = '';
      $('.xmoCalendarMainFoot .xmoCalendarTo',_this.wrapperBox).val('');
      return true;
    }
  }else if(type == 'to'){
    if(_this.compareFrom == '' ||  date == _this.compareFrom) return true
    var isInrange = _this.isInRange(date,'1977-01-01',_this.compareFrom);
    if(isInrange){
      _this.errorTip(lang['err_2']);
      return false;
    }
  }
  return true;
}

xmoCalendar.prototype.focusCheck = function(){
  var _this = this;
  var dateFrom = $('.xmoCalendarMainHead .xmoCalendarFrom',_this.wrapperBox);
  var dateTo = $('.xmoCalendarMainHead .xmoCalendarTo',_this.wrapperBox);
  if(dateFrom.val().length == 0){
    dateFrom[0].focus();
    return false;
  }
  if(dateTo.val().length == 0){
    dateTo[0].focus();
    return false;
  }
  // input to
  if(dateFrom.val().length > 0 && dateTo.val().length > 0){
    _this.selecteOver();
  }else{
    _this.selecting();
  }
}
xmoCalendar.prototype.focusCheckFoot = function(){
  var _this = this;
  var dateFrom = $('.xmoCalendarMainFoot .xmoCalendarFrom',_this.wrapperBox);
  var dateTo = $('.xmoCalendarMainFoot .xmoCalendarTo',_this.wrapperBox);
  if(dateFrom.val().length == 0){
    dateFrom[0].focus();
    return false;
  }
  if(dateTo.val().length == 0){
    dateTo[0].focus();
    return false;
  }
  _this.wrapperBox.removeClass('inputingBox');
  $('.xmoCalendarMainFoot .inputing',_this.wrapperBox).removeClass('inputing');
}

xmoCalendar.prototype.dateToAry = function(date){
  if(typeof(date)==="string" && date.indexOf("-")>-1){
    date = new Date((date).replace(/-/g, '/'));
  }
  var _this = this,dateNow = new Date(date);
  var date = [dateNow.getFullYear(),dateNow.getMonth() + 1,dateNow.getDate()];

  for(var i = 1; i < 3; i++){
    if(date[i] < 10) date[i] = _this.pad(date[i],2);
  }
//  console.log(date);
  return date;
}

xmoCalendar.prototype.isInRange = function(date,start,end){
  var _this = this;
  var dateFrom = start || _this.dateFrom;
  var dateTo = end || _this.dateTo;
  if(typeof(dateFrom)==="string" && dateFrom.indexOf("-")>-1){
    dateFrom = new Date((dateFrom).replace(/-/g, '/'));
  }
  if(typeof(date)==="string" && date.indexOf("-")>-1){
    date = new Date((date).replace(/-/g, '/'));
  }
  if(typeof(dateTo)==="string" && dateTo.indexOf("-")>-1){
    dateTo = new Date((dateTo).replace(/-/g, '/'));
  }
  var millisecondsFrom = new Date(dateFrom).getTime();
  var millisecondsTo = new Date(dateTo).getTime();
  var milliseconds = new Date(date).getTime();
 // console.log(dateFrom+"@@"+dateTo+"!!"+date+"$$");
  if(milliseconds <= millisecondsTo&&millisecondsFrom <= milliseconds) return true;
  return false;
}

xmoCalendar.prototype.btnLeftFunc = function(){
  var _this = this;
  var year =   _this.currentFirstYear;
  var month =  parseInt((_this.currentFirstMonth),10);
  _this.focusCheck();
  if(month -3 <= 0){
    month = month + 9;
    year -= 1;
  }else{
    month -= 3;
  }
  var xmoCalendarList = _this.getDataTable(year,month);
  _this.xmoCalendarList.html(xmoCalendarList);
  _this.wrapperBox.show();
  _this.setMonth();
  _this.refreshDisabled();
}

xmoCalendar.prototype.btnRightFunc = function(){
  var _this = this;
  var year =   _this.currentFirstYear;
  var month =  parseInt((_this.currentFirstMonth),10);
  _this.focusCheck();
  if(month + 3 > 12){
    month = month - 9;
    year += 1;
  }else{
    month += 3;
  }
  var xmoCalendarList = _this.getDataTable(year,month);
  _this.xmoCalendarList.html(xmoCalendarList);
  _this.wrapperBox.show();
  _this.setMonth();
  _this.refreshDisabled();
}

/*
  改变月份显示 和 左右按钮的显示
*/ 
xmoCalendar.prototype.setMonth = function(){
  var _this = this;
  $('#' + _this.boxId + ' .xmoCalendarMonth').each(function(index,ele){
    $(ele).html(_this.monthAry[index]);
  })
}

/*
  把删除的日期值添加到隐藏的input中
*/ 
xmoCalendar.prototype.updateRemoved = function(addToInput){
    var _this = this;
    var removedAry = [];
    for(var i in _this.removed){
      var isInRange = _this.isInRange(i);
      if(i.length > 0 && isInRange){
        removedAry.push(i);
      }else{
        delete _this.removed[i];
      }
    }
    for(var i in _this.disabledJs){
      var isInRange = _this.isInRange(i);
      if(i.length > 0 && isInRange){
        removedAry.push(i);
      }else{
        delete _this.removed[i];
      }
    }
    if(addToInput){
      _this.exclude_dates_obj.val(removedAry.join(','));
    }
}

xmoCalendar.prototype.getDataTable = function(year,month){
  var _this = this;
  var lang = _this.lang[_this.lang_opt];

  var year = parseInt((year || _this.currentFirstYear),10);
  var month = parseInt((month || _this.currentFirstMonth),10);

  var html = '';
  var tableHead = '<thead><tr><th><a href="javascript:void(0);" index="0">'+ lang['aWeekStr'][1] +'</a></th><th><a href="javascript:void(0);" index="1">'+ lang['aWeekStr'][2] +'</a></th><th><a href="javascript:void(0);" index="2">'+ lang['aWeekStr'][3] +'</a></th><th><a href="javascript:void(0);" index="3">'+ lang['aWeekStr'][4] +'</a></th><th><a href="javascript:void(0);" index="4">'+ lang['aWeekStr'][5] +'</a></th><th><a href="javascript:void(0);" index="5">'+ lang['aWeekStr'][6] +'</a></th><th><a href="javascript:void(0);" index="6">'+lang['aWeekStr'][7] +'</a></th></tr></thead>';
  for (var k = 0; k < 3; k++) {
    var tableData = _this.getMonthData(year,month);
    var table = '<div class="xmoCalendarTableWraper"><table class="xmoCalendarTable">'
    if(k == 2){
      table = '<div class="xmoCalendarTableWraper xmoCalendarTableWraperLast"><table class="xmoCalendarTable">';
    }
    if(k == 0){
      _this.currentFirstYear = year;
      _this.currentFirstMonth = month;

    }
    var tbody = '<tbody>';
    table += tableHead;
    if(_this.lang_opt == 'CN'){
       _this.monthAry[k] = year + '年  '+ _this.pad(month,2) + '月';
    }else{
       _this.monthAry[k] = lang['aLongMonStr'][month-1] + '&nbsp;' + year
    }
    if(month == 12){
      month = 01;
      year++;
    }else{
      month = _this.pad(++month,2)
    }
      // 拼出每周的
    for (var i = 0; i < 6; i++) {
      var tr = '<tr>';
      var weekAry = tableData[i];
      if(weekAry == undefined){
        weekAry = [{day:0},{day:0},{day:0},{day:0},{day:0},{day:0},{day:0}]
      }
      for (var j = 0; j < weekAry.length; j++) {
        var item = weekAry[j];
        var aClass = '';
        if(item.day == 0){
          tr += '<td>&nbsp;</td>';
        }else{
          var thisDay = item.year+ '-' + _this.pad(item.month,2)+ '-' + _this.pad(item.day,2);

          if(_this.today == thisDay) aClass = 'today';
          if(_this.selectedDone){
            var isInRange = _this.isInRange(thisDay);
            if(isInRange){
              aClass = 'selected ';
            }
          }else{
            if(thisDay == _this.dateFrom || thisDay == _this.dateTo) aClass = 'selected'
            
            if(thisDay == $('.xmoCalendarMainHead .xmoCalendarFrom',_this.wrapperBox).val() || (_this.type == 'OnlySelectDate' && thisDay == _this.dateFrom)) aClass = 'justSelected'
          }
          var canBeSelect = _this.isInRange(thisDay,_this.startTime.join('-'),_this.endTime.join('-'));
          if(!canBeSelect){
            aClass = 'disabled';
          }
          
          if(_this.removed[thisDay]) aClass = 'removed';
          if(_this.type == 'CompositeAll' && _this.compareCheckbox){
              var isInCompareRange = _this.isInRange(thisDay,_this.compareFrom ,_this.compareTo);
              if(isInCompareRange){
                aClass = 'compare';
              }
              if(_this.selectedDone && _this.isInRange(thisDay) && isInCompareRange){
                aClass = 'compareAndSelected';
              }
          }
          
          tr += '<td><a href="javascript:void(0);" class="'+ aClass +'" week="'+ j +'"  day="'+ _this.pad(item.day,2) +'" title="'+ thisDay +'">'+ item.day +'</a></td>';

        }
      };
      tr += '</tr>';
      tbody += tr;
    };
    tbody += '</tbody>';
    table += tbody + '</table></div>';
    html += table;
  }
  html += '<div class="cle"></div>';
  // $('.xmoCalendarList').html(html + '<div class="cle"></div>');
  return html;
}

/*
月 +1之后的月份
*/ 
xmoCalendar.prototype.getMonthData = function(year,month){
    var _this = this;
    var data = [];
    var tempYear = new Date(year, month-1, 1);
    var daily = 0;
    var startDay = tempYear.getDay();// 从 Date 对象返回一周中的某一天 (0 ~ 6)。  周日为0
    // 本月共有多少天
    var intDaysInMonth = _this.getDaysInMonth( month-1,year);
     // 共有几周
    var weeks = (intDaysInMonth + startDay) % 7 == 0 ? (intDaysInMonth + startDay) / 7 : parseInt(((intDaysInMonth + startDay) / 7),10) + 1;
    for (var intWeek = 1; intWeek <= weeks; intWeek++) {
      var weekData = []
      for (var intDay = 0; intDay < 7; intDay++) {
        var dayObj = {};
        if ((intDay == startDay) && (0 == daily)) daily = 1;
          dayObj.year = year;
          dayObj.month = month;
        if ((daily > 0) && (daily <= intDaysInMonth)) {
          dayObj.day = daily;
          daily++;
        } else {
          dayObj.day = 0;
        }
        weekData.push(dayObj);
      }
      data.push(weekData);
     }
     return data;
}

/*
  获取一个月有多少天
*/ 
xmoCalendar.prototype.getDaysInMonth = function(month, year){
  var daysInMonth = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  var _this = this;
  if (1 == month) return ((0 == year % 4) && (0 != (year % 100))) || (0 == year % 400) ? 29 : 28;
  else return daysInMonth[month];
}
/*
  将指定范围日期disable
*/
xmoCalendar.prototype.refreshDisabled = function(){
  var _this = this;
  if(_this.disabledDate.length>0){
    //console.log(_this.disabledDate);
    $(_this.xmoCalendarList).find(".xmoCalendarTable td a").each(function(){
      var thisDay = $(this).attr("title");
      for (var i = 0; i < _this.disabledDate.length; i++) {
        if(_this.disabledDate[i].indexOf(" ~ ")>-1){
          var canNotbeSelect = _this.isInRange(thisDay,_this.disabledDate[i].split(" ~ ")[0],_this.disabledDate[i].split(" ~ ")[1]);
          if (canNotbeSelect) {
            _this.disabledJs[thisDay]=true;
            $(this).attr("class","disabled");
          };
        }else if(_this.disabledDate[i]!=""){
            var canNotbeSelect = _this.isInRange(thisDay,_this.disabledDate[i],_this.disabledDate[i]);
            if (canNotbeSelect) {
              _this.disabledJs[thisDay]=true;
              $(this).attr("class","disabled");
            };
        }
      };
    })
  }
}
xmoCalendar.prototype.lang = {
  'CN' : {
      errAlertMsg: "选择时间超出范围，是否继续？",
      aWeekStr: ["周", "日", "一", "二", "三", "四", "五", "六"],
      aLongWeekStr:["周", "周日", "周一", "周二", "周三", "周四", "周五", "周六"],
      aMonStr: ["一","二","三","四","五","六","七","八","九","十","十一","十二"],
      aLongMonStr: ["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"],
      clearStr: "清除",
      today: "今天",
      okStr: "好",
      CompareTo:'对比',
      this_week : '本周',
      none : '不选',
      this_month : '本月',
      this_yeah : '今年',
      last_7_days : '最近7天',
      last_30_days : '最近30天',
      last_week : '上周',
      last_month : '上月',
      last_3_month : '最近三个月',
      last_12_month : '最近12个月',
      last_month : '上月',
      previous : '之前的',
      updateStr: "好",
      timeStr: "时间",
      quickStr: "快速选择",
      err_1: '开始日期不能大于结束日期',
      err_2: '结束日期不能小于开始日期',
      range : '日期范围',
      from:'从',
      to:'到',
      submit : '提交',
      yes : '是',
      allWeekStr : ['您已经取消了','是否要取消选择其它月份的','号?'],
      allWeekStr1 : [' 已經取消。','您是否要取消所有月份的','?'],
      allWeekStrUnselect : ['您已经选择了','是否要选择其它月份的','号?'],
      allWeekStrUnselect1 : [' 已经选择','是否要选择其它月份的','?'],
      everyMonthStr : '',
      dateFormatUncorrect : '日期格式不正确',
      period : '。'
  },
  'EN' : {
      errAlertMsg: "Invalid date or the date out of range,redo or not?",
      aWeekStr: ["wk", "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"],
      aLongWeekStr:["wk","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"],
      aMonStr: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
      aLongMonStr: ["January","February","March","April","May","June","July","August","September","October","November","December"],
      clearStr: "Clear",
      today: "Today",
      okStr: "OK",
      CompareTo:'Compare to',
      previous : 'previous',
      none : 'NONE',
      last_7_days : 'Last 7 Days',
      last_30_days : 'Last 30 Days',
      this_week : 'This Week',
      this_month : 'This Month',
      this_yeah : 'This Year',
      last_week : 'Last Week',
      last_month : 'Last Month',
      last_3_month : 'Last 3 Months',
      last_12_month : 'Last 12 Months',
      last_month : 'Last Month',

      updateStr: "OK",
      timeStr: "Time",
      quickStr: "Quick Selection",
      err_1: 'Start date cannot be greater than end date',
      err_2: 'End date cannot be less than start date',
      range : 'Date Range',
      from:'From',
      to:'To',
      submit : 'Submit',
      yes : 'Yes',
      allWeekStr : ['You have excluded','Would you like to exclude ','th in every month?'],
      allWeekStr1 : [' is excluded.','Would you like to exclude ',' in every month?'],
      allWeekStrUnselect : ['You have selected','Would you like to select ','th in every month?'],
      allWeekStrUnselect1 : [' is selected','Would you like to select ','in every month?'],
      everyMonthStr : ' in every month',
      dateFormatUncorrect : 'Date format is not correct',
      period : '.'
  }
}
