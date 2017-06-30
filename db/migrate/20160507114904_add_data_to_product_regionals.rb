class AddDataToProductRegionals < ActiveRecord::Migration
  def change
    ProductRegional.create [
                               {name: '大陆-北京、上海',en_name: 'CN-BJ、SH',value: 'SPECIAL'},
                               {name: '大陆-广州、深圳',en_name: 'CN-GZ、SZ',value: 'SPECIAL'},
                               {name: '大陆-一线城市',en_name: 'CN-1st tier cities',value: 'SPECIAL'},
                               {name: '大陆-其他城市',en_name: 'CN-other cities',value: 'OTHER'},
                               {name: '大陆-全国通投',en_name: 'CN-nationwide',value: 'NATION'},
                               {name: '港台澳-香港',en_name: 'HongKong',value: 'HK_TW_MA'},
                               {name: '港台澳-台湾',en_name: 'Taiwan',value: 'HK_TW_MA'},
                              # {name: '港台澳-澳门',en_name: 'Macao',value: 'HK_TW_MA'},
                               {name: '海外市场 international',en_name: 'International Market',value: 'OTHER_COUNTRY'},
                               {name: '美国,英国',en_name: 'US,UK',value: 'US_UK'},
                               {name: '海外其他市场 International',en_name: 'International (Except HK,TW,US,UK)',value: 'OTHER_COUNTRY'}

    ]
    Product.all.each do |product|
      productRegional = ProductRegional.where({"value" => product.regional})
      if productRegional.present?
        product_regional_id = productRegional.last.id
      else
        product_regional_id = (ProductRegional.find_by_value ("HK_TW_MA")).id if product.regional == "HK_TW_MA_SG"
        product_regional_id = (ProductRegional.find_by_value ("US_UK")).id if product.regional == "US_UK_AU_NZ_MY"
      end
      product.update_columns({:product_regional_id => product_regional_id})
    end
  end
end
