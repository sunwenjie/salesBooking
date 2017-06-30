# coding: utf-8

module Generator
  class ExcelGenerator

    attr_reader :excel,:workbook,:order,:worksheet

    attr_accessor :styles

    include ActionView::Helpers::NumberHelper
    
    def init_styles
      # Define default style
      default_style = {:sz=>9,:bg_color => "FFF",:font_name=>"宋体",:alignment=>{:vertical => :center,:wrap_text => false}  }
      border = {:border => Axlsx::STYLE_THIN_BORDER}
      # Define every area style
      _style =  {:logo => default_style.merge({}),
                 :notification => default_style.merge({}),
                 :title => default_style.merge({:sz=>26}),
                 :info => default_style.merge({:alignment=>{:vertical => :center,:wrap_text => false, :horizontal =>:left }}),
                 :sign => default_style.merge({}),
                 :red_sign => default_style.merge({:fg_color =>'FF0000'}),
                 :price => default_style.merge(border).merge({}),
                 :operation_title => default_style.merge(border).merge({:bg_color => 'D4D4D4',:sz=>10, :fg_color => '00', :b => true,:border => { :style => :thin, :color => "00" },:alignment=>{:vertical => :center,:wrap_text => false, :horizontal => :center }}),
                 :operation_summary => default_style.merge(border).merge({:bg_color => 'E3C8C4',:sz=>10, :fg_color => '00', :b => true,:border => { :style => :thin, :color => "00" },:alignment=>{:vertical => :center,:wrap_text => false, :horizontal => :center }}),
                 :operation_body => default_style.merge(border).merge({:alignment=>{:vertical => :center,:wrap_text => true, :horizontal => :center }}),
                 :operation_body_red => default_style.merge(border).merge({:fg_color =>'FF0000',:alignment=>{:vertical => :center,:wrap_text => true, :horizontal => :center }}),
                 :operation_body_nonuniforms => default_style.merge(border).merge({:alignment=>{:vertical => :center,:wrap_text => true, :horizontal => :left }})

      }

      _style.each_pair {| key, value | self.styles[key] = workbook.styles.add_style(value); }

    end

    def init_size
      worksheet.rows[0].height = 50
      [*(0..10)].each do |i|
        #worksheet.column_info[i].width = 20
      end
      worksheet.column_info[1].width = 30
      worksheet.rows[20].height = 25
    end

  

    def initialize(order)
      @excel ||= Axlsx::Package.new
      @workbook ||= @excel.workbook
      @worksheet = @workbook.add_worksheet(:name => I18n.t('order.schedule_excel.sheet_name_schedule'))
      @order ||= order
      @styles ||= Hash.new
      init_styles
    end

    

    def generate_schedule     
        generate_logo
        generate_title
        generate_info
        empety_rows(4)
        generate_price
        # empety_rows(3)
        # generate_stablize_delivery
        empety_rows(3)
        generate_operation
        empety_rows(1)
        generate_sign
        generate_notification
        init_size
        tmp_directory = File.join(Rails.root,"tmp/schedules/")
        tmp_filename = "#{order.id.to_s}_#{DateTime.now.to_i}.xlsx"
        FileUtils::mkdir_p(tmp_directory) unless File.directory?(tmp_directory)
        excel.serialize File.join(tmp_directory,tmp_filename)
        order.schedule_attachment = File.open(File.join(tmp_directory,tmp_filename)) 
        order.save
        File.delete(File.join(tmp_directory,tmp_filename)) if File.exists?(File.join(tmp_directory,tmp_filename))

    end

    private
    
      def empety_rows(i)
        i.times{worksheet.add_row}
      end

      def generate_logo
        worksheet.merge_cells "A1:B1"
        worksheet.add_image(:image_src => File.join(Rails.root,"app/assets/images","logo.png"), :noSelect => true, :noMove => true ) do |image|
          image.width = 190
          image.height = 63 
          image.start_at 0,0
        end
      end

      def generate_notification

        notification = [I18n.t('order.schedule_excel.sheet_notification_1'),
                        I18n.t('order.schedule_excel.sheet_notification_2'),
                        I18n.t('order.schedule_excel.sheet_notification_3'),
                        I18n.t('order.schedule_excel.sheet_notification_4'),
                        I18n.t('order.schedule_excel.sheet_notification_5'),
                        I18n.t('order.schedule_excel.sheet_notification_6'),
                        I18n.t('order.schedule_excel.sheet_notification_7'),
                        I18n.t('order.schedule_excel.sheet_notification_8'),
                        I18n.t('order.schedule_excel.sheet_notification_9')]

         notification.each_with_index do |item, index|
            worksheet.rows[index+1].cells[4].value = item
            worksheet.rows[index+1].cells[4].style = styles[:notification]
         end
      end


      def generate_title
        worksheet.add_row ['','',I18n.t('order.schedule_excel.sheet_title_iclick')], :style => styles[:title]
      end

      def generate_info
          worksheet.add_row [I18n.t('order.executer_excel.sheet_order_order_bopnum'),Order.display_item_class(order.business_opportunity_number),'','',''],:style => styles[:info]
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_order_id'), order.code,'','',''], :style => styles[:info]
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_order_name'), order.title,'','',''], :style => styles[:info]
          worksheet.add_row [I18n.t('order.executer_excel.sheet_order_order_type'),I18n.t('order.executer_excel.sheet_order_order_type1'),'','',''],:style => styles[:info]
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_client_name'), (order.client.present? ? order.client.clientname : ''),'','',''], :style => styles[:info]
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_brand'),Client.display_item_class(order.client.try(:brand)),'','',''], :style => styles[:info]
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_agency'),order.client.try(:channel_name).present? ? order.client.channel_name : '-' ,'','',''], :style => styles[:info]

          worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_industry'),I18n.locale == :en ? (order.client.try(:industry).present? ? order.client.industry.name : "-") : (order.client.industry_name.present? ? order.client.industry_name : '-'),'','',''], :style => styles[:info]
          #worksheet.add_row ['商务登记号', '','','',''], :style => styles[:info]
          #worksheet.add_row ['下单客户', "#{order.client.clientcontact}",'','',''], :style => styles[:info]
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_msa_framwork'), (order.whether_msa == true && order.msa_contract.present?) ? order.msa_contract : '-', '','',''], :style => styles[:info]
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_sale'), "#{order.share_order_user}",'','',''], :style => styles[:info]
          worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_create_date'), "#{order.created_at.localtime.strftime('%Y/%m/%d')}",'','',''], :style => styles[:info]
          #worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_execute_date'), order.start_date.to_s+'~'+order.ending_date.to_s,'','',''], :style => styles[:info]
          #worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_exclude_date'), order.exclude_date.join(","),'','',''], :style => styles[:info]
          #worksheet.add_row ['广告目标链接', 'TBD','','',''], :style => styles[:info]
          #worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_geo'), order.map_country.to_s + (order.china_regional? ? order.map_city.to_s : "") ,'','',''], :style => styles[:info]
          worksheet.add_row ['','','','',''], :style => styles[:info]
          #worksheet.add_row ["#{order.free_tag.present? ? I18n.t('order.schedule_excel.sheet_info_remark') : '' }",'','','',''], :style => styles[:red_sign]
      end

      def generate_sign
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_sign_part_a'),'','','',I18n.t('order.schedule_excel.sheet_sign_part_b'),'','','','',''], :style => styles[:sign]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_sign_representatives'),'','','',I18n.t('order.schedule_excel.sheet_sign_representatives'),'','','','',''], :style => styles[:sign]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_sign_stamp'),'','','',I18n.t('order.schedule_excel.sheet_sign_stamp'),'','','','',''], :style => styles[:sign]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_sign_date'),'','','',I18n.t('order.schedule_excel.sheet_sign_date'),'','','','',''], :style => styles[:sign]
      end

      def generate_price
        #worksheet.add_row [I18n.t('order.schedule_excel.sheet_price_industry') , "#{order.industry_name}"], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_price_total_budget',currency: "#{order.budget_currency}") , "#{number_with_precision(order.budget, :precision => 2, :delimiter => ",")}"], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_bonus_package'),order.free_tag.to_s == "1" ? I18n.t('order.executer_excel.sheet_base_bonus_package_reason_yes', :free_reason => "#{ order.free_notice}") : I18n.t('order.executer_excel.sheet_base_bonus_package_reason_no')], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_start_date'),order.start_date.try(:strftime, '%Y/%m/%d')], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_end_date'),order.ending_date.try(:strftime, '%Y/%m/%d')], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_exclude_date'), order.exclude_date? ? order.exclude_date.join(",") : '-'], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_price_total_day') , "#{order.period.to_s}" + I18n.t('order.executer_excel.sheet_base_total_day_number')], :style => styles[:info]
        worksheet.add_row [I18n.t('order.executer_excel.sheet_nonuniform') , order.whether_nonuniform == true ? I18n.t('order.executer_excel.sheet_detail_yes') : I18n.t('order.executer_excel.sheet_detail_no')], :style => styles[:info]
        generate_stablize_delivery
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_info_geo'),order.china_region_all? ? (order.map_country.to_s) : (order.map_country.to_s+ " " + (order.china_regional? ? order.map_city.to_s : ""))], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_target_goal')  , order.convert_goal? ? order.convert_goal : "-"], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_price_audience_group')  , Order.display_item_class(order.interest_crowd)], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_3rd_monitor')  , order.whether_monitor? ? order.whether_monitor : '-'], :style => styles[:info]
        worksheet.add_row [I18n.t('order.schedule_excel.sheet_price_blacklist') ,"#{Order.display_item_class(order.blacklist_website)}"], :style => styles[:info]
      end

      def generate_stablize_delivery
        if order.whether_nonuniform == false && order.order_nonuniforms.present?

          have_order_nonuniforms = order.order_nonuniforms.present? ? order.order_nonuniforms : []
          total_nonuniforms = have_order_nonuniforms.size
          have_order_nonuniforms.each do |on|
            worksheet.add_row [I18n.t('order.executer_excel.sheet_nonuniform_date'),on.start_date.try(:strftime, '%Y/%m/%d'),
                               on.end_date.try(:strftime, '%Y/%m/%d'),
                               number_with_precision(on.nonuniform_budget, :precision => 2, :delimiter => ",")
                              ],:style => styles[:operation_body_nonuniforms]
          end

          worksheet.merge_cells "A25:A#{25+total_nonuniforms -1}"

        end
      end

      def generate_operation
        for advertisement in order.advertisements
          check_add_row(advertisement)
          if (advertisement.planner_clicks.present? && advertisement.planner_clicks.to_i != 0)
            if advertisement.cost_type == "CPE"
              from_array = ['','','','','','', I18n.t('order.schedule_excel.sheet_operation_bonus_click'), advertisement.planner_clicks]
            else
              from_array = ['','','','','','','','','','','', I18n.t('order.schedule_excel.sheet_operation_bonus_click'), advertisement.planner_clicks]
            end
            
            worksheet.add_row array_delete(from_array,get_cpm_cpc_cols(advertisement)), :style => styles[:operation_body]
          end
        end
        if advertisement.present? && advertisement.cost_type == "CPE"
          from_array = [I18n.t('order.schedule_excel.sheet_column_content_total') ,'','','','','','','',number_with_precision(order.budget, :precision => 2, :delimiter => ",")]
        else
          from_array = [I18n.t('order.schedule_excel.sheet_column_content_total'),'','','','','','','','','','','','',number_with_precision(order.budget, :precision => 2, :delimiter => ",")]
        end
        
        worksheet.add_row array_delete(from_array,get_cpm_cpc_cols(advertisement)) , :style => styles[:operation_body]
      end


      def check_add_row(advertisement)
        p 99999887766
        p advertisement
        @cost_type = (advertisement.cost_type == "CPE" ? "cpe" : "uncpe")
        @admeasure_state = (advertisement.admeasure_state ? "admeasure" : "unadmeasure")
        from_array = send(@cost_type+"_row",advertisement)
        worksheet.add_row array_delete(from_array,get_cpm_cpc_cols(advertisement)) , :style => styles[:operation_title]
        send(@cost_type+"_"+@admeasure_state,advertisement)
      end


      def cpe_row(advertisement)
              [   I18n.t('order.schedule_excel.sheet_column_product_category'),
                  I18n.t('order.schedule_excel.sheet_column_category'),
                  I18n.t('order.schedule_excel.sheet_column_location'),
                  I18n.t('order.schedule_excel.sheet_column_card_price',currency: "#{order.budget_currency}"),
                  I18n.t('order.schedule_excel.sheet_column_discount'),
                  "#{advertisement.cost_type}" + I18n.t('order.schedule_excel.sheet_column_sell_price') + "(#{order.budget_currency})",
                  I18n.t('order.schedule_excel.sheet_column_interactive'),
                  I18n.t('order.schedule_excel.sheet_column_total_card_price'),
                  I18n.t('order.schedule_excel.sheet_column_total_price',currency: "#{order.budget_currency}")]
      end

      
      def uncpe_row(advertisement)
             [ I18n.t('order.schedule_excel.sheet_column_product_category'),
               I18n.t('order.schedule_excel.sheet_column_category'),
               I18n.t('order.schedule_excel.sheet_column_location'),
               I18n.t('order.schedule_excel.sheet_column_card_price',currency: "#{order.budget_currency}"),
               I18n.t('order.schedule_excel.sheet_column_discount'),
               #"#{advertisement.cost_type}(#{order.budget_currency})",
               "#{advertisement.cost_type}" + I18n.t('order.schedule_excel.sheet_column_sell_price') + "(#{order.budget_currency})",
               "#{advertisement.cpm? ? I18n.t('order.schedule_excel.sheet_column_avg_impl') : I18n.t('order.schedule_excel.sheet_column_avg_click')}",
               "#{advertisement.cpm? ? I18n.t('order.schedule_excel.sheet_column_total_impl') : I18n.t('order.schedule_excel.sheet_column_total_click')}",
               I18n.t('order.schedule_excel.sheet_column_estimate_ctr'),
               "#{advertisement.cpm? ? I18n.t('order.schedule_excel.sheet_column_estimate_cpc',currency_cpc: "#{order.budget_currency}") : I18n.t('order.schedule_excel.sheet_column_estimate_cpm',currency_cpm: "#{order.budget_currency}")}",
               "#{advertisement.cpm? ? I18n.t('order.schedule_excel.sheet_column_estimate_avg_click') : I18n.t('order.schedule_excel.sheet_column_estimate_avg_impl')}",
               "#{advertisement.cpm? ? I18n.t('order.schedule_excel.sheet_column_estimate_click') : I18n.t('order.schedule_excel.sheet_column_estimate_impl')}",
               I18n.t('order.schedule_excel.sheet_column_total_card_price'),
               I18n.t('order.schedule_excel.sheet_column_total_price',currency: "#{order.budget_currency}")]
      end

      def array_delete(from_array,delete_index)
        new_array = []
        from_array.each_with_index do |arr,index|
          new_array << arr if !delete_index.include? index
        end
        return new_array
      end

      def get_cpm_cpc_cols(advertisement)
        delete_arry = []
        if advertisement.present?
        if advertisement.cpm?
          delete_arry << [7,8]  if order.check_download_attr['ctr'] == "false"
          delete_arry << [9,10]  if order.check_download_attr['click'] == "false"
          delete_arry << [5,6]  if order.check_download_attr['impression'] == "false"
        elsif advertisement.cpc?
          delete_arry << [7,8]  if order.check_download_attr['ctr'] == "false"
          delete_arry << [5,6]  if order.check_download_attr['click'] == "false"
          delete_arry << [9,10]  if order.check_download_attr['impression'] == "false"
        end
        end
        return delete_arry.flatten
      end



      def cpe_admeasure(advertisement)

       (I18n.locale == :en ? advertisement.admeasure_en[0..-2].select{|a| a[1].present?} : advertisement.admeasure[0..-2].select{|a| a[1].present?}).each do |distribution|
                      city = distribution[0]
                      city_budget_distribution = distribution[1].to_f / advertisement.budget_ratio("super")
                      worksheet.add_row [
                                        advertisement.product.present? ? I18n.locale == :en ? (advertisement.product.product_type_en.present? ? advertisement.product.product_type_en : '-') : advertisement.product.product_type_cn : "-" ,
                                        advertisement.product ? I18n.locale == :en ? (advertisement.product.en_name.present? ? advertisement.product.en_name : '-') : advertisement.product.name : I18n.t(advertisement.ad_type) ,
                                        city,
                                        number_with_precision(advertisement.special_ad? ? "-" : advertisement.public_price, :precision => 2, :delimiter => ","),
                                        advertisement.special_ad? ? "-" : number_with_precision(advertisement.discount, :precision => 2, :delimiter => ",")+'%',
                                        "#{number_with_precision(advertisement.promise_cpe, :precision => 2) }",
                                        "#{advertisement.cpe_times(city_budget_distribution)}",
                                        number_with_precision(advertisement.special_ad? ? "-" : advertisement.total_price(city_budget_distribution), :precision => 2, :delimiter => ","),
                                        number_with_precision(advertisement.budget * city_budget_distribution, :precision => 2, :delimiter => ",")
                                        ],:style => styles[:operation_body]
                   end

                   worksheet.add_row [
                   I18n.t('order.schedule_excel.sheet_column_content_pro_total'),
                    '',
                    '',
                    number_with_precision(advertisement.special_ad? ? "-" : advertisement.public_price, :precision => 2, :delimiter => ","),
                    advertisement.special_ad? ? "-" : number_with_precision(advertisement.discount, :precision => 2, :delimiter => ",")+'%',
                    "#{number_with_precision(advertisement.promise_cpe, :precision => 2) }",
                    "#{advertisement.cpe_times}",
                    number_with_precision(advertisement.special_ad? ? "-" : advertisement.total_price, :precision => 2, :delimiter => ","),
                    number_with_precision(advertisement.budget, :precision => 2, :delimiter => ",")
                    ],:style => styles[:operation_summary]

      end
      

      def cpe_unadmeasure(advertisement)

        worksheet.add_row [
                        advertisement.product.present? ? I18n.locale == :en ? (advertisement.product.product_type_en.present? ? advertisement.product.product_type_en : '-') : advertisement.product.product_type_cn : "-" ,
                        advertisement.product ? I18n.locale == :en ? (advertisement.product.en_name.present? ? advertisement.product.en_name : '-') : advertisement.product.name : I18n.t(advertisement.ad_type),
                        "-",
                        number_with_precision(advertisement.special_ad? ? "-" : advertisement.public_price, :precision => 2, :delimiter => ","),
                        advertisement.special_ad? ? "-" : number_with_precision(advertisement.discount, :precision => 2, :delimiter => ",")+'%',
                        "#{number_with_precision(advertisement.promise_cpe, :precision => 2) }",
                        "#{advertisement.cpe_times}",
                        number_with_precision(advertisement.special_ad? ? "-" : advertisement.total_price, :precision => 2, :delimiter => ","),
                        number_with_precision(advertisement.budget, :precision => 2, :delimiter => ",")
                        ],:style => styles[:operation_body]

      end

      
      def uncpe_unadmeasure(advertisement)
        
         from_array = [
                         advertisement.product.present? ? I18n.locale == :en ? (advertisement.product.product_type_en.present? ? advertisement.product.product_type_en : '-') : advertisement.product.product_type_cn : "-" ,
                         advertisement.product ? I18n.locale == :en ? (advertisement.product.en_name.present? ? advertisement.product.en_name : '-') : advertisement.product.name : I18n.t(advertisement.ad_type) ,
                         "-",
                         number_with_precision(advertisement.special_ad? ? "-" : advertisement.public_price, :precision => 2, :delimiter => ","),
                         advertisement.special_ad? ? "-" : number_with_precision(advertisement.discount, :precision => 2, :delimiter => ",")+'%',
                         "#{number_with_precision(advertisement.cpm? ? advertisement.promise_cpm : advertisement.promise_cpc, :precision => 2) }",
                         "#{number_with_precision(advertisement.cpm? ? advertisement.daily_exposure : advertisement.daily_hits, :precision => 0, :delimiter => ",")}",
                         "#{number_with_precision(advertisement.cpm? ? advertisement.promise_exposure : advertisement.promise_hits, :precision => 0, :delimiter => ",")}",
                         "#{order.check_download_attr['ctr']=='true' ? number_with_precision(advertisement.forecast_ctr, :precision => 2, :delimiter => ",") + '%' : '-' }",
                         "#{advertisement.cpm? ? advertisement.cpc_prediction : advertisement.cpm_prediction}",
                         "#{advertisement.cpm? ? (order.check_download_attr['click']=='true' ? advertisement.daily_clicks_prediction : '-'): (order.check_download_attr['impression']== 'true' ? advertisement.daily_impressions_prediction : '-')}",
                         "#{advertisement.cpm? ? (order.check_download_attr['click']=='true' ? advertisement.clicks_prediction : '-') : (order.check_download_attr['impression']== 'true' ? advertisement.impressions_prediction : '-')}",
                         number_with_precision(advertisement.special_ad? ? "-" : advertisement.total_price, :precision => 2, :delimiter => ","),
                         number_with_precision(advertisement.budget, :precision => 2, :delimiter => ",")
                         ]

         worksheet.add_row array_delete(from_array,get_cpm_cpc_cols(advertisement)) ,:style => styles[:operation_body]

      end

      
      def uncpe_admeasure(advertisement)
         if  advertisement.admeasure_state && advertisement.admeasure?
           (I18n.locale == :en ? advertisement.admeasure_en[0..-2].select{|a| a[1].present?} : advertisement.admeasure[0..-2].select{|a| a[1].present?}).each do |distribution|
                city = distribution[0]
                city_budget_distribution = distribution[1].to_f / advertisement.budget_ratio("super")
                from_array = [
                      advertisement.product.present? ? I18n.locale == :en ? (advertisement.product.product_type_en.present? ? advertisement.product.product_type_en : '-') : advertisement.product.product_type_cn : "-" ,
                      advertisement.product ? I18n.locale == :en ? (advertisement.product.en_name.present? ? advertisement.product.en_name : '-') : advertisement.product.name : I18n.t(advertisement.ad_type) ,
                      city,
                      number_with_precision(advertisement.special_ad? ? "-" : advertisement.public_price, :precision => 2, :delimiter => ","),
                      advertisement.special_ad? ? "-" : number_with_precision(advertisement.discount, :precision => 2, :delimiter => ",")+'%',
                      "#{number_with_precision(advertisement.cpm? ? advertisement.promise_cpm : advertisement.promise_cpc, :precision => 2) }",
                      "#{number_with_precision(advertisement.cpm? ? advertisement.daily_exposure(city_budget_distribution) : advertisement.daily_hits(city_budget_distribution), :precision => 0, :delimiter => ",")}",
                      "#{number_with_precision(advertisement.cpm? ? advertisement.promise_exposure(city_budget_distribution) : advertisement.promise_hits(city_budget_distribution), :precision => 0, :delimiter => ",")}",
                      "#{order.check_download_attr['ctr']=='true' ? number_with_precision(advertisement.forecast_ctr, :precision => 2, :delimiter => ",") + '%' : '-' }",
                      "#{advertisement.cpm? ? advertisement.cpc_prediction : advertisement.cpm_prediction}",
                      "#{advertisement.cpm? ? (order.check_download_attr['click']=='true' ? advertisement.daily_clicks_prediction(city_budget_distribution) : '-'): (order.check_download_attr['impression']== 'true' ? advertisement.daily_impressions_prediction(city_budget_distribution) : '-')}",
                      "#{advertisement.cpm? ? (order.check_download_attr['click']=='true' ? advertisement.clicks_prediction(city_budget_distribution) : '-') : (order.check_download_attr['impression']== 'true' ? advertisement.impressions_prediction(city_budget_distribution) : '-')}",
                      number_with_precision(advertisement.special_ad? ? "-" : advertisement.total_price(city_budget_distribution), :precision => 2, :delimiter => ","),
                      number_with_precision(advertisement.budget * city_budget_distribution, :precision => 2, :delimiter => ",")
                      ]

                worksheet.add_row array_delete(from_array,get_cpm_cpc_cols(advertisement)) ,:style => styles[:operation_body]
              end
              end

              from_array = [    I18n.t('order.schedule_excel.sheet_column_content_pro_total'),
                                '',
                                '',
                                number_with_precision(advertisement.special_ad? ? "-" : advertisement.public_price, :precision => 2, :delimiter => ","),
                                advertisement.special_ad? ? "-" : number_with_precision(advertisement.discount, :precision => 2, :delimiter => ",")+'%',
                                "#{number_with_precision(advertisement.cpm? ? advertisement.promise_cpm : advertisement.promise_cpc, :precision => 2) }",
                                "#{number_with_precision(advertisement.cpm? ? advertisement.daily_exposure : advertisement.daily_hits, :precision => 0, :delimiter => ",")}",
                                "#{number_with_precision(advertisement.cpm? ? advertisement.promise_exposure : advertisement.promise_hits, :precision => 0, :delimiter => ",")}",
                                "#{order.check_download_attr['ctr']=='true' ? number_with_precision(advertisement.forecast_ctr, :precision => 2, :delimiter => ",") + '%' : '-' }",
                                "#{advertisement.cpm? ? advertisement.cpc_prediction : advertisement.cpm_prediction}",
                                "#{advertisement.cpm? ? (order.check_download_attr['click']=='true' ? advertisement.daily_clicks_prediction : '-'): (order.check_download_attr['impression']== 'true' ? advertisement.daily_impressions_prediction : '-')}",
                                "#{advertisement.cpm? ? (order.check_download_attr['click']=='true' ? advertisement.clicks_prediction : '-') : (order.check_download_attr['impression']== 'true' ? advertisement.impressions_prediction : '-')}",
                                number_with_precision(advertisement.special_ad? ? "-" : advertisement.total_price, :precision => 2, :delimiter => ","),
                                number_with_precision(advertisement.budget, :precision => 2, :delimiter => ",")
                                ]

              worksheet.add_row array_delete(from_array,get_cpm_cpc_cols(advertisement)),:style => styles[:operation_summary]

      end


  end
end
