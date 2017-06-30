 var bshare = bshare || {};
//排除直辖市 、港澳台，地区所属城市所有选中才算选中
 (function(BS) {
    BS.Ncity = function(option) {
        var self = this,
            temp = "";
        this.settings = $.extend({

        }, option || {});
        self.container = option.container;
        self.lang = option.lang || "ch";
        self.china = option.china;
        self.foreign = option.foreign;
        self.result = option.result;
        self.tempForeign="";
        self.foreignData=[];
        self.callback=option.callback;
        self.count = 0;//键盘次数方向键

        if (self.china) {
            self.convertChina(self.china,self.lang,this);
        };
        
        
        self.langs={'tip_en':'You Have Selected','tip_ch':'您已经选中','search_en':'Search','search_ch':'搜索','selected_en':'City(ies) / Country(ies)','selected_ch':'个城市 / 海外国家','china_en':'China','china_ch':'中国','foreign_en':'Overseas','foreign_ch':'海外','Unselecte_en':'Invert','Unselecte_ch':'反选','clear_en':'Clear','clear_ch':'清空','one_en':'First-tier City','one_ch':'一线城市','two_en':'Second-tier City','two_ch':'二线城市','three_en':'Third-tier City','three_ch':'三线城市','four_en':'Fourth-tier City','four_ch':'四线城市'};

        this.dom = $('<div class="cityDomNew"></div>').appendTo(self.container);
        this.citys=[];
        this.foreginCitys=[];  
        //创建头部
        temp='<div class="cityArea" style="padding-left: 10px;height:30px;">';
        temp=temp+'<ul class="cityAreaCon" >';
        temp=temp+'<li >'  ;
        temp=temp+'<label>'+self.langs["tip_"+self.lang]+'<span class="allSum" style="color:red"> 0 </span>'+self["langs"]["selected_"+self.lang]+'</label>';
        temp=temp+'<input placeholder="'+self.langs["search_"+self.lang]+'" data-id="search" type="text" class="searchText">';
        temp=temp+'</li>';
        temp=temp+'</ul>';
        temp+='</div>';
         //创建中国海外反选清空
        temp+='<div class="cityArea" >';
        temp=temp+'<ul class="cityAreaCon">';
        temp=temp+'<li style="display: inline;">'  ;
        temp=temp+'<div class="countryName selected"><input  class="AllControl" name="All-Control-city" alt="china" type="checkbox" ><label class="AllControl" alt="china">'+self.langs["china_"+self.lang]+'</label></div>';
        temp=temp+'<div class="countryName"><input class="AllControl" name="All-Control-city" alt="foregin" type="checkbox"><label class="AllControl" alt="foregin">'+self.langs["foreign_"+self.lang]+'</label></div>';
        temp=temp+'<div style="float:right"><label data-id="unSelect" class="selectButton">'+self.langs["Unselecte_"+self.lang]+'</label> <label data-id="clearSelect" class="selectButton">'+self.langs["clear_"+self.lang]+'</label></div>';
        temp=temp+'</li>';
        temp=temp+'</ul>';
        temp+='</div>';
        //创建等级制度
        temp+='<div class="cityArea" data-type="china">';
        temp=temp+'<ul class="cityAreaCon">';
        temp=temp+'<li>'  ;
        temp=temp+'<div class="cityAreaName" style="float:left;width:12%;display: inline;"><label><input class="levelControl" alt="1" type="checkbox">'+self.langs["one_"+self.lang]+'</label></div>';
        temp=temp+'<div style="width:80%;display: inline-block;">'
        temp=temp+'<div class="cityName"><div class="cityCon"><label title="'+self.langs["two_"+self.lang]+'" ><input class="levelControl" alt="2" type="checkbox">'+self.langs["two_"+self.lang]+'</label></div></div>';
        temp=temp+'<div class="cityName"><div class="cityCon"><label title="'+self.langs["three_"+self.lang]+'"><input class="levelControl" alt="3" type="checkbox">'+self.langs["three_"+self.lang]+'</label></div></div>';
        temp=temp+'<div class="cityName"><div class="cityCon"><label title="'+self.langs["four_"+self.lang]+'"><input class="levelControl" alt="4" type="checkbox">'+self.langs["four_"+self.lang]+'</label></div></div>';
        temp=temp+'</div>';
        temp=temp+'</li>';
        temp=temp+'</ul>';
        temp+='</div>';
        temp+='<div class="citySelectArea">';
        
        for (var i = 0; i < this.cityData.length; i++) {
            temp += self.createItem(this.cityData[i],"china",i);
        }
      
        temp+='</div>';
        this.dom.html(temp);
        if(self.lang==="en"){
           // $(".cityCon",self.container).css("white-space","nowrap");
            //$(".cityCon",self.container).css("overflow","hidden");
            //$(".cityCon",self.container).css("text-overflow","ellipsis");
            $(".cityCon",self.container).css("width","132px");
            $(".township",self.container).css("left","142px");
        }
        $(".cityCon",self.container).mouseover(function(){
            /* 
            var township = $(".township",$(this).parent());
            if (township.length>0) {
                var allwidth = $(".cityDomNew",self.container).width();

                var townshipwidth = township.offset().left+township.width()-$(".cityDomNew ",self.container).offset().left;
              //  console.log(township.offset().left+"px/"+township.offset().top+"px"+townshipwidth);
                if (allwidth<townshipwidth) {
                    $(township).css("left",-$(township).width()-11);
                     
                    if (township.offset().left<10) {
                        $(township).css("left","-150px");
                        $(township).css("top","33px");
                    };
                   // console.log($(township).css("top"));
                }
            };
            var left = parseInt($(township).css("left"));
            var top = parseInt($(township).css("top"));
            var right = parseInt($(township).css("right"));
            var bottom = parseInt($(township).css("bottom"));
            //console.log(left+"::"+top+"::"+right+"::"+bottom);
            $(township).find("li").css("float","");
            if(left<0&&top>5){
                $(this).css("border-bottom","transparent");
               
            }else if(left<0){
                $(this).css("border-left","transparent");
                $(township).find("li").css("float","right");
        //    }else if(left>0&&top<5){
        //        $(this).css("border-top","transparent");
            }else if(left>0){
                $(this).css("border-right","transparent");
            }
            */
             $(this).css("border-right","transparent");
        });

        $(self.container).on("click",".countryName",function(){
            var that=this;
            var type = $(this).find(".AllControl").first().attr("alt");
            (("china"===type) && $("[data-type='china']").show() && $("[data-type='foregin']").hide() && $(".citySelectArea").css("overflow-y","")) || (("foregin"===type) && $("[data-type='foregin']").show() && $("[data-type='china']").hide() && $(".citySelectArea").css("overflow-y","auto"));
            $(that).parent().find(".selected").removeClass("selected");
            $(that).addClass("selected");
             $(".cityName").attr("style","");
             $(".citySelectArea",self.container).css("height","");
              $(".cityDomNew",self.container).css("border-bottom","none");
            if("foregin"===type){
                self.getForeignData(self);
                $(".cityName",self.container).attr("style","width: 120px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;");
                $(".citySelectArea",self.container).css("height","307px");
                $(".cityDomNew",self.container).css("border-bottom","1px solid #ccc");
            }
        });
        $(self.container).on("click",".AllControl",function(){
            var that=this;
            var type = $(this).attr("alt");
            (("china"===type) && $("[data-type='china']").show() && $("[data-type='foregin']").hide()) || (("foregin"===type) && $("[data-type='foregin']").show() && $("[data-type='china']").hide());
            $(that).parent().parent().find(".selected").removeClass("selected");
            $(that).parent().addClass("selected");
            if (that.type==="checkbox") {
                $(self.container).find("[data-type='"+type+"']").find(":checkbox").attr("checked",$(that)[0].checked);
                /*$(self.container).find("[data-type='"+type+"']").find(".cityControl").each(function(){
                     self.sumCount(this);
                });*/
                $(".citySum").remove();
                self.sumAllCount();
            };
        });
        $(self.container).on("click",".levelControl",function(){
            var name = $(this).attr("alt");
            var bool = this.checked;
            //$(self.container).find(":checkbox:not(.levelControl)").attr("checked",false);
            for (var i = self.levelCity.length - 1; i >= 0; i--) {
                if(name===self.levelCity[i].name){
                    for (var j = self.levelCity[i].items.length - 1; j >= 0; j--) {
                        $('[value="'+self.levelCity[i].items[j]+'"].townshipControl').attr("checked",bool);
                        $('[value="'+self.levelCity[i].items[j]+'"].zhixiashiControl').attr("checked",bool);
                    };
                }
            };
            $(self.container).find("[data-type='china']").find(".areaControl:checked").attr("checked",false);
            $(self.container).find(".cityControl").each(function(){
                 self.sumCount(this);
            });
            self.sumAllCount();
        });
        $(self.container).on("change",".areaControl",function(event) {
            $(this).parent().parent().parent().find(".cityControl").attr("checked", $(this)[0].checked);
            $(this).parent().parent().parent().find(".townshipControl").attr("checked", $(this)[0].checked);
            $(this).parent().parent().parent().find(".foreginControl").attr("checked", $(this)[0].checked);
            $(this).parent().parent().parent().find(".zhixiashiControl").attr("checked", $(this)[0].checked);
            $(self.container).find(".cityControl").each(function(){
                 self.sumCount(this);
            });
            self.sumAllCount();
        });

        $(self.container).on("click",".areaControl",function(){
            $(this).change();
        })
        $(self.container).on("click",".foreginControl",function(){
           
            self.sumAllCount();
        })
        $(self.container).on("click",".zhixiashiControl",function(){
           
            self.sumAllCount();
        })

        $(".cityControl",self.container).change(function(event){
            var $li=$(this).parent().parent().parent().parent().parent();
            $(this).parent().parent().parent().find(".townshipControl").attr("checked",$(this)[0].checked);
           
            self.sumCount(this);
            self.sumAllCount();
        });
        $(self.container).on("click",".cityControl",function(){
            $(this).change();
        })
        $(self.container).on("change",".townshipControl",function(event){
            
            self.sumCount(this);
            self.sumAllCount();
        });
        $(self.container).on("click",".townshipControl",function(){
            $(this).change();
           
        });
        $("[data-id='search']").bind('keyup keypress', function (e) {
            var code = e.keyCode || e.which;
            if (code == 13) {
                return false;
            }
        });
       $("[data-id='search']",self.container).keyup(function(event){
            self.input=this;
            self.createUl(this);
             // 下拉菜单显示的时候捕捉按键事件
            event = event || window.event;
            var keycode = event.keyCode;
            if(self.ul && !$(self.ul).hasClass("hide")){
                self.KeyboardEvent(event,keycode);
            }
       });
       $("[data-id='search']",self.container).click(function(){
            self.input=this;
           // if(self.ul)$(self.ul).removeClass("hide");
            self.createUl(this);
       });
       $("[data-id='unSelect']",self.container).click(function(){
            var that= this,
                type = $(".AllControl").parent(".selected").find(":checkbox").attr("alt"),
                bool;
            if ("china"===type) {
                $(self.container).find(":checkbox.townshipControl").each(function(){
                    this.checked=!this.checked;
                });
                $(self.container).find(":checkbox.zhixiashiControl").each(function(){
                    this.checked=!this.checked;
                });
                $(self.container).find(".levelControl:checked").attr("checked",false);
                $(self.container).find("[data-type='"+type+"']").find(".areaControl:checked").attr("checked",false);
                $(self.container).find(".cityControl").each(function(){
                     self.sumCount(this);
                });
            }else{
               $(self.container).find(":checkbox.foreginControl").each(function(){
                    this.checked=!this.checked;
                });
            }
            self.sumAllCount();
       });
       $("[data-id='clearSelect']",self.container).click(function(){
            var type = $(".AllControl").parent(".selected").find(":checkbox").attr("alt");;
            $(self.container).find("[data-type='"+type+"']").find(":checkbox").attr("checked",false);
            $(".citySum").remove();        
            self.sumAllCount();
       });
    }
    /* 正则表达式 筛选中文城市名、拼音、首字母 */

        BS.regEx_en = /(\w+)\|(\w+)\|(\w)\w*$/i;
        BS.regExChiese_en = /(\w+)/;

        BS.regEx = /^([\u4E00-\u9FA5\uf900-\ufa2d]+)\|(\w+)\|(\w)\w*$/i;
        BS.regExChiese = /([\u4E00-\u9FA5\uf900-\ufa2d]+)/;

    
    BS.Ncity.prototype = {
         /* 绑定事件 */
        on:function (node, type, handler) {
            node.addEventListener ? node.addEventListener(type, handler, false) : node.attachEvent('on' + type, handler);
        },

        /* 获取事件 */
        getEvent:function(event){
            return event || window.event;
        },

        /* 获取事件目标 */
        getTarget:function(event){
            return event.target || event.srcElement;
        },
        /* 阻止冒泡 */
        stopPropagation:function (event) {
            event = event || window.event;
            event.stopPropagation ? event.stopPropagation() : event.cancelBubble = true;
        },
         /* 获取元素位置 */
        getPos:function (node) {
            var scrollx = document.documentElement.scrollLeft || document.body.scrollLeft,
                scrollt = document.documentElement.scrollTop || document.body.scrollTop;
            var pos = node.getBoundingClientRect();
            return {top:pos.top + scrollt, right:pos.right + scrollx, bottom:pos.bottom + scrollt, left:pos.left + scrollx }
        },
        /*country:"china",isChinaAll:false,city_level:"1,2,3",province:[{province_id:"1",city_id:"1,2,3"}]*/
        getSelected: function() {
            var city = $(".cityControl:checked","[data-type='china']"),
                shi =  $(".zhixiashiControl:checked","[data-type='china']"),
                con =  $(".foreginControl:checked","[data-type='foregin']"),
                level = $(".levelControl:checked","[data-type='china']"),
                isChinaAll = $("input[alt='china']",".cityDomNew").is(":checked"),
                town,
                citys=[],
                levels = [],
                jsonChina={},
                jsonForegin={},
                jsonProvince={},
                countrys = [],
                result=[];

            if(shi.length>0||city.length>0){
                jsonChina.country="china";
                jsonChina.province=[];
            }
            if (level.length>0) {
                for (var i = 0; i < level.length; i++) {
                    levels.push($(level[i]).attr("alt"));
                };
                jsonChina.city_level =levels.join(",");
            };

            for (var i = 0; i < shi.length; i++) {
                jsonProvince={};
                jsonProvince.province_id=$(shi[i]).attr("value");
                jsonProvince.city_id=$(shi[i]).attr("value");
                jsonChina.province.push(jsonProvince);
            }
            
            for (var i = 0; i < city.length; i++) {
                jsonProvince={};
                citys=[];
                jsonProvince.province_id=$(city[i]).attr("value");
                town=$(city[i]).parent().parent().parent().find(".townshipControl:checked");
                for (var j = 0; j < town.length; j++) {
                    citys.push($(town[j]).attr("value"));
                };
                jsonProvince.city_id=citys.join(",");
                jsonChina.province.push(jsonProvince);
            }
            if(jsonChina.country){
                jsonChina.isChinaAll=isChinaAll;
                result.push(jsonChina);
            }
            if (con.length>0) {
                jsonForegin.country="foregin";
            
                for (var i = 0; i < con.length; i++) {
                    countrys.push($(con[i]).attr("value"));
                }
                jsonForegin.country_id=countrys.join(",")
            };
            if (jsonForegin.country) {
                result.push(jsonForegin);
            };
     //       console.log(result);
            return result;
        },
        setSelected:function(data){
            var self = this,
                $con,i,alt,
                city=[],hasdone="",length=0,foreginLength=0;

            self.getForeignData(self);
            var type  = $(".AllControl").parent().not(".selected").find(":checkbox").attr("alt");
            $("[data-type='"+type+"']").hide();

            for(var i=0;i<data.length;i++){
                $con={};
                $con=self.dom.find("input[value='"+data[i]+"']:first");
               // $con.trigger("click");
                $con.attr("checked",true);
                //获取对应省份
                if ($con.hasClass('townshipControl')) {
                    city.push($con.parent().parent().parent().parent().parent());
                };
            }
            //获取对应省份下对应城市比重
            if (city.length>0) {
                for (i = city.length - 1; i >= 0; i--) {
                    alt=city[i].find(".cityControl").attr("alt");
                    hasdone = hasdone+alt+",";
                    if (hasdone!="" && !hasdone.indexOf(alt)>-1) {
                        self.calculateChose(city[i],city[i].find(".cityCon"));
                    };
                };
            };
            //海外国际选中
            $(self.container).find("[data-type='foregin']").find(".areaControl").each(function(){
                length=$(this).parent().parent().parent().find(".foreginControl:not(:checked)").length;
                $(this).attr("checked",length===0); 
                foreginLength+=length;
            }); 
            //海外是否选中
            $(self.container).find("input[alt='foregin']").attr("checked",foreginLength===0);
             self.sumAllCount();
        },
        createChild: function(d) {
            var self = this,
                match,
                str = "";

            match = d.name.split("|"); 
            if(d.items.length>0){
                str += '<div class="cityName"><div class="cityWrap" ><div class="cityCon"><label title="'+match[0]+'"><input class="cityControl" alt="'+match[0]+'" title="'+match[0]+'" value="'+match[2]+'" type="checkbox"/> ' + match[0] + '<input name="pinyin" value="'+match[1]+'" type="hidden" /></label></div><div class="township"><ul>';
            }else{
                self.citys.push(d.name);
                str +='<div class="cityName"><div class="" ><div class="cityCon"><label title="'+match[0]+'"><input class="zhixiashiControl" alt="'+match[0]+'" title="'+match[0]+'" value="'+match[2]+'" type="checkbox"/> ' + match[0] + '<input name="pinyin" value="'+match[1]+'" type="hidden" /></label></div>';
            }
            for (var i = 0; i < d.items.length; i++) {
                match = d.items[i].split("|");
                self.citys.push(d.items[i]);
                str += '<li><label title="'+match[0]+'"><input class="townshipControl" alt="'+match[0]+'" title="'+match[0]+'" value="'+match[2]+'" type="checkbox"/> ' + match[0] + '<input class="pinyin" value="'+match[1]+'" type="hidden"/></label></li>';
            }
            if (d.items.length>0) {
                str +='</ul></div>';
            };
            str += '</div></div>';
            return str;
        },
        createItem: function(d,type,i) {
            var self = this,
                match=[],
                dom,
                color=(i%2===0)?"":"background-color:#f1f1f3";
            try{

                switch(type){
                    case "china":
                        match = d.name.split("|");
                        match.push(color);
                        break;
                    case "foregin":
                        match = d.name?d.name.split("|"):d.split("|");
                        match.push(color);
                        d.name?"":self.foreginCitys.push(d);
                        break;
                    default:
                        break;
                }

            }catch(event){
                console.log(d);
            }
            //d.items存在代表是国内选中和国外的区域选中组装样式，不存在则是国外的国家选中样式，无child节点
            dom = d.items?'<div class="cityArea"  style="'+match[3]+'" data-type="'+type+'"><ul class="cityAreaCon"><li>':'';
            if ("foregin"===type) {
                dom+=d.items?'<div class="cityAreaName" style="float:left;width:12.7%;display: inline;"><label title="'+match[0]+'"><input class="areaControl" alt="'+match[0]+'" title="'+match[0]+'" value="'+match[1]+'" type="checkbox"/> ' + match[0] + '</label></div>':'';
                dom+=d.items?'<div style="width:82%;display: inline-block;">':'';
            };
            if ("china"===type) {
                dom+=d.items?'<div class="cityAreaName" style="float:left;width:12%;display: inline;"><label title="'+match[0]+'"><input class="areaControl" alt="'+match[0]+'" title="'+match[0]+'" value="'+match[1]+'" type="checkbox"/> ' + match[0] + '</label></div>':''; 
                dom+='<div style="width:80%;display: inline-block;">';
            };
            dom+=d.items?'':'<div class="cityName" style="padding-right:10px;padding-bottom:10px"><label title="'+match[0]+'"><input class="foreginControl"  value="'+match[2]+'" alt="'+match[0]+'" title="'+match[0]+'" type="checkbox"/> ' + match[0] + '</label></div>';
            if (d.items) {
                for (var i = 0; i < d.items.length; i++) {
                    if ("china"===type) {
                        dom += self.createChild(d.items[i]);
                    }else{
                        dom += self.createItem(d.items[i],type);
                    }
                    
                }
            };
            if ("foregin"===type) {
                dom+=d.items?'</div>':'';
            };
             if ("china"===type) {
                dom+='</div>';
            };
            dom += d.items?'</li></ul></div>':'';
            return dom;
        },
        searchItem:function(d){
            var self = this,
                dom,$select;
            $("label").css("background-color","");     
            if(d!=""){
                    dom= $("label:contains('"+d+"')");
                    if (dom.length>0) {
                     dom.parent().parent().parent().prev().children("label").css("background-color","#C4EF2D");
                         $("label:contains('"+d+"')").css("background-color","#B2E0FF");
                         $select=dom.parent().parent().parent().prev().children("label").length>0?dom.parent().parent().parent().prev().children("label"):$("label:contains('"+d+"')");
                      //  $("#city").animate({scrollTop:$select.offset().top-100},1000);
                        if (dom.parents(".cityArea").is(":hidden")) {
                             $(".countryName:not(.selected)").click();
                        };
                        $select.focus();
                    }
                    
            }
        },
        sumCount:function(d){
            var self = this,
                dom,
                $chose,
                $choseCity,
                citySum=0,
                citySumSelect=0,
                domCity=0,
                domCon=0;
           
            if(d.className){
                switch(d.className){
                    case "townshipControl":
                        $chose = $(d).parent().parent().parent().parent().parent();
                        $choseCity = $chose.find(".cityCon");
                        break;
                    case "cityControl":
                        $chose = $(d).parent().parent().parent();
                        $choseCity = $(d).parent().parent();
                        break;
                   
                    default:
                        console.log(d.className);
                        break;
                }
                //已选择城市
                if ($chose) {
                    self.calculateChose($chose,$choseCity);
                };
                
                //总共选择城市
                //$(".allSum").text(domCity);
            }
        },
        sumAllCount: function(){
            var self = this,
                type = $(".AllControl").parent(".selected").find(":checkbox").attr("alt"),
                classCheck ,
                levelCity,
                length,
                domCon,
                domCity,
                domShi,
                i,j,result;
            if("china"===type){
                classCheck=".cityControl";
            }else if ("foregin"===type) {
                classCheck=".foreginControl";
            };
            domCon=$(".foreginControl:checked","[data-type='foregin']").length;
            domShi = $(".zhixiashiControl:checked","[data-type='china']").length+domCon;
            domCity = $(".townshipControl:checked","[data-type='china']").length+domShi;
            //总共选择城市
            $(".allSum").text(" "+domCity+" ");    
            //地区是否选中
            $(self.container).find("[data-type='"+type+"']").find(".areaControl").each(function(){
                length=$(this).parent().parent().parent().find(classCheck+":not(:checked)").length;
                if (length>0) {
                    $(this).attr("checked",false);
                }else{
                    type==="china"&&(length=$(this).parent().parent().parent().find(".townshipControl:not(:checked),.zhixiashiControl:not(:checked)").length+length);
                    $(this).attr("checked",length===0); 
                }
            }); 
            //国家是否选中
            $(self.container).find(".AllControl:not('label')").each(function(){
                if (type==$(this).attr('alt')) {
                    if("china"===$(this).attr('alt')){
                        classCheck=".townshipControl";
                        length=$(self.container).find("[data-type='"+$(this).attr('alt')+"']").find(".zhixiashiControl:not(:checked)").length;
                    }else if ("foregin"===$(this).attr('alt')) {
                        classCheck=".foreginControl";
                        length=0;
                    };

                    $(this).attr("checked",length===0?($(self.container).find("[data-type='"+$(this).attr('alt')+"']").find(classCheck+":not(:checked)").length+length===0):false);
                };
                
            });
            //x线城市是否选中
            if ("china"===type) {
                for ( i = 0; i < self.levelCity.length ; i++) {
                    levelCity = self.levelCity[i];
                   // console.log(levelCity);
                    $(".levelControl").eq(Number(levelCity.name)-1).attr("checked",true);
                    for (j = levelCity.items.length - 1; j >= 0; j--) {
                       // console.log(levelCity.items[j]+"::"+$("input[value='"+levelCity.items[j]+"']").is(":checked"));
                        if(!$("input[value='"+levelCity.items[j]+"']").is(":checked")){
                            $(".levelControl").eq(Number(levelCity.name)-1).attr("checked",false);
                            break;
                        }
                    };
                };
            };
            if (self.result) {
                result=self.getSelected().length===0?"":JSON.stringify(self.getSelected());
                self.result.attr("value",result);
            };
            self.callback && self.callback(result);
        },
        liEvent:function(){
            var self = this;
            var lis = $(self.ul).find("li");
            for(var i = 0,n = lis.length;i < n;i++){
                (function(i){
                    self.on(lis[i],'click',function(event){
                    event = self.getEvent(event);
                    var target = self.getTarget(event);
                    self.input.value = target.innerText || target.textContent;
                    self.searchItem(self.input.value);
                    //$(self.container).find(".AllControl[alt='china']").click();
                    $(self.ul).addClass('hide');
                    });
                   $(lis[i]).mouseover(function(){
                        $(this).addClass('on');
                        self.count=i;
                    });
                    $(lis[i]).mouseout(function(){
                        $(this).removeClass('on');
                    })
                })(i)
                
            }
        },
        createUl:function(d){
            var self = this;
            var value = $.trim($(d).val());
            var inputPos = self.getPos(d);
            var type = $(".AllControl").parent(".selected").find(":checkbox").attr("alt");
            var searchArr=[];
            //"china"===type?searchArr=self.citys:searchArr=self.foreginCitys;
            self.getForeignData(self);
            var type  = $(".AllControl").parent().not(".selected").find(":checkbox").attr("alt");
            $("[data-type='"+type+"']").hide();
            for (var i = 0; i < self.citys.length; i++) {
               searchArr.push(self.citys[i]);
           };
           for (var i = 0; i < self.foreginCitys.length; i++) {
               searchArr.push(self.foreginCitys[i]);
           };
            if(self.rootDiv){
                var div = self.rootDiv
            }else{
                div = self.rootDiv = document.createElement('div');
            }
             // 设置DIV阻止冒泡
            self.on(self.rootDiv,'click',function(event){
               self.stopPropagation(event);
            });
            // 设置点击文档隐藏弹出的城市选择框
            self.on(document, 'click', function (event) {
                event = self.getEvent(event);
                var target = self.getTarget(event);
                if(target == self.input) return false;
                //console.log(target.className);
                if (self.ul){
                    //$(self.ul).addClass("hide");
                    $(self.ul).remove();
                    self.ul="";
                }
            });
            if($(".container").length>0){
               inputPos.left =inputPos.left - $(".container").offset().left;
               inputPos.bottom =inputPos.bottom - $(".container").offset().top;
            }
            $(".citySelector").remove();
            div.className = 'citySelector';
            div.style.position = 'absolute';
            div.style.left = inputPos.left + 'px';
            div.style.top = inputPos.bottom + 'px';
            div.style.zIndex = 999999;
            if(value!=""){
                var reg = new RegExp(value + "|\\|" + value, 'gi');
                var searchResult = [];
                for (var i = searchArr.length - 1; i >= 0; i--) {
                   if (reg.test(searchArr[i])) {
                        var match = searchArr[i].split("|");
                        if (searchResult.length !== 0) {
                            str = '<li><b class="cityname">' + match[0] + '</b></li>';
                        } else {
                            str = '<li class="on"><b class="cityname">' + match[0] + '</b></li>';
                        }
                        searchResult.push(str);
                    }
                };
                this.isEmpty = false;
                // 如果搜索数据为空
                if (searchResult.length == 0) {
                    this.isEmpty = true;
                    str = '<li class="empty">对不起，没有找到数据 "<em>' + value + '</em>"</li>';
                    searchResult.push(str);
                }
                if (!self.ul) {
                    var ul = self.ul = document.createElement('ul');
                     self.count = 0;
                }
                self.ul.className = 'cityslide';
                self.rootDiv && self.rootDiv.appendChild(self.ul);
                $(d).after(self.rootDiv);
                $(self.ul).html( searchResult.join(''));

                // 绑定Li事件
                this.liEvent();
            }else{
                if (self.ul) {
                     //$(self.ul).addClass("hide");
                    $(self.ul).remove();
                    self.ul="";
                };
            }

        },
        /* *
         * 特定键盘事件，上、下、Enter键
         * @ KeyboardEvent
         * */

        KeyboardEvent:function(event,keycode){
            var lis = $(this.ul).find("li");
            var len = lis.length;
            switch(keycode){
                case 40: //向下箭头↓
                    this.count++;
                    if(this.count > len-1) this.count = 0;
                    for(var i=0;i<len;i++){
                        $(lis[i]).removeClass('on');
                    }
                    $(lis[this.count]).addClass('on');
                    break;
                case 38: //向上箭头↑
                    this.count--;
                    if(this.count<0) this.count = len-1;
                    for(i=0;i<len;i++){
                        $(lis[i]).removeClass('on');
                    }
                    $(lis[this.count]).addClass('on');
                    break;

                case 13: // enter键
                    this.input.value = lis[this.count].innerText || lis[this.count].textContent;
                    this.searchItem(this.input.value);
                    $(this.ul).remove();
                    this.ul="";
                    break;
                default:
                    break;
            }
        },
        convertChina:function(d,type,thi){
            var result=[],levels=[],area = ["huabei", "huadong", "huanan", "huazhong","dongbei","xibei","xinan","gangaotai"],
                level=["1","2","3","4"],allcitys=[],objLevel,
                obj={},objprovince={},city=[],i,j,k,l,m,n,temp=[],objResult,name,
                areaFY={"huabei":"North","huadong":"East","huanan":"South","huazhong":"Central","dongbei":"Northeast","xibei":"Northwest","xinan":"Southwest","gangaotai":"HK, MO & TW"};
            type=type==="en"?"":"_cn";
            for ( i = d.length - 1; i >= 0; i--) {
                obj={};
                objprovince={};
                objprovince.items=[];
                obj.name=d[i]["area"+type]+"|"+d[i]["area"]+"|"+"-1";
                objprovince.name=d[i]["provice_name"+type]+"|"+d[i]["provice_name"]+"|"+d[i]["provice_id"];
                if(d[i].cities.length>0){
                    for (j = d[i].cities.length - 1; j >= 0; j--) {
                        objprovince.items.push(d[i].cities[j]["city_name"+type]+"|"+d[i].cities[j]["city_name"]+"|"+d[i].cities[j]["city_id"]);
                        if (d[i].cities[j]["city_level"]) {
                            allcitys.push(d[i].cities[j]["city_name"+type]+"|"+d[i].cities[j]["city_level"]+"|"+d[i].cities[j]["city_id"]);
                        };
                    };
                }
                //if("Beijing Tianjin Shanghai".indexOf(d[i]["provice_name"])>-1 ){
                //    allcitys.push(d[i]["provice_name"+type]+"|1|"+d[i]["provice_id"]);
                //}
                if("Beijing Shanghai".indexOf(d[i]["provice_name"])>-1 ){
                    allcitys.push(d[i]["provice_name"+type]+"|1|"+d[i]["provice_id"]);
                }
                if("Tianjin".indexOf(d[i]["provice_name"])>-1 ){
                    allcitys.push(d[i]["provice_name"+type]+"|2|"+d[i]["provice_id"]);
                }

                obj.provice=objprovince; 
                temp.push(obj);
            };
            //重新组装地区省份城市新兴
            for (l = area.length - 1; l >= 0; l--) {
                objResult={};
                objResult.items=[];
                for (k = temp.length - 1; k >= 0; k--) {

                    if(temp[k].name.toLowerCase().indexOf(area[l])>-1){
                        name=temp[k].name;
                        objResult.items.push(temp[k].provice);
                    }
                };
                if (name) {

                    name = name.split("|")[0];
                    if(type=="" ){
                        name = areaFY[name];
                    }
                    
                    objResult.name=name+"|"+name+"|-1";
                    result.push(objResult);
                };
                
            };
            
            //重新组装等级信息
            for (m = level.length - 1;  m >= 0; m--) {
                objLevel={};
                objLevel.items=[];
                name="";
                for (n = allcitys.length - 1; n >= 0; n--) {
                    city=allcitys[n].split("|");
                    if(city[1]===level[m]){
                        name=city[1];
                        objLevel.items.push(city[2]);
                    }
                };
                if (name!="") {
                    objLevel.name=name;
                    levels.push(objLevel);
                };
            };
         //   console.log(levels);
            thi.cityData= result;
            thi.levelCity=levels;
        },
        converForegin:function(d,type,thi){
            var result =[],area=["Asia","Afrika","Europe","North","South","Oceania"],
                obj,temp=[],objResult,name,
                i,j,k,
                areaFY={"Asia":"Asia","Afrika":"Africa","Europe":"Europe","North":"North America","South":"South America","Oceania":"Oceania"};
            type=type==="en"?"":"_cn";
            for (i = d.length - 1; i >= 0; i--) {
                obj={};
                obj.name=d[i]["continent_name"+type]+"|"+d[i]["continent_name"]+"|"+"-1";
                obj.country=d[i]["foreign_name"+type]+"|"+d[i]["foreign_name"]+"|"+d[i]["foreign_id"];
                temp.push(obj);
            };
            //重新组装国外国家
            for (j = area.length - 1; j >= 0; j--) {
                objResult={};
                objResult.items=[];
                for (k = temp.length - 1; k >= 0; k--) {
                    if (temp[k].name.indexOf(area[j])>-1) {
                        name=temp[k].name;
                        objResult.items.push(temp[k].country);
                    };
                };
                if (name) {
                    if(type=="" ){
                        name = name.split("|")[0];
                        name = areaFY[name];
                        objResult.name=name+"|"+name+"|-1";
                    }else{
                        objResult.name=name;
                    }
                    result.push(objResult);
                };
            };
           // console.log(JSON.stringify(result));
            thi.foreignData=result;
        },
        getForeignData:function(self){
            if (self.foreign && self.foreignData.length===0) {
                self.converForegin(self.foreign,self.lang,self);
                for (var i = 0; i < self.foreignData.length; i++) {
                    self.tempForeign += self.createItem(self.foreignData[i],"foregin",i);
                }
                $("[data-type='china']:last").after(self.tempForeign);
             };
        },
        calculateChose:function($chose,$choseCity){
            var citySum = $chose.find(".townshipControl").length;
            var citySumSelect = $chose.find(".townshipControl:checked").length;
             $choseCity.find(".cityControl").attr("checked",false);
            $(".citySum",$chose).remove();
            if(citySumSelect>0){
                if(citySumSelect<citySum){
                    dom = '<span class="citySum" >'+citySumSelect+'/'+citySum+'</span>';
                    $choseCity.append(dom);  
                }
               $choseCity.find(".cityControl").attr("checked",true);
               //$choseCity.parent().parent().parent().find(".areaControl").attr("checked",true);
            }
        }
    }
    
 })(bshare);