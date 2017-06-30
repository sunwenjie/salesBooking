#!/usr/bin/env ruby -w -s
# -*- coding: utf-8 -*-
module SendAxlsx

 def left_string
    @str1="1.该媒介计划为爱点击广告服务投放报价单。"
    @str2="2.该媒介计划在客户最终确认前可能会发生修改。一经客户在本文件下方签字栏签字或盖章确认，该媒介计划成为媒介执行表，是双方合同不可分割的一部分，爱点击将根据该表的规定为客户购买媒体，执行广告活动。"
    @str3="3.爱点击广告服务投放印象数、点击数的分配将根据可竞价资源在投放期的实际情况进行动态分配。"
    @str4="4.爱点击使用客户确认的广告样稿,不擅自改动广告样稿。"
    @str5="5.客户广告内容必须真实、合法，爱点击有权审查广告内容和表现形式，对不符合法律法规的广告内容和表现形式,有权要求客户修改。"
    @str6="6.本报价单自爱点击发出日起30天（含第30天）有效。"
    @str7="7.客户付款方式：采取投放后付款，具体细则以合同中相关付款方式为准。"
    @str8="8.爱点击免费制作的广告创意、作品、程序等（不包含由客户提供的创意素材）的知识产权和源代码属于爱点击所有，客户得在支付制作及技术开发等相关费用后取得上述广告创意、作品、程序等的知识产权和源代码。"
    @str9="9.本报价单一经客户签字或盖章确认，不得更改，否则客户承担变更或修改本报价单导致的变更或修改费用，包括但不限于损失赔偿，违约金、罚款等。"
 end

 def empety_rows(i)
    i.times.each do
      @ws.add_row
    end
 end


 def sheel_images
    img = File.expand_path('../logo3.png', __FILE__)
    @ws.add_image(:image_src => img, :start_at => [0,0],:noEditPoints=>true) do |image|
      image.width = 190
      image.height = 63
    end
 end

 def random
    request_id = ([*('A'..'Z'),*('a'..'z'),*('0'..'9')]-%w(0 1 h I O)).sample(14).join
    return request_id
 end

 def send_schedule_xlsx(order_id)
    left_string
    @order=Order.find(order_id)
    my_package = Axlsx::Package.new
    my_package.workbook do |wb|
    styles = wb.styles
    title = styles.add_style :sz => 26,:alignment => {:vertical => :center}
    default = styles.add_style :sz => 9
    @default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :b => true,:sz => 9
    @default1 = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :sz => 9,:alignment => { :horizontal => :right,
                                              :wrap_text => true}
    @combing = styles.add_style :alignment => { :horizontal => :center,
                                              :vertical => :center ,
                                              :wrap_text => true}
    @table = styles.add_style :bg_color => 'FF9933', :fg_color => 'ff', :b => true,:border => { :style => :thin, :color => "00" },:sz => 9,:paper_height=>'100mm',:alignment => { :horizontal => :center,
                                              :vertical => :center ,
                                              :wrap_text => true}
    @table_default = styles.add_style :fg_color => '00',:sz => 9,:border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :center,
                                              :vertical => :center ,
                                              :wrap_text => true}

    wb.add_worksheet(:name => 'Downtown traffic') do  |ws|
      @ws=ws
      @ws.merge_cells "A1:B1"
      sheel_images
      @ws.add_row ['','','  爱点击广告服务排期表'], :style => [@combing,@combing,title]
      @ws.add_row ['客户名称', @order.client.clientname,'','', @str1], :style => default
      @ws.add_row ['产品名称', t(@order.product_type),'','', @str2], :style => default
      @ws.add_row ['下单客户', "#{@order.client.clientcontact}",'','', @str3], :style => default
      @ws.add_row ['销售', "#{@order.user.real_name}",'','', @str4], :style =>default
      @ws.add_row ['报价单制作日期', "#{@order.created_at.localtime.strftime('%Y-%m-%d')}",'','', @str5], :style => default
      @ws.add_row ['广告执行期', @order.start_date.to_s+'至'+@order.ending_date.to_s,'','',@str6], :style => default
      @ws.add_row ['广告目标链接', 'TBD','','', @str7], :style => default
      @ws.add_row ['投放地域', @order.city,'','', @str8], :style => default
      @ws.add_row ['','','','', @str9], :style => default
      empety_rows(3)
      @ws.add_row ["总花费(元)" , @order.budget.to_f], :style => [@default,@default1]
      @ws.add_row ["承诺曝光数" , @order.budget.to_f*1000/(@order.cost*@order.discount)], :style => [@default,@default1]
      @ws.add_row ["承诺#{@order.cost_type}(元)" , @order.cost*@order.discount], :style => [@default,@default1]
      empety_rows(3)
      @ws.add_row ['投放方式',t(@order.product_type),'行业','投放天数','刊例价（元）','折扣',@order.cost_type.to_s+' (元)','日均曝光数','总曝光数','刊例总价','净总价'], :style => @table
      @ws.add_row ['爱点击媒体采购',@order.product_type=="MEDIA_BUYING" ? @order.extra_website : @order.interest_crowd , @order.industry.name, @order.period , @order.cost ,(@order.discount*100).to_i.to_s+'%',@order.cost*@order.discount,
        @order.budget.to_f*1000/(@order.cost*@order.discount)/@order.period , @order.budget.to_f*1000/(@order.cost*@order.discount) , @order.budget.to_f/@order.discount,@order.budget.to_f] , :style => @table_default
      @ws.add_row ['总计','','','','','','','','','',@order.budget.to_f], :style => @table_default
      empety_rows(1)
      @ws.add_row ['AdChina  Sign-off','','','','Client  Sign-off','','','','',''], :style => default
      empety_rows(2)
      @ws.add_row ['_____________________________________________________________________','','','','__________________________________________________________________________________________________________________________________________','','','','',''], :style => default
      @ws.column_info[0].width = 21
      @ws.column_info[1].width = 17
      @ws.column_info[2].width = 16
      @ws.column_info[3].width = 15
      @ws.column_info[4].width = 14
      @ws.column_info[5].width = 14
      @ws.column_info[6].width = 13
      @ws.column_info[7].width = 13
      @ws.column_info[8].width = 13
      @ws.column_info[9].width = 13
      @ws.column_info[10].width = 9
      @ws.rows[0].height= 50
      @ws.rows[19].height= 25
      @ws.rows[20].height= 28
      @ws.merge_cells "A27:B27"
      @ws.merge_cells "E27:K27"
    end
  end
  file_name = "./public/schedules/#{random}-iclick.xlsx"
  my_package.serialize file_name
  @order.schedule_attachment = File.open(file_name)
  @order.save
  File.delete(file_name)
 end
 

end
