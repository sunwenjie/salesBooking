$(function () {
    var time = 250;
    var hideDelay = 10000;
    var hideDelayTimer = null;
    $(document).on('click', '.xmo-popover',function(){
        if (hideDelayTimer) clearTimeout(hideDelayTimer);
    });

    $(document).on('click', '.xmo-tooltip-click',function(){
        var _this=this
        var type = $(_this).attr("type")
        var url = $(_this).attr("url")
        if (type == "client_node_message"){
            var client_id = $(this).attr("client_id")
            var node_id = $(this).attr("node_id")
            var status = $(this).attr("status")
            var whether_cross_district = $(this).attr("whether_cross_district")
            var params = {"client_id":client_id,"node_id":node_id,"status":status,"whether_cross_district":whether_cross_district}
        }else if(type == "ad_message" || type == "client_message"){
            var order_id = $(_this).attr("order_id")
            var params = {"type":type,"order_id":order_id}
        }else{
        var order_id = $(_this).attr("order_id")
        var params = {"type":type,"order_id":order_id}
        var position = $(_this).attr("position")
            if (position == "show_page"){
                params["position"]= position
            }
        if (type == "pre_check" || type =="order_approval" || type =="contract_check" || type =="order_distribution" || type == "gp_control"){
            var node_ids = $(_this).attr("node_ids")
            var status =  $(_this).attr("status")
            var is_statndard_or_unstatnard = $(_this).attr("is_statndard_or_unstatnard")
            var is_pre_check = $(_this).attr("is_pre_check")
            params["order_id"]= order_id
            params["node_ids"] = node_ids
            params["status"] = status
            params["is_nonstandard"] = is_statndard_or_unstatnard
            params["is_pre_check"] = is_pre_check
        }else if(type =="schedul_list"){
            var status =  $(_this).attr("status")
            var node_ids = $(_this).attr("node_ids")
            params["status"] = status
            params["node_ids"] = node_ids
        }
        }
        $.ajax({
            type : "POST",
            url : url,
            data : params,
            success : function(data){

                if (type == "client_node_message"){
                    $("#"+client_id+"_"+type).html(data);
                }else if (type == "ad_message" || type == "client_message"){
                    $("#"+order_id+"_"+type).html(data);
                }else{
                    if(type == "order_approval" && (is_statndard_or_unstatnard == "true") ){
                        type = "non_standard_approval"
                    }
                    $("#" + order_id + "_" + type + "_message").html(data);
                }
                if (hideDelayTimer) clearTimeout(hideDelayTimer);

                var position = $(_this).attr('data-position') || 'top';
                var id = $(_this).attr('data-id');
                var width_info = parseInt($(_this).attr('data-width'));
                var data_wordbreak = $(_this).attr('data-wordbreak');
                var opt_offset = $(_this).attr('data-offset');
                if(!id){
                    id = ('a' + Math.random()).replace('.','');
                }
                $(_this).attr('data-id',id);
                if($('#' + id).length > 0) return false;
                var info = $(_this).find('.xmo-popover').clone(true).addClass('xmo-tooltip-showbox').attr('id',id).show();
                info.find(":radio").each(function(){
                    $(this).attr("name",$(this).attr("name")+"_clone")
                })

                info.find("textarea").each(function(){
                    $(this).attr("id",$(this).attr("id")+"_clone")
                })
                info.find("select").each(function(){
                    $(this).trigger("change");
                })
                var top = 0;
                var left = 0;
                var offset_left = $(_this).offset().left;
                var offset_top = $(_this).offset().top;
                var width = $(_this).width();
                var height = $(_this).height();

                $('.xmo-tooltip-showbox').remove();
                info.hide().appendTo($('body'));

                if(!!width_info) info.width(width_info);
                if(!!data_wordbreak){
                    info.find('.popover-content').css({'word-break':'break-all'});
                }
                if(position == 'right'){
                    tar_top = offset_top + height/2 - info.outerHeight()/2;
                    tar_left = offset_left + width;
                }else if(position == 'top'){
                    tar_top = offset_top - info.outerHeight();
                    tar_left = offset_left + width/2 - info.outerWidth()/2;
                }else if(position == 'left'){
                    tar_top = offset_top + height/2 - info.outerHeight()/2;
                    tar_left = offset_left - info.outerWidth();
                }else if(position == 'bottom'){
                    tar_top = offset_top + height;
                    tar_left = offset_left + width/2 - info.outerWidth()/2;
                }else if(position == 'right-bottom'){
                    tar_top = offset_top;
                    tar_left = offset_left + width;
                    position="right";
                }else if(position == 'left-bottom'){
                    tar_top = offset_top + height;
                    tar_left = offset_left + width/2 - info.outerWidth()/2 - 110;
                    position="bottom";
                }

                if(!!opt_offset){
                    opt_offset = opt_offset.split('_');
                    if(opt_offset[0] == 'top'){
                        tar_top += parseInt(opt_offset[1]);
                    }else if(opt_offset[0] == 'left'){
                        tar_left += parseInt(opt_offset[1]);
                    }
                }
                info.addClass(position).css({top: tar_top,left: tar_left}).fadeIn(200);

                $(".popover_position").css({"top":-17})
                $(".popover_position").parent().css({"marginTop":-2})
                $(".popover_position_left").css({"marginTop":-2,"marginLeft":0})
                $(".popover_position_top").css({"marginTop":25})
                 if (type != "client_node_message") {
                     $(".xmo-tooltip-showbox").find("#" + order_id + "_operator_id").chosen();
                     $(".xmo-tooltip-showbox").find("#" + order_id + "_share_username").chosen();

                 }
                return false;
            },
            error: function (msg) {
            }

        });

            return false;

        }
    )

    

    $(document).on('mouseleave', '.xmo-tooltip-click,.xmo-popover',function(){
        if($(this).hasClass('no-mouseout')){
            return false;
        }else if($(this).hasClass('cancel_change_gp')){
            ChangeProductGp.cancel_change_gp();
        }else{
            var hasFocus ;
            $("textarea").each(function(){
                console.log($(this).is(":focus"));
                if ($(this).is(":focus")) {hasFocus=true};
            })
            if(hasFocus){
                return false;
            }else {
                if (hideDelayTimer) clearTimeout(hideDelayTimer);
                hideDelayTimer = setTimeout(function () {
                    hideDelayTimer = null;
                    $('.xmo-tooltip-showbox').remove();
                    shown = false;
                }, hideDelay);
                return false;
            }
        }
    });
    var _tooltipCallback=function(){
        if (hideDelayTimer) clearTimeout(hideDelayTimer);
        var position = $(this).attr('data-position') || 'top';
        var id = $(this).attr('data-id');
        var width_info = parseInt($(this).attr('data-width'));
        var data_wordbreak = $(this).attr('data-wordbreak');
        var opt_offset = $(this).attr('data-offset');
        if(!id){
            id = ('a' + Math.random()).replace('.','');
        }
        $(this).attr('data-id',id);
        if($('#' + id).length > 0) return false;
        var info = $(this).find('.xmo-popover').clone(true).addClass('xmo-tooltip-showbox').attr('id',id).show();
        var top = 0;
        var left = 0;
        var offset_left = $(this).offset().left;
        var offset_top = $(this).offset().top;
        var width = $(this).width();
        var height = $(this).height();
        $('.xmo-tooltip-showbox').remove();
        info.hide().appendTo($('body'));
        if(!!width_info) info.width(width_info);
        if(!!data_wordbreak){
            info.find('.popover-content').css({'word-break':'break-all'});
        }
        if(position == 'right'){
            tar_top = offset_top + height/2 - info.outerHeight()/2;
            tar_left = offset_left + width;
        }else if(position == 'top'){
            tar_top = offset_top - info.outerHeight();
            tar_left = offset_left + width/2 - info.outerWidth()/2;
        }else if(position == 'left'){
            tar_top = offset_top + height/2 - info.outerHeight()/2;
            tar_left = offset_left - info.outerWidth();
        }else if(position == 'bottom'){
            tar_top = offset_top + height;
            tar_left = offset_left + width/2 - info.outerWidth()/2;
        }
        if(!!opt_offset){
            opt_offset = opt_offset.split('_');
            if(opt_offset[0] == 'top'){
                tar_top += parseInt(opt_offset[1]);
            }else if(opt_offset[0] == 'left'){
                tar_left += parseInt(opt_offset[1]);
            }
        }
        info.addClass(position).css({top: tar_top,left: tar_left}).fadeIn(200);
        return false;
    };
    $(document).on('click', '.booking-tooltip-click',_tooltipCallback);
    $.hideTips = function(){
        if (hideDelayTimer) clearTimeout(hideDelayTimer);
        hideDelayTimer = null;
        $('.xmo-tooltip-showbox').remove();
        shown = false;
    }



});