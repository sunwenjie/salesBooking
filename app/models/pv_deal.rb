class PvDeal < ActiveRecord::Base
  establish_connection "xmo_production".to_sym
  belongs_to :pv_detail
  # status 已预定：booked，已销售：approve_yes,审批未通过：approve_no,三天未审批已释放：outline，已删除：cancle
  class << self
    def distribute_pv(pv,detail_ids)
      #TODO 确定数据源 动态分配
      dist = {'北京' => 6,'上海' => 3,'广州'=>2,'杭州'=>2,'深圳'=>2,'其他'=>85}
      all_city = []
      detail_ids.each do |x|
        dd = PvDetail.find(x)
        all_city << [dd.city,dd.store_pv,dist[dd.city]]
      end
      # sum 用来计算比例 如三个城市 北京上海广州 就是6+3+2
      sum = all_city.inject(0){|x,v| x+=v[2]}
      # 计算期望分配pv  格式［城市，库存pv，期望pv，多余pv，缺少pv，最后分配pv］
      sum_a = all_city.collect{|x|[x[0],x[1],pv * x[2]/sum.to_f.to_i,0,0,0]}
      # 库存pv减去期望pv，多了就是多余pv，少了就是缺少的pv。
      # 如果缺少最后分配的pv就是库存pv，如果多了最后分配的pv初始化为期望pv
      sum_b = sum_a.collect{|x| (x[1] > x[2]) ? [x[0],x[1],x[2],(x[1]-x[2]),x[4],x[2]] : [x[0],x[1],x[2],x[3],(x[2]-x[1]),x[1]]}
      #计算总共缺少的pv
      # less = sum_b.inject(0){|x,v| x+=v[4]} + 1
      less = pv - sum_b.inject(0){|x,v| x+=v[5]}
      #从多余pv里面去取pv  并分配出去。
      sum_b.each do |x|
        if x[3] >= less
          x[5] = x[5] + less 
          break
        else
          x[5] = x[5] + x[3]
          less -= x[3]
        end
      end
      p sum_b
      sum_b.collect{|x| [x[0],x[5]]}.to_h
    end

    def pv_valid(pv_detail,ui_pv,order_id)
      pv_list = []
      pv_detail_ids = pv_detail.split(',')
      pv_arr = ui_pv
      if pv_detail_ids.length > 1

        pv_cities = PvDeal.distribute_pv(pv_arr,pv_detail_ids)

        pv_detail_ids.each do |detail_id|
          detail = PvDetail.find(detail_id)
          pv = pv_cities[detail['city']]
          if detail.store_pv < pv
            return "Media:#{detail.media},City:#{detail.city},PV不足."
          end
          pv_list << [detail_id, pv]
        end
      else
        detail_id = pv_detail_ids[0]
        detail = PvDetail.find(detail_id)
        if detail.store_pv < pv_arr
          return "Media:#{detail.media},City:#{detail.city},PV不足."
        end
        pv_list << [detail_id, pv_arr]
      end
      return pv_list
    end

    def booking(order_id,pv_details,current_user_id,delete_pvs)
      #TODO 点击加入列表 params 
      #[{'pv_detail_id':1111,all_area_pv:110,city_pv:0},
      # {'pv_detail_id':1112,all_area_pv:0,city_pv:22},] order_id
      if delete_pvs.to_s != ''
        dp = delete_pvs.to_s.split(',')
        # delete_pv = dp.delete_at(0)
        retry_count = 0
        dp.each do |x|
          d_deal = PvDeal.find(x.to_i)
          d_detail = PvDetail.find(d_deal.pv_detail_id)
          begin
            d_detail.process_pv(d_deal.pv,'cancle')
            d_detail.save
            d_deal.destroy
          rescue ActiveRecord::StaleObjectError
            sleep(1)
            if retry_count < 5
              retry_count += 1
              retry
            else
              ErrorMailer.send_error_message(PV_RECIPIENTS, "User booking pv is locked,please check it!").deliver
            end
          end
        end
      end

      if pv_details.present?
        # pv_details = pv_details.values
        valid = []
        pv_details.each do |pv_detail|
          ui_pv = pv_detail[:all_area_pv].present? ? pv_detail[:all_area_pv] : pv_detail[:city_pv]
          msg = pv_valid(pv_detail[:pv_detail_id],ui_pv,order_id)
          if String === msg
            return msg
            break
          end
          valid += msg
        end
        retry_count = 0
        begin
          valid.each do |x|
            detail_id = x[0]
            detail = PvDetail.find(detail_id)
            pv = x[1]
            deal = PvDeal.new
            deal.pv_detail_id = detail.id
            deal.order_id = order_id
            deal.pv = pv
            deal.deal_by = current_user_id
            deal.status = 'booked'
            deal.save
            detail.process_pv(pv,'booking')
            detail.save
          end
          
        rescue ActiveRecord::StaleObjectError
          sleep(1)
          if retry_count < 5
            retry_count += 1
            retry
          else
            ErrorMailer.send_error_message(PV_RECIPIENTS, "User booking pv is locked,please check it!").deliver
          end
          
        end
      end
      
      # end
      return false
    end

    def change_status(order_id,status)
      pv_deal = PvDeal.where("order_id=#{order_id}")
      if pv_deal.exists?
        pv_deal.each do |deal|
          deal.status = status
          deal.save
          pv_detail = PvDetail.find(deal.pv_detail_id)
          pv_detail.process_pv(deal.pv,status)
          pv_detail.save
        end
      end
    end

    def release_pv(order_id)
      retry_count = 0
      dp = self.where(["order_id = ?",order_id])
      dp.each do |d_deal|
        d_detail = PvDetail.find(d_deal.pv_detail_id)
        begin
          d_detail.process_pv(d_deal.pv,'cancle')
          d_detail.save
          d_deal.destroy
        rescue ActiveRecord::StaleObjectError
          sleep(1)
          if retry_count < 5
            retry_count += 1
            retry
          else
            ErrorMailer.send_error_message(PV_RECIPIENTS, "User booking pv is locked,please check it!").deliver
          end
        end
      end
    end
  end

  
end