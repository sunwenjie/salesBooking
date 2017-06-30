#!/usr/bin/env ruby -w -s
# -*- coding: utf-8 -*-
  module SendAxlsx
    require 'find'
    include ActionView
    include ActionView::Helpers::NumberHelper

    def empety_rows(i)
      i.times.each do
        @ws.add_row
      end
    end


    def generate_logo
      @ws.add_image(:image_src => File.join(Rails.root, "app/assets/images", "logo.png"), :noSelect => true, :noMove => true) do |image|
        image.width = 190
        image.height = 63
        image.start_at 0, 0
      end
    end

    def sheel_images
      img = File.expand_path('../logo3.png', __FILE__)
      @ws.add_image(:image_src => img, :start_at => [0, 0], :noEditPoints => true) do |image|
        image.width = 190
        image.height = 63
      end
    end

    def random
      request_id = ([*('A'..'Z'), *('a'..'z'), *('0'..'9')]-%w(0 1 h I O)).sample(14).join
      return request_id
    end


    # @param [Object]
    def send_orders_xlsx(orders, tmp_directory, tmp_filename, gp_submit_orders)
      my_package = Axlsx::Package.new
      my_package.workbook do |wb|
        styles = wb.styles
        title = styles.add_style :sz => 26, :alignment => {:horizontal => :center,
                                                           :vertical => :center,
                                                           :wrap_text => true}
        default = styles.add_style :sz => 9
        @default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :b => true, :sz => 15
        @default1 = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :sz => 9, :alignment => {:horizontal => :right,
                                                                                                   :wrap_text => true}
        @combing = styles.add_style :alignment => {:horizontal => :center,
                                                   :vertical => :center,
                                                   :wrap_text => true}
        @table = styles.add_style :bg_color => 'FF9933', :fg_color => 'ff', :b => true, :border => {:style => :thin, :color => "00"}, :sz => 9, :paper_height => '100mm', :alignment => {:horizontal => :center,
                                                                                                                                                                                         :vertical => :center,
                                                                                                                                                                                         :wrap_text => true}
        @table_default = styles.add_style :fg_color => '00', :sz => 12, :border => {:style => :thin, :color => "00"}, :alignment => {:horizontal => :center,
                                                                                                                                     :vertical => :center,
                                                                                                                                     :wrap_text => true}

        wb.add_worksheet(:name => 'orders') do |ws|
          @ws=ws
          @ws.merge_cells "A1:B4"
          @ws.merge_cells "C1:N4"
          generate_logo
          @ws.add_row ['', '', I18n.t('order.orders_excel.sheet_title_iclick')], :style => title
          empety_rows(3)

          advertisementMaxSize=1
          order_ids = orders.present? ? orders.map(&:id).join(',') : null
          @result=ActiveRecord::Base.connection.execute("select  max(t.num) as num from (select count(1) as num  from `advertisements` where order_id  in(#{order_ids}) group by order_id ) t")

          advertisementMaxSize=@result.first[0] if @result.present?
          advertisementTitle=[]
          for i in 1 .. advertisementMaxSize
            if i!=advertisementMaxSize
              advertisementTitle=advertisementTitle+[I18n.t('order.orders_excel.sheet_advertisement')+i.to_s+I18n.t('order.orders_excel.sheet_name'), I18n.t('order.form.budget_allocations_column'), I18n.t('order.adlist.cost_type'), I18n.t('order.adlist.cost'), I18n.t('order.orders_excel.sheet_min_sell_price'),]
            else
              advertisementTitle=advertisementTitle+[I18n.t('order.orders_excel.sheet_advertisement')+i.to_s+I18n.t('order.orders_excel.sheet_name'), I18n.t('order.form.budget_allocations_column'), I18n.t('order.adlist.cost_type'), I18n.t('order.adlist.cost'), I18n.t('order.orders_excel.sheet_min_sell_price')]
            end
          end

          orderTitle=[I18n.t('order.orders_excel.sheet_info_order_name'), I18n.t('order.orders_excel.sheet_info_sale'), I18n.t('order.orders_excel.sheet_info_client_name'), I18n.t('order.orders_excel.sheet_info_brand'), I18n.t('order.orders_excel.sheet_info_agency'), I18n.t('order.orders_excel.sheet_base_total_budget'), I18n.t('order.orders_excel.sheet_base_budget_currency'), I18n.t('order.orders_excel.sheet_info_geo'), I18n.t('order.orders_excel.sheet_info_start_date'), I18n.t('order.orders_excel.sheet_info_end_date'), I18n.t('order.orders_excel.sheet_info_create_date'), I18n.t('order.orders_excel.sheet_info_status'), I18n.t('order.orders_excel.sheet_info_setting_status'), I18n.t('order.orders_excel.sheet_detail_3rd_monitor')]
          @ws.add_row orderTitle+advertisementTitle, :style => @default
          if orders.present?
            all_share_orders = ShareOrder.all_share_orders
            orders.each { |order|
              clientname=""
              brand=""
              channelname=""
              if order.client.present?
                clientname=order.client.clientname
                brand=order.client.brand
                channelname=order.client.channel_name
              end
              advertisements=[]
              if order.advertisements.present?
                order.advertisements.each { |ad|
                  # if !ad.floor_price.present? && ad.ad_type.present?
                  #   p "advertisements_floor_price:"+ad.order_regional_show
                  # end
                  advertisements<<(ad.product.present? ? I18n.locale == :en ? (ad.product.product_type_en.present? ? ad.product.product_type_en : '-') : ad.product.product_type_cn : "-") << number_with_precision(ad.budget_ratio, :precision => 2, :delimiter => ",")<< ad.cost_type.to_s<< number_with_precision(ad.cost, :precision => 2, :delimiter => ",")<< number_with_precision(ad.floor_price, :precision => 2, :delimiter => ",")
                }
              end
              regional = order.china_region_all? ? (order.map_country.to_s) : (order.map_country.to_s + " " + (order.china_regional? ? order.map_city.split(",")[0..3].join(",")+"..." : ""))
              third_monitor= order.third_monitor? ? (order.third_monitor.class.to_s=='Array' ? order.third_monitor.join(';') : order.third_monitor) : ''
              share_order_user = all_share_orders[order.id]
              @ws.add_row [order.title, share_order_user, clientname, brand, channelname, number_with_precision(order.budget, :precision => 2, :delimiter => ","), order.budget_currency, regional, order.start_date? ? order.start_date.strftime("%Y/%m/%d %H:%M") : "", order.ending_date? ? order.ending_date.strftime("%Y/%m/%d %H:%M") : "", order.created_at.localtime.strftime("%Y/%m/%d %H:%M"), order.map_order_status(order["status"], order.is_standard, gp_submit_orders), order.operations.last ? I18n.t(order.operations.last.action) : "正在配置", third_monitor]+advertisements, :style => @table_default
            }
          end
        end
      end

      create_file(my_package, tmp_directory, tmp_filename)

    end

    def send_clients_xlsx(clients, tmp_directory, tmp_filename)
      my_package = Axlsx::Package.new
      my_package.workbook do |wb|
        styles = wb.styles
        title = styles.add_style :sz => 26, :alignment => {:horizontal => :center,
                                                           :vertical => :center,
                                                           :wrap_text => true}
        default = styles.add_style :sz => 9
        @default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :b => true, :sz => 15
        @default1 = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :sz => 9, :alignment => {:horizontal => :right,
                                                                                                   :wrap_text => true}
        @combing = styles.add_style :alignment => {:horizontal => :center,
                                                   :vertical => :center,
                                                   :wrap_text => true}
        @table = styles.add_style :bg_color => 'FF9933', :fg_color => 'ff', :b => true, :border => {:style => :thin, :color => "00"}, :sz => 9, :paper_height => '100mm', :alignment => {:horizontal => :center,
                                                                                                                                                                                         :vertical => :center,
                                                                                                                                                                                         :wrap_text => true}
        @table_default = styles.add_style :fg_color => '00', :sz => 12, :border => {:style => :thin, :color => "00"}, :alignment => {:horizontal => :center,
                                                                                                                                     :vertical => :center,
                                                                                                                                     :wrap_text => true}
        all_share_users = ShareClient.all_share_clients
        wb.add_worksheet(:name => 'clients') do |ws|
          @ws=ws
          @ws.merge_cells "A1:B4"
          @ws.merge_cells "C1:F4"
          generate_logo
          @ws.add_row ['', '', t("clients.index.excel_title")], :style => title
          empety_rows(3)
          @ws.add_row [t("clients.index.client_id"), t("clients.index.client_name"), t("clients.index.channel"), t("clients.index.client_owner"), t("clients.index.created_at"), t("clients.index.status")], :style => @default
          clients.each { |client|
            share_users = all_share_users[client.id] ? all_share_users[client.id] : ''
            @ws.add_row [client.id, client.name, client.channel_name, share_users, client.created_at? ? client.created_at.localtime.strftime("%Y/%m/%d %H:%M") : '', client.state? ? '-' : t("clients.index.#{client.state}")], :style => @table_default
          }

        end
      end

      create_file(my_package, tmp_directory, tmp_filename)
    end


    def send_products_xlsx(products, tmp_directory, tmp_filename)
      my_package = Axlsx::Package.new
      my_package.workbook do |wb|
        styles = wb.styles
        title = styles.add_style :sz => 26, :alignment => {:horizontal => :center,
                                                           :vertical => :center,
                                                           :wrap_text => true}
        default = styles.add_style :sz => 9
        @default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :b => true, :sz => 15
        @default1 = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :sz => 9, :alignment => {:horizontal => :right,
                                                                                                   :wrap_text => true}
        @combing = styles.add_style :alignment => {:horizontal => :center,
                                                   :vertical => :center,
                                                   :wrap_text => true}
        @table = styles.add_style :bg_color => 'FF9933', :fg_color => 'ff', :b => true, :border => {:style => :thin, :color => "00"}, :sz => 9, :paper_height => '100mm', :alignment => {:horizontal => :center,
                                                                                                                                                                                         :vertical => :center,
                                                                                                                                                                                         :wrap_text => true}
        @table_default = styles.add_style :fg_color => '00', :sz => 12, :border => {:style => :thin, :color => "00"}, :alignment => {:horizontal => :center,
                                                                                                                                     :vertical => :center,
                                                                                                                                     :wrap_text => true}
        wb.add_worksheet(:name => 'products') do |ws|
          @ws=ws
          @ws.merge_cells "A1:B4"
          @ws.merge_cells "C1:H4"
          generate_logo
          @ws.add_row ['', '', t("products.index.product_excel_title")], :style => title
          empety_rows(3)
          @ws.add_row [t("products.index.product_id"), t("products.index.product_name"), t("products.index.type"), t("products.index.financial_settlement"), t("products.index.sale_type"), t("products.index.price"), t("products.index.bu"), t("products.new.remark_textarea")], :style => @default
          products.each { |product|
            financial_settlement = I18n.locale == :en ? product.try(:financial_settlement).try(:name_en) : product.try(:financial_settlement).try(:name_cn)
            general_price = ((product.floor_discount.present? ? product.floor_discount : 0) * (product.public_price.present? ? product.public_price : 0))
            @ws.add_row [product.product_serial, product.name, product.product_type, financial_settlement, product.sale_model, number_with_precision(general_price, :precision => 2, :delimiter => ","), product.bu.to_a.join(","), product.remark], :style => @table_default
          }

        end
      end
      create_file(my_package, tmp_directory, tmp_filename)
    end


    def send_agencies_xlsx(agencies, tmp_directory, tmp_filename)
      my_package = Axlsx::Package.new
      my_package.workbook do |wb|
        styles = wb.styles
        title = styles.add_style :sz => 26, :alignment => {:horizontal => :center,
                                                           :vertical => :center,
                                                           :wrap_text => true}
        default = styles.add_style :sz => 9
        @default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :b => true, :sz => 15
        @default1 = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :sz => 9, :alignment => {:horizontal => :right,
                                                                                                   :wrap_text => true}
        @combing = styles.add_style :alignment => {:horizontal => :center,
                                                   :vertical => :center,
                                                   :wrap_text => true}
        @table = styles.add_style :bg_color => 'FF9933', :fg_color => 'ff', :b => true, :border => {:style => :thin, :color => "00"}, :sz => 9, :paper_height => '100mm', :alignment => {:horizontal => :center,
                                                                                                                                                                                         :vertical => :center,
                                                                                                                                                                                         :wrap_text => true}
        @table_default = styles.add_style :fg_color => '00', :sz => 12, :border => {:style => :thin, :color => "00"}, :alignment => {:horizontal => :center,
                                                                                                                                     :vertical => :center,
                                                                                                                                     :wrap_text => true}
        wb.add_worksheet(:name => 'agencies') do |ws|
          @ws=ws
          @ws.merge_cells "A1:B4"
          @ws.merge_cells "C1:E4"
          generate_logo
          @ws.add_row ['', '', t("products.index.agency_excel_title")], :style => title
          empety_rows(3)
          @ws.add_row [t("products.list.channel_name"), t("products.list.rebate_date"), t("products.list.rebate_name"), t("products.list.salespersion"), t("products.list.create_date")], :style => @default
          agencies.each { |agency|
            @ws.add_row [agency.channel_name, agency.rebate_date.present? ? agency.rebate_date.split(',').uniq[0] : '', agency.ch_rebate.present? ? number_to_percentage(agency.ch_rebate.split(',').uniq[0], :precision => 2) : '',
                         agency.salesperson.present? ? agency.salesperson.split(',').uniq.join(',') : '-', agency.created_at.present? ? agency.created_at.strftime("%Y/%m/%d %H:%M") : ''], :style => @table_default
          }

        end
      end

      create_file(my_package, tmp_directory, tmp_filename)

    end

    def send_flows_xlsx(flows, tmp_directory, tmp_filename)
      my_package = Axlsx::Package.new
      my_package.workbook do |wb|
        styles = wb.styles
        title = styles.add_style :sz => 26, :alignment => {:horizontal => :center,
                                                           :vertical => :center,
                                                           :wrap_text => true}
        default = styles.add_style :sz => 9
        @default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :b => true, :sz => 15
        @default1 = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :sz => 9, :alignment => {:horizontal => :right,
                                                                                                   :wrap_text => true}
        @combing = styles.add_style :alignment => {:horizontal => :center,
                                                   :vertical => :center,
                                                   :wrap_text => true}
        @table = styles.add_style :bg_color => 'FF9933', :fg_color => 'ff', :b => true, :border => {:style => :thin, :color => "00"}, :sz => 9, :paper_height => '100mm', :alignment => {:horizontal => :center,
                                                                                                                                                                                         :vertical => :center,
                                                                                                                                                                                         :wrap_text => true}
        @table_default = styles.add_style :fg_color => '00', :sz => 12, :border => {:style => :thin, :color => "00"}, :alignment => {:horizontal => :center,
                                                                                                                                     :vertical => :center,
                                                                                                                                     :wrap_text => true}
        wb.add_worksheet(:name => 'user_permissions') do |ws|
          @ws=ws
          @ws.merge_cells "A1:B4"
          @ws.merge_cells "C1:F4"
          generate_logo
          @ws.add_row ['', '', t("approval_flows.index.approval_flows_excel_title")], :style => title
          empety_rows(3)
          @ws.add_row [t("approval_flows.index.name"), t("approval_flows.index.flow"), t("approval_flows.index.product"), t("approval_flows.index.bu"), t("approval_flows.index.user_group"), t("approval_flows.index.approve_group")], :style => @default
          flows.each { |flow|
            node_name = I18n.locale == :en ? flow.node.enname : flow.node.name
            @ws.add_row [flow.name, node_name, flow.product_type ? flow.product_type.reject { |r| r.blank? }.join(',') : '',
                         flow.bu, flow.group.group_name, flow.approver_group.group_name], :style => @table_default
          }
        end
      end

      create_file(my_package, tmp_directory, tmp_filename)

    end


    # def send_gps_xlsx(order_id, tmp_directory, tmp_filename)
    #   my_package = Axlsx::Package.new
    #   my_package.workbook do |wb|
    #     styles = wb.styles
    #     title = styles.add_style :sz => 26, :alignment => {:horizontal => :center,
    #                                                        :vertical => :center,
    #                                                        :wrap_text => true}
    #     @default = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :b => true, :sz => 15
    #     @default1 = styles.add_style :border => Axlsx::STYLE_THIN_BORDER, :sz => 9, :alignment => {:horizontal => :right,
    #                                                                                                :wrap_text => true}
    #     @combing = styles.add_style :alignment => {:horizontal => :center,
    #                                                :vertical => :center,
    #                                                :wrap_text => true}
    #     # @table = styles.add_style :bg_color => 'D4D4D4', :fg_color => '00', :b => true, :border => {:style => :thin, :color => "00"}, :sz => 15, :paper_height => '200mm', :alignment => {:horizontal => :left,
    #     #                                                                                                                                                                                  :vertical => :center,
    #     #                                                                                                                                                                                  :wrap_text => true}
    #     # @table_default = styles.add_style  :sz => 15,:b => true, :font_name=>"宋体",:border => { :style => :thin, :color => "00" }, :alignment => {:horizontal => :left, :vertical => :center, :wrap_text => true}
    #     #
    #
    #     @table = styles.add_style :bg_color => 'D4D4D4', :fg_color => '00', :b => true,:border => { :style => :thin, :color => "00" },:sz => 12,:paper_height=>'100mm',:alignment => { :horizontal => :left,
    #                                                                                                                                                                                   :vertical => :center ,
    #                                                                                                                                                                                   :wrap_text => true}
    #     @table_default = styles.add_style :fg_color => '00',:sz => 12,:border => { :style => :thin, :color => "00" },:alignment => { :horizontal => :left,
    #                                                                                                                                 :vertical => :center ,
    #                                                                                                                                 :wrap_text => true}
    #
    #
    #
    #     wb.add_worksheet(:name => 'Downtown traffic') do |ws|
    #       @ws=ws
    #       @ws.merge_cells "A1:B4"
    #       @ws.merge_cells "C1:D4"
    #       generate_logo
    #       @ws.add_row ['','','爱点击媒体组合列表','','','','','',''], :style => title
    #       empety_rows(3)
    #       order = Order.find(order_id)
    #       if order.client && order.client.channel_name.present?
    #         channel="渠道:"+order.client.channel_name
    #       else
    #         channel="直客"
    #       end
    #       clients = order.client ? order.client.clientname+" | "+" 品牌:"+order.client.brand+" | "+channel : ""
    #
    #       @ws.add_row ['订单号:',order.code],:style => @table_default
    #       @ws.add_row ['订单名称:',order.title],:style => @table_default
    #       @ws.add_row ['客户名称:',order.client.clientname],:style => @table_default
    #       @ws.add_row ['行业:',order.industry_name],:style => @table_default
    #       @ws.add_row ['提交销售:',order.user.real_name],:style => @table_default
    #       @ws.add_row ['订单生成时间:',order.created_at.localtime.to_s(:db)],:style => @table_default
    #       @ws.add_row ['计划开始日期:',order.start_date.to_s(:db)],:style => @table_default
    #       @ws.add_row ['计划结束日期:',order.ending_date.to_s(:db)],:style => @table_default
    #       @ws.add_row ['排除日期:',order.exclude_date.join(",")],:style => @table_default
    #       @ws.add_row ['总天数:',order.period.to_s],:style => @table_default
    #       @ws.add_row ['地域定向:',order.china_region_all? ? (order.map_country.to_s) :(order.map_country.to_s+" " + (order.china_regional? ? order.map_city.to_s : ""))],:style => @table_default
    #
    #       empety_rows(1)
    #       # media_gps = Order.get_media_list(params[:order_id])
    #       media_gps = Gp.get_gp_list(params[:order_id])
    #       @result = media_gps.group_by(&:advertisement_id)
    #       @result.each{|advertisement_id,city_gps|
    #         ad = Advertisement.find(advertisement_id)
    #         @ws.add_row [ad.get_advertisements_live,ad.product.name],:style => @table_default
    #         @city_gp_data = city_gps.group_by(&:city)
    #         @city_gp_data.each{|city,gp|
    #           # @ws.add_row ['地域',city == "-" ?  order.city.map{|c| t("city."+c) if c.present?  }.join("|"):city ],:style => @table_default
    #           if ad.ad_type == "BAN"
    #             @ws.add_row ['地域','网站名称', '网站类型', '广告形式', '原始尺寸', '停靠/拓展尺寸', '参考点击率','分配点击量','分配点击量比例'], :style => @table
    #           else
    #             @ws.add_row ['地域','网站名称', '网站类型', '广告形式', '原始尺寸', '停靠/拓展尺寸', '参考点击率','分配展示量','分配展示量比例'], :style => @table
    #           end
    #           city_pv_config = 0
    #           gp.each do |g|
    #             city_pv_config += g.pv_config
    #             @ws.add_row [city == "-" ?  "-":city,g.media,g.media_type,g.media_form,g.ad_original_size,g.ad_expand_size,g.ctr,number_with_precision(g.pv_config, :precision => 0, :delimiter => ",")+"K",sprintf("%.2f",g.pv_config_scale).to_s+"%"], :style => @table_default
    #           end
    #           @ws.add_row ['','','','','','','全部',number_with_precision(city_pv_config, :precision => 0, :delimiter => ",")+'K','100.00%'], :style => @table_default
    #
    #           empety_rows(0)
    #         }
    #       }
    #       empety_rows(1)
    #     end
    #   end
    #
    #   FileUtils::mkdir_p(tmp_directory) unless File.directory?(tmp_directory)
    #   my_package.serialize File.join(tmp_directory, tmp_filename)
    #   begin
    #     f=File.open(File.join(tmp_directory, tmp_filename))
    #   rescue Exception => e;
    #   ensure
    #     f.close
    #   end
    # end


    def generate_head
      worksheet.add_image(:image_src => File.join(Rails.root, "app/assets/images", "logo.png"), :noSelect => true, :noMove => true) do |image|
        image.width = 190
        image.height = 63
        image.start_at 0, 0
      end
      # worksheet.merge_cells "A1:A1"
      worksheet.add_row ['', '爱点击广告服务执行表', '', '', ''], :style => styles[:head_title]
    end

    def file_delete(filedir)
      if File.directory?(filedir)
        Find.find(filedir) do |filename|
          #File.delete(filename) if !filename.eql? filedir
        end
      end
    end

    def create_file(my_package, tmp_directory, tmp_filename)
      FileUtils::mkdir_p(tmp_directory) unless File.directory?(tmp_directory)
      my_package.serialize File.join(tmp_directory, tmp_filename)
      begin
        f=File.open(File.join(tmp_directory, tmp_filename))
      rescue  => e;
      ensure
        f.close
      end
    end

  end
