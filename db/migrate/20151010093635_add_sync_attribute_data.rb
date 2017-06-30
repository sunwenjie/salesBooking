class AddSyncAttributeData < ActiveRecord::Migration
  def change
    # order
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system) values(1,'share_sales','共享到销售',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(2,'sap_order','请选择SAP对应订单',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(3,'sale_channel','分销渠道',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(4,'client_business_licence_name','客户营业执照名称',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(5,'pay_condition','付款条件',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(6,'organize_number','组织编号',now(),now(),'Order','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(7,'business_type','业务类型',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(32,'sale_unit','销售单位',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(33,'client_invoice_type','客户发票类型',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(34,'product','项目-产品',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(35,'product_type','产品归类',now(),now(),'Order','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(36,'project_task','项目任务',now(),now(),'Order','SAP');"

    # client
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(8,'sap_client','SAP对应客户',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(9,'sale_channel','分销渠道',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(10,'client_business_licence_name','客户营业执照名称',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(11,'pay_condition','付款条件',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(12,'country','国家',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(13,'province','省份',now(),now(),'Client','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(14,'business_type','业务类型',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(15,'industry_detail','行业细分',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(16,'client_invoice_type','客户发票类型',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(17,'pay_type','付款方式',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(18,'deal_people','交易对象',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(19,'share_sales','共享到销售',now(),now(),'Client','SAP');"

    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(37,'sap_channel','渠道',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(38,'sale_origanize','销售组织',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(39,'currency','货币',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(40,'company_number','公司编号',now(),now(),'Client','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(45,'sap_client_name','SAP对应客户名称',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(47,'advertisement_master_id','广告主ID',now(),now(),'Client','SAP');"
    execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(48,'advertisement_master_name','广告主名称',now(),now(),'Client','SAP');"


    # channel
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system) values(20,'sap_client','SAP对应客户',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(21,'sale_channel','分销渠道',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(22,'client_business_licence_name','客户营业执照名称',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(23,'pay_condition','付款条件',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(24,'country','国家',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(25,'province','省份',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(26,'business_type','业务类型',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(27,'industry_detail','行业细分',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(28,'client_invoice_type','客户发票类型',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(29,'pay_type','付款方式',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(30,'deal_people','交易对象',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(31,'share_sales','共享到销售',now(),now(),'Channel','SAP');"
    #
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(41,'sap_channel','渠道',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(42,'sale_origanize','销售组织',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(43,'currency','货币',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(44,'company_number','公司编号',now(),now(),'Channel','SAP');"
    # execute "insert into sync_attributes (id,en,cn,created_at,updated_at,type,system)  values(46,'sap_client_name','SAP对应客户名称',now(),now(),'Channel','SAP');"

  end
end
