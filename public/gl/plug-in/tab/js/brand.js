var XMO_Band = {
  color : ['#ebcab8','#ebbda9','#f5a590','#e84427','#851e00','#5f1500','#ebcab8','#ebbda9','#f5a590','#e84427','#851e00','#5f1500','#ebcab8','#ebbda9','#f5a590','#e84427','#851e00','#5f1500'],
  init : function(){
      this.bind();
      // bubble_init(ajax_data);
  },
  getData : function(){
    $.ajax({
      url :'',
      success : function(_ajax_data){
        bubble_init(_ajax_data);
      }
    })
  },
  initTab : function(data,_num){
    if(!data)return;
    var num = _num || 6;
    this.initGender(data.gender.f,data.gender.m);
    this.initInterest(data.interst,'#interests-content');
    this.initAgeGroup(data.age_group);
    this.initLocation(data.location,num);
    this.initDevice(data.device);
  },
  bind : function(){
      $('.xtb-nav-list li[data-toggle="tab"]').on('shown', function (e) {
          $('.xtb-nav-list li').removeClass('active');
          $(this).addClass('active');
      })
  },
  initAgeGroup : function(_data){
      var data = [];
      var total = 0;
      var colors = ['#662600','#d45c3a','#e48b61','#e7b4a1','#e5bfb6','#e6c9b7'];
      function getColorIndex(value){
          var index = 0;
          for(var i in _data){
            if(value<_data[i])index++;
          }
          return index;
      }
      for(var i in _data){
        total += _data[i];
      }
      for(var i in _data){
        var per = _data[i]/total;
        if(isNaN(per))per=0;
        data.push({
          name : i,
          per : per,
          color : colors[getColorIndex(_data[i])]
        })
      }
      this.perBar(data,'#age-content',true);
  },
  initLocation : function(_data,max){
      var data = [];
      var total = 0;
      var index = 0;
      var colors = ['#662600','#7d2904','#d45c3a','#e56422','#e48b61','#e49577','#e7b4a1','#e5bfb6','#e6c9b7','#e8cebd'];
      function getColorIndex(value){
          var index = 0;
          for(var i in _data){
            // console.info(value<_data[i]['value'])
            if(value<_data[i]['value'])index++;
          }
          return index;
      }
      for(var i in _data){
        total += _data[i]['value'];
      }
      for(var i in _data){
        if(index < max){
          var per = _data[i]['value']/total
          if(isNaN(per))per=0;
          data.push({
            name : _data[i]['name'],
            per : per,
            color : colors[getColorIndex(_data[i]['value'])]
          })
        }
        index++;
      }
      this.perLine(data,'#location-content');
      var len1 = $('.brand-box #location-content .line_per_new').length;
      var len2 = $('.tab-content #location-content .line_per_new').length;
      if(len1 <= 10&&len1 > 1){
        $('#location-content').css({'margin-top':(10-len1)*30});
      }
      if(len2 <= 6&&len2 > 1){
        $('#location-content').css({'margin-top':(6-len2)*30});
      }
  },
  initGender : function (_male,_female) {
      male = _male.value || 0;
      female = _female.value || 0;
      var isZero = false;
      var type1 = 'ae';
      var type2 = 'dn';
      $("#gender-content").html('');
      var w = 390;
      var total = male+female;
      var per_male = parseInt(100*male/total);
      if(isNaN(per_male))per_male=0;
      var per_female = 100-per_male;
      if(total == 0){
        total = 2;
        per_female = per_male = 1;
        isZero = true;
        type1 = type2 = 'zero'
      }
      var data = [
        {name: _male.name, val:per_male , type: type1},
        {name: _female.name, val: per_female, type: type2}
      ];
      donut_chart(w,w,"#gender-content",data,isZero);
  },
  initDevice : function (_data_device) {
    var data_device = [];
    data_device[0] = _data_device['PC'] || 0;
    data_device[1] = _data_device['Tablet'] || 0;
    data_device[2] = _data_device['Mobile'] || 0;
    var total = 0;
    var data = brand_config.device;
    for (var i = 0; i<data_device.length;i++) {
      var item = data_device[i];
      total += item;
    };
    var colors = ['#662600','#d45c3a','#e48b61'];
    function getColorIndex(value){
        var index = 0;
        for (var i = 0; i<data_device.length;i++){
          if(value<data_device[i])index++;
        }
        return index;
    }
    for (var i = 0; i<data_device.length;i++) {
        var item = data_device[i];
        data[i]["color"] = colors[getColorIndex(item)];
        data[i]["per"] = item/total
        if(isNaN(data[i]["per"]))data[i]["per"]=0;
    };
    this.perBar(data,'#device-content',true);
  },
  initInterest : function(_data,id){
        var colors = ['#851e00','#e84427','#f5a590','#ebbda9','#ebcab8','#ebcab8','#ebcab8'];
        var data = [];
        var total_per = 0;
        var total = 0,max = 0;
        for(var i in _data){
          var item = _data[i];
          total += item.value;
          if(item.value > max) max = item.value;
        }
        for(var i in _data){
          var item = _data[i];
          item.value2 = (100*item['value']/total).toFixed(1)
          if(isNaN(item.value2))item.value2=0;
          data.push(item)
        }
        $(id).html('<div id="canvas_area"><span class="chartwell radar"></span></div>');
        var html = '<span style="color: #b8b7bc">d</span>';
        var html2 = '';
        $(id + ' .data_item').remove();
        for (var i = 0; i < data.length; i++) {
          var item = data[i];
          var showV = parseInt(100*item.value/max);
          showV = isNaN(showV) ? 0 : showV;
          if(i == data.length - 1){
            item.value2 = (100-total_per).toFixed(1);
          }else{
            total_per -= -item.value2;
          }
          html += '<span style="color: '+colors[i]+'">'+showV+'</span>';
          html2 +='<div class="data_item" id="data_item_'+ (i+1) +'">'+ item.name +'<br/><p>'+ item.value2 +'%</p></div>';
        };
        $(id).attr('class','pre_box_con')
        var length = data.length;
        $(id).addClass('data_'+length);
        $(id + ' #canvas_area .chartwell').html(html);
        FFChartwell();
        $(id + ' #canvas_area').append(html2);
    },
    perBar : function(dataAry,id,lastDeal){
        $box = $(id).html('');
        var total_per = 0;
        for(var i = 0; i < dataAry.length; i++){
            var item = dataAry[i],
                color = item.color||'#999',
                per = (item.per*100).toFixed(1);
            if(per != 0&&i==dataAry.length-1&&lastDeal){
               per = (100-total_per).toFixed(1);
            }
            total_per -= -per;
            var html = $('<div class="bar_per"><span class="name">'+ item.name +'</span> <span class="bar_main"><div class="bar_bg"></div><div class="bar_content">'+per+'%<i></i></span></div></div>');
            $box.append(html);
            html.find('i').css({
              background : color,
              height : parseFloat(item.per) * 214,
              background : color
            });
        }
    },
    perLine : function(dataAry,id,lastDeal){
        $box = $(id).html('');
        var total_per = 0;
        for(var i = 0; i < dataAry.length; i++){
            var item = dataAry[i],
                color = item.color,
                per = (item.per*100).toFixed(1);
            if(per != 0&&i==dataAry.length-1&&lastDeal){
               per = (100-total_per).toFixed(1);
            }
            total_per -= -per;
            var html = $('<div class="line_per line_per_new"><span class="name pull-left">'+ item.name +'</span><span class="line-bg"></span> <span class="pull-right"><span>'+per+'%</span><i></i></span></div>');
            $box.append(html);
            html.find('i').css({
              background : color,
              width : parseFloat(item.per) * $('.line_per_new .line-bg').width(),
              background : color
            });
        }
     }
}
$(function(){
  XMO_Band.init();
})