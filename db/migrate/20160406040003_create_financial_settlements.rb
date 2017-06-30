class CreateFinancialSettlements < ActiveRecord::Migration
  def change
    create_table :financial_settlements do |t|
      t.string :name_en
      t.string :name_cn
      t.string :oa_code

      t.timestamps
    end
     sql = "insert into financial_settlements(name_en,name_cn,oa_code,created_at,updated_at) values('Mobile DSP','Mobile DSP','P100',now(),now()),
        ('PC DSP','PC DSP','P101',now(),now()),
        ('Mobile OTV','Mobile OTV','P102',now(),now()),
        ('PC OTV','PC OTV','P103',now(),now()),
        ('MoSocial','MoSocial','P104',now(),now()),
        ('MOTV','MOTV','P105',now(),now()),
        ('Rich Media','Rich Media','P106',now(),now()),
        ('智盒','智盒','P107',now(),now()),
        ('Others','Others','P108',now(),now()),
        ('搜索排名','搜索排名','S100',now(),now()),
        ('无线搜索','无线搜索','S101',now(),now()),
        ('品牌专区','品牌专区','S102',now(),now()),
        ('无线品牌专区','无线品牌专区','S103',now(),now()),
        ('品牌地标','品牌地标','S104',now(),now()),
        ('网盟','网盟','S105',now(),now()),
        ('其他','其他','S106',now(),now()),
        ('展示推广DSP','展示推广DSP','S107',now(),now())
"
ActiveRecord::Base.connection_pool.with_connection{|conn| conn.execute(sql)}
  end

end
