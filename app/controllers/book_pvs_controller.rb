class BookPvsController < ApplicationController
  
  def pv_query
    cond = ' 1=1 '
    media_type,media_form,city  = '','',''
    book_sql = ""
    @action_flag = 0
    if params['media_type'] == 'null' && params['media_form'] == 'null' && params['city'] == 'null'
      book_sql = "select * from (select * from (select *,floor(sum(round(all_pv * 0.8) - (booked_pv + saled_pv + used_pv))) sum_pv,group_concat(id) ids 
                    from pv_details group by placement_id,city with rollup) as a 
                    order by a.placement_id desc,a.city asc) aa where aa.sum_pv > 0;"
      @action_flag = 1
    else
      if params['media_type'] != 'null' && !params['media_type'].include?('全部') 
        params['media_type'].split(",").each{|b| media_type += "'#{b}',"}
        cond << " and media_type in (#{media_type.gsub(/,$/, '')})"
      end
      if params['media_form'] != 'null' && !params['media_form'].include?('全部') 
        params['media_form'].split(",").each{|b| media_form += "'#{b}',"}
        cond << " and midia_form in (#{media_form.gsub(/,$/, '')})"
      end
      if params['city'] != 'null' && !params['city'].include?('全部') 
        params['city'].split(",").each{|b| city += "'#{b}',"}
        cond << " and city in (#{city.gsub(/,$/, '')})"
      end
      book_sql = "select * from (select *,floor(sum(round(all_pv * 0.8) - (booked_pv + saled_pv + used_pv))) sum_pv,group_concat(id) ids from pv_details where #{cond} group by placement_id,city) aa where aa.sum_pv > 0"
    end
    @book_pvs = PvDetail.find_by_sql(book_sql)
    @pv_list = PvDeal.includes(:pv_detail).where("order_id = #{params[:id]} and status = 'booking'") if params[:id]
    render :partial=>"orders/book_pv_table"  
  end

end