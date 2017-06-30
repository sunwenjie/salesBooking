class CreateBookingBshares < ActiveRecord::Migration
  def change
    # create_bshares_sql = 'CREATE TABLE xmo.bshare_industries (
    #                              id int(11) NOT NULL AUTO_INCREMENT,
    #                              industry_id int(11) DEFAULT NULL,
    #                              code int(11) DEFAULT NULL,
    #                              name varchar(255) DEFAULT NULL,
    #                              en_name varchar(255) DEFAULT NULL,
    #                              parent_id int(11) DEFAULT NULL,
    #                              level int(11) DEFAULT NULL,
    #                              created_at datetime DEFAULT NULL,
    #                              updated_at datetime DEFAULT NULL,
    #                              PRIMARY KEY (id)
    #                              ) ENGINE=InnoDB DEFAULT CHARSET=utf8;'
    #
    # create_booking_bshares_sql = 'CREATE TABLE xmo.booking_bshares (
    #                              id int(11) NOT NULL AUTO_INCREMENT,
    #                              industry_id int(11) DEFAULT NULL,
    #                              name varchar(255) DEFAULT NULL,
    #                              name_en varchar(255) DEFAULT NULL,
    #                              code varchar(255) DEFAULT NULL,
    #                              is_delete tinyint(1) DEFAULT NULL,
    #                              bshare_id int(11) DEFAULT NULL,
    #                              created_at datetime DEFAULT NULL,
    #                              updated_at datetime DEFAULT NULL,
    #                               PRIMARY KEY (id)
    #                               ) ENGINE=InnoDB DEFAULT CHARSET=utf8;'

    #
    # insert_industries_sql = "insert into industries (name,remarks,created_at,updated_at,name_cn,agency_id,gdn_id,bshare_id) values
    #                          ('Office Supplies','',now(),now(),'办公用品',1,null,601),
    #                          ('Fashion','',now(),now(),'服饰',1,null,604),
    #                          ('Home Appliance','',now(),now(),'家用电器',1,null,609),
    #                          ('Maternity & Babies','',now(),now(),'母婴相关',1,null,613),
    #                          ('Agriculture','',now(),now(),'农业相关',1,null,614),
    #                          ('Ticketing','',now(),now(),'票务服务',1,null,615),
    #                          ('Business Services','',now(),now(),'商务服务',1,null,617),
    #                          ('Gift & Packaging','',now(),now(),'箱包配饰及礼品',1,null,626),
    #                          ('Medical drugs','',now(),now(),'医疗药品',1,null,625)
    #                         "
    #
    # insert_booking_industries_sql="
    #                         insert into industries (agency_id,bshare_id)
    #                         select 1,booking_bshares.bshare_id  from  booking_bshares where booking_bshares.bshare_id not in
    #                         (select distinct bshare_id from industries)
    #                         "
    #
    # update_industries_sql = "update industries inner join bshare_industries on industries.bshare_id = bshare_industries.industry_id
    #                          set industries.name = bshare_industries.en_name,industries.name_cn = bshare_industries.name"
    #
    # update_create_at_sql = "update industries set created_at = now(),updated_at= now() where created_at is null"
    #
    # insert_bshare_product_sql = " insert into bshare_products (industry_id,name_cn,name_en,product_id,created_at)
    #                               select id,name_cn,name,bshare_id,created_at from industries where date_format(created_at,'%Y-%m-%d') = date_format(now(),'%Y-%m-%d')
    #                          "
    # update_booking_client_industry_id = "update clients c inner join
    #                         (select clients.id as client_id,clients.industry_id as client_industry_id,max(industries.id) as id from clients,booking_bshares,industries  where clients.industry_id = booking_bshares.industry_id  and
    #                         booking_bshares.bshare_id = industries.bshare_id and
    #                        clients.booking_client_id is not null group by clients.id ) t on c.id = t.client_id set c.industry_id = t.id
    #                        "
    #
    # ActiveRecord::Base.connection_pool.with_connection{|conn|
    #   conn.execute(create_bshares_sql)
    #   conn.execute(create_booking_bshares_sql)
    #   conn.execute(insert_industries_sql)
    #   conn.execute(insert_booking_industries_sql)
    #   conn.execute(update_industries_sql)
    #   conn.execute(update_create_at_sql)
    #   conn.execute(insert_bshare_product_sql)
    #   conn.execute(update_booking_client_industry_id)
    #
    # }
    #



  end
end
