# coding: utf-8

module Generator
  class ExecuterGenerator

    attr_reader :excel,:workbook,:order,:worksheet

    attr_accessor :styles
    include ActionView::Helpers::NumberHelper

    require 'find'
    include ActionView
    include AbstractController::Translation
    def init_styles
      # Define default style
      default_style = {:sz=>10,:b => true,:bg_color => "FFF",:font_name=>"宋体",:alignment=>{:vertical => :center,:wrap_text => false,:horizontal => :center}  }
      border = {:border => Axlsx::STYLE_THIN_BORDER}
      # Define every area style
      _style =  {:head_title => default_style.merge(border).merge({:sz=>26}),
                 #:head_body => default_style.merge(border),
                 #:title => default_style.merge({:sz=>26}),
                 :info => default_style.merge({:b => false,:border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :center,:vertical => :center ,:wrap_text => true}}),
                 :sign => default_style.merge({:border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :left,:vertical => :center ,:wrap_text => true}}),
                 #:price => default_style.merge(border).merge({}),
                 #:operation_title => default_style.merge(border).merge({:bg_color => 'FF9933',:sz=>10, :fg_color => 'ff', :b => true,:border => { :style => :thin, :color => "00" },:alignment=>{:vertical => :center,:wrap_text => false, :horizontal => :center }}),
                 #:operation_body => default_style.merge(border).merge({:alignment=>{:vertical => :center,:wrap_text => true, :horizontal => :center }}),
                 :b_color => default_style.merge(border).merge({:bg_color => 'FF9933', :fg_color => '00', :border => { :style => :thin, :color => "00" },:sz => 10,:paper_height=>'100mm',:alignment => { :horizontal => :center,:vertical => :center ,:wrap_text => true}}),
                 :y_color => default_style.merge(border).merge({:bg_color => 'ffff00', :fg_color => '00', :b => true,:border => { :style => :thin, :color => "00" },:sz => 10,:paper_height=>'100mm',:alignment => { :horizontal => :center,:vertical => :center ,:wrap_text => true}}),
                 :left_y_color => default_style.merge(border).merge({:bg_color => 'ffff00', :fg_color => '00', :b => true,:border => { :style => :thin, :color => "00" },:sz => 10,:paper_height=>'100mm',:alignment => { :horizontal => :left,:vertical => :center ,:wrap_text => true}}),
                 :right_style => default_style.merge(border).merge({:border => { :style => :thin, :color => "00" },:b => false,:sz => 10,:paper_height=>'100mm',:alignment => { :horizontal => :right,:vertical => :center ,:wrap_text => true}}),
                 :not_style => {}
                }

      _style.each_pair {| key, value | self.styles[key] = workbook.styles.add_style(value); }

    end

    def init_size
      worksheet.rows[0].height = 53
      worksheet.column_info[0].width = 28
      worksheet.column_info[1].width = 28
    end

    def initialize(order)
      @excel ||= Axlsx::Package.new
      @workbook ||= @excel.workbook
      @worksheet = @workbook.add_worksheet(:name => 'Downtown traffic')
      @order ||= order
      @styles ||= Hash.new
      init_styles
    end
    # def total_ad_rows
    #   all_ad_rows = 0
    #   order.advertisements.each do |ad|
    #     all_ad_rows += (ad.admeasure_state && ad.admeasure.to_a.size.to_i > 0 ? (ad.admeasure.to_a.size.to_i - 1) : 0)  + (ad.diff_ctr? ? 6 : 5)
    #   end
    #   all_ad_rows
    # end

    def total_ad_rows
      all_ad_rows = 0
      order.advertisements.each do |ad|
        ad_admeasure_rows = ad.admeasure.to_a.select{|a| a[1].present?}.size.to_i
        all_ad_rows += (ad.admeasure_state.present? && ad_admeasure_rows > 0 ? (ad_admeasure_rows - 1) : 0)  + (ad.diff_ctr? ? 7 : 6)
      end
      all_ad_rows
    end
    

    def generate_executer     
        merge_rows
        generate_head
        generate_advertiser
        empety_rows(2)
        generate_order
        empety_rows(2)
        generate_base
        empety_rows(2)
        ad_base
        empety_rows(2)
        generate_detail
        empety_rows(2)
        generate_order_nonuniform
        empety_rows(2)
        init_size
        # if @order.gps.size >0
        # generate_sov(@workbook)
        # end
        tmp_directory = File.join(Rails.root,"tmp/executer/")
        tmp_filename = "#{order.id.to_s}_#{DateTime.now.to_i}.xlsx"
        FileUtils::mkdir_p(tmp_directory) unless File.directory?(tmp_directory)
        excel.serialize File.join(tmp_directory,tmp_filename)
        order.executer_attachment = File.open(File.join(tmp_directory,tmp_filename)) 
        order.save(:validate=>false)
        File.delete(File.join(tmp_directory,tmp_filename)) if File.exists?(File.join(tmp_directory,tmp_filename))
    end



    private
    
      def empety_rows(i)
        i.times{worksheet.add_row}
      end

      # def merge_rows
      #   a=21+ total_ad_rows
      #   (3..19).each do |i|
      #     worksheet.merge_cells("B#{i}:E#{i}") unless %w{11}.include? i.to_s
      #   end
      #   (a+1..(a+14)).each do |i|
      #     worksheet.merge_cells("B#{i}:E#{i}") unless a+3 == i
      #   end
      # end

    def merge_rows
      a=36+ total_ad_rows
      (3..30).each do |i|
        worksheet.merge_cells("B#{i}:E#{i}") unless %w{9 17}.include? i.to_s
      end
      (a+1..(a+14)).each do |i|
        worksheet.merge_cells("B#{i}:E#{i}") unless a+3 == i || i == a+14
      end

    end

      def generate_head
        worksheet.add_image(:image_src => File.join(Rails.root,"app/assets/images","logo.png"), :noSelect => true, :noMove => true ) do |image|
          image.width = 190
          image.height = 63 
          image.start_at 0,0
        end
        worksheet.merge_cells "B1:E1"
        worksheet.add_row ['',I18n.t('order.executer_excel.sheet_title_iclick'),'','',''], :style => styles[:head_title]
      end

      def generate_advertiser
        worksheet.merge_cells "A2:E2"
        worksheet.add_row [I18n.t('order.executer_excel.sheet_advertiser_advertiser'),'','','',''], :style => [styles[:b_color]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_advertiser_advertiser'),order.client.clientname,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_advertiser_brand'),order.client.brand,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_advertiser_agency'),order.client.channel_name.present? ? order.client.channel_name : '-' ,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_advertiser_industry'),I18n.locale == :en ? (order.client.industry.present? ? order.client.industry.name : "-") : (order.client.industry_name.present? ? order.client.industry_name : '-'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
      end


      def generate_order
        # worksheet.merge_cells "A2:E2"
        worksheet.merge_cells "A9:E9"
        worksheet.add_row [I18n.t('order.executer_excel.sheet_order_order_detail'),'','','',''], :style => [styles[:b_color]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_order_order_bopnum'),Order.display_item_class(order.business_opportunity_number),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_order_order_id'),order.code,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        #worksheet.add_row [I18n.t('order.executer_excel.sheet_order_client_name'),order.client.clientname,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_order_order_name'),order.title,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_order_order_type'),I18n.t('order.executer_excel.sheet_order_order_type1'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_msa_framwork'),(order.whether_msa == true && order.msa_contract.present?) ? order.msa_contract : '-','','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_order_order_owner'),order.share_order_user,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        #worksheet.add_row [I18n.t('order.executer_excel.sheet_order_create_date'),order.created_at.localtime.to_s(:db),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_order_share_with'),Group.where(Group.group_conditions(order.share_order_groups.pluck(:share_id))).pluck(:group_name).join(",") ,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
      end

      def generate_base
        #worksheet.merge_cells "A11:E11"
        worksheet.merge_cells "A19:E19"
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_base_info'),'','','',''], :style => [styles[:b_color]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_total_budget',currency: "#{order.budget_currency}"),number_with_precision(order.budget, :precision => 2, :delimiter => ","),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_bonus_package'),order.free_tag.to_s == "1" ? I18n.t('order.executer_excel.sheet_base_bonus_package_reason_yes', :free_reason => "#{ order.free_notice}") : I18n.t('order.executer_excel.sheet_base_bonus_package_reason_no'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_plan_startdate'),order.start_date.try(:strftime, '%Y/%m/%d'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_plan_enddate'),order.ending_date.try(:strftime, '%Y/%m/%d'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_exclude_date'),order.exclude_date.length==0 ? '-' : order.exclude_date.join(',') ,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_total_day'),order.period.to_s + I18n.t('order.executer_excel.sheet_base_total_day_number'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_nonuniform'),order.whether_nonuniform == true ? I18n.t('order.executer_excel.sheet_detail_yes') : I18n.t('order.executer_excel.sheet_detail_no'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_geo_target'),order.map_country.to_s+" " + (order.china_regional? ? order.map_city.to_s : ""),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_msa_framwork'), (order.whether_msa == true && order.msa_contract.present?) ? order.msa_contract : '-', '','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_target_goal'),order.convert_goal? ? order.convert_goal : "-" ,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_audience_group'),order.interest_crowd? ? order.interest_crowd : '-' ,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_3rd_party'),order.whether_monitor? ? order.whether_monitor : '-','','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_base_website_blacklist'),order.blacklist_website? ? order.blacklist_website : "-" ,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
      end

      def ad_base
        # worksheet.merge_cells "A20:E20"
        worksheet.merge_cells "A35:E35"
        worksheet.add_row [I18n.t('order.executer_excel.sheet_ad_base_info'),'','','',''], :style => [styles[:b_color]]
        # worksheet.merge_cells("B21:E21")
        worksheet.merge_cells("B36:E36")
        worksheet.add_row [I18n.t('order.executer_excel.sheet_ad_base_category'),I18n.t('order.executer_excel.sheet_ad_base_delievery'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        # worksheet.add_row ['广告形式','预算','单价','非标准KPI(IMP/CLICKS/CTR)','配送点击'],:style => [styles[:sign],styles[:sign],styles[:sign],styles[:sign],styles[:info]]
        # ad_start_row = 22
        ad_start_row = 37
        for advertisement  in order.advertisements
          admeasure_rows = advertisement.admeasure.to_a.select{|a| a[1].present?}.size.to_i
          #ad_rows = (advertisement.admeasure_state && advertisement.admeasure.to_a.size.to_i > 0 ? (advertisement.admeasure.to_a.size.to_i - 1) : 0) + (advertisement.diff_ctr? ? 5 : 4)
          ad_rows = (advertisement.admeasure_state? && admeasure_rows > 0 ? (admeasure_rows - 1) : 0) + (advertisement.diff_ctr? ? 6 : 5)
          worksheet.merge_cells("A#{ad_start_row}:A#{ad_start_row + ad_rows}")
          (0..ad_rows).each do |i|
            worksheet.merge_cells("B#{ad_start_row + i}:C#{ad_start_row + i}")
            worksheet.merge_cells("D#{ad_start_row + i}:E#{ad_start_row + i}")
          end
          worksheet.add_row [advertisement.product ? (I18n.locale == :en ? (advertisement.product.en_name.present? ? advertisement.product.en_name : '-') : advertisement.product.name) : advertisement.ad_type , I18n.t('order.executer_excel.sheet_ad_base_product_category'), '', advertisement.product.present? ? I18n.locale == :en ? (advertisement.product.product_type_en.present? ? advertisement.product.product_type_en : '-') : advertisement.product.product_type_cn : "-", ''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
          worksheet.add_row ['', I18n.t('order.executer_excel.sheet_ad_base_total_budget',currency: "#{advertisement.budget_currency_show}"), '', number_with_precision(advertisement.budget, :precision => 2, :delimiter => ","), ''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
          if advertisement.admeasure_state?
            dmeasure_datas = (I18n.locale == :en ? (advertisement.admeasure_en? ? advertisement.admeasure_en[0..-2].select{|a| a[1].present?} : []) : advertisement.admeasure[0..-2].select{|a| a[1].present?})
            dmeasure_datas.each do |distribution|
              city = distribution[0].present? ? distribution[0] : "-"
              city_budget_distribution = distribution[1].to_f / advertisement.budget_ratio("super")
              worksheet.add_row ['', '  '+ city, '', number_with_precision((advertisement.budget.to_f * city_budget_distribution), :precision => 2, :delimiter => ","), ''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
            end
          end
          
          worksheet.add_row ['', I18n.t('order.executer_excel.sheet_ad_base_settle_amount',currency: "#{advertisement.budget_currency_show}"), '', (advertisement.cpm? ? 'CPM: ' + number_with_precision(advertisement.cost, :precision => 2, :delimiter => ",") : 'CPC: ' + number_with_precision(advertisement.cost, :precision => 2, :delimiter => ",")) , ''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]

          if advertisement.diff_ctr?
            worksheet.add_row ['', 'CTR', '', number_with_precision(advertisement.planner_ctr, :precision => 2, :delimiter => ",") + "%" + "(" + I18n.t('order.executer_excel.sheet_ad_base_normal_ctr') + ":" + number_with_precision(advertisement.forecast_ctr, :precision => 2, :delimiter => ",") + "%)", ''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
          end
          worksheet.add_row ['', I18n.t('order.executer_excel.sheet_ad_base_unnormal_kpi'), '', advertisement.nonstandard_kpi? ? advertisement.nonstandard_kpi : '-', ''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
          worksheet.add_row ['', I18n.t('order.executer_excel.sheet_ad_base_bonus_click'), '', advertisement.planner_clicks.present? ? advertisement.planner_clicks : '-', ''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
          worksheet.add_row ['', I18n.t('order.executer_excel.sheet_ad_base_price_remark'), '', advertisement.price_presentation? ? advertisement.price_presentation : '-', ''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
          ad_start_row += (ad_rows + 1)
         # worksheet.add_row [I18n.t(advertisement.ad_platform)+ " - " +I18n.t(advertisement.ad_type),number_with_precision(advertisement.budget, :precision => 2, :delimiter => ","), (advertisement.cpm? ? 'CPM: ' : 'CPC: ') + number_with_precision(advertisement.cost, :precision => 2, :delimiter => ",") + order.budget_currency  ,advertisement.nonstandard_kpi, advertisement.planner_clicks],:style => [styles[:info]]
        end
      end

      def generate_detail
        # worksheet.merge_cells "A#{22+total_ad_rows+2}:E#{22+total_ad_rows+2}"
        worksheet.merge_cells "A#{37+total_ad_rows+2}:E#{37+total_ad_rows+2}"
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_delievery'),'','','',''], :style => [styles[:b_color]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_landing_page'),order.landing_page? ? order.landing_page : '-' ,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_frequency'),order.frequency.to_i != 0 && order.frequency_limit == true ? "#{order.frequency? ? order.frequency : '-'} " + I18n.t('order.executer_excel.sheet_detail_fre_content') : "",'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_keywords'),order.keywords? ? order.keywords : '-','','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info],styles[:info],styles[:info]]
        #worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_3rd_monitor'),order.whether_monitor == true ? I18n.t('order.executer_excel.sheet_detail_yes') : I18n.t('order.executer_excel.sheet_detail_no'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        #worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_3rd_business'),order.description.to_s != '' ? order.description : order.third_monitor,'',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]] if order.whether_monitor == true
        #worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_3rd_code'),order.third_monitor_code,'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]] if order.whether_monitor == true
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_xmo_code'),order.xmo_code == true ? I18n.t('order.executer_excel.sheet_detail_yes') : I18n.t('order.executer_excel.sheet_detail_no'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_creative_asstets'),order.client_material == true ? I18n.t('order.executer_excel.sheet_detail_yes') : I18n.t('order.executer_excel.sheet_detail_no'),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_report_template'),I18n.t("report_template_#{order.report_template}"),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_report_period'),order.report_period.split(",").map{|period| I18n.t("report_period_#{period}")}.join(","),'','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_detail_screenshot'),order.screenshot? ? order.screenshot : '-','','',''],:style => [styles[:sign],styles[:info],styles[:info],styles[:info],styles[:info]]
        # worksheet.add_row ['频次限制',order.frequency+" 每天 当前媒体计划"],:style => [styles[:sign],styles[:info]]
        # worksheet.add_row ['关键词',order.keywords],:style => [styles[:sign],styles[:info]]
        # worksheet.add_row ['是否添加第三方监测',I18n.t(order.whether_monitor.to_s)],:style => [styles[:sign],styles[:info]]
        # worksheet.add_row ['第三方监测服务商',order.third_monitor],:style => [styles[:sign],styles[:info]]
        # worksheet.add_row ['是否添加XMO网站监测代码',I18n.t(order.xmo_code.to_s)],:style => [styles[:sign],styles[:info]]
        # worksheet.add_row ['客户是否提供素材',I18n.t(order.client_material.to_s)],:style => [styles[:sign],styles[:info]]
        # worksheet.add_row ['报表模版',I18n.t(order.report_template,:scope =>"REPORTTEMPLATE") ],:style => [styles[:sign],styles[:info]]
        # worksheet.add_row ['报表周期',order.report_period.split(',').map{|period| I18n.t(period,:scope =>"REPORTPERIOD")}.join(',')   ],:style => [styles[:sign],styles[:info]]
        # worksheet.add_row ['特殊拷屏要求',order.screenshot],:style => [styles[:sign],styles[:info]]
      end

      def generate_order_nonuniform
        if order.whether_nonuniform == false && order.order_nonuniforms.present?
          nonuniform_start_row = 37+total_ad_rows+13
          worksheet.merge_cells "A#{nonuniform_start_row}:E#{nonuniform_start_row}"
          worksheet.add_row [I18n.t('order.executer_excel.sheet_nonuniform'),'','','',''], :style => [styles[:b_color]]
          worksheet.merge_cells "C#{nonuniform_start_row + 1}:E#{nonuniform_start_row + 1}"
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_delivery_start_date'),I18n.t('order.schedule_excel.sheet_delivery_end_date'),I18n.t('order.schedule_excel.sheet_delivery_budget',currency: "#{order.budget_currency}"),'',''], :style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
          have_order_nonuniforms = order.order_nonuniforms.present? ? order.order_nonuniforms : []
          have_order_nonuniforms.each_with_index do |on, i|
            worksheet.merge_cells("C#{nonuniform_start_row+1 + i+1}:E#{nonuniform_start_row+1 + i+1}")
            worksheet.add_row [on.start_date.try(:strftime, '%Y/%m/%d'),
                               on.end_date.try(:strftime, '%Y/%m/%d'),
                               number_with_precision(on.nonuniform_budget, :precision => 2, :delimiter => ","),
                               '',
                               ''
                              ],:style => [styles[:sign],styles[:sign],styles[:sign],styles[:info],styles[:info]]
          end
        end
      end







    def random
      request_id = ([*('A'..'Z'), *('a'..'z'), *('0'..'9')]-%w(0 1 h I O)).sample(14).join
      return request_id
    end

    def generate_logo
      @ws.add_image(:image_src => File.join(Rails.root, "app/assets/images", "logo.png"), :noSelect => true, :noMove => true) do |image|
        image.width = 190
        image.height = 63
        image.start_at 0, 0
      end
    end
  end
end
