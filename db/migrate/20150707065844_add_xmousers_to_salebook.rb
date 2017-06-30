 class AddXmousersToSalebook < ActiveRecord::Migration
   def change
#     # 用户不重复 i-click.com邮箱账号导入
#     execute <<-SQL
#     insert into users(username,real_name,encrypted_password,reset_password_token,tel,created_at,updated_at,role_id,user_state,is_active,email)
#     select username, name,'$2a$10$Ko6x1q/gQNamG6yxaybNSuGwSvmX6idmQKVLnLYcHFgj6Vg9VzZyK',id, usercontact,now(),now(),
#            1,'inactive',false,useremail
#     from xmo.users where id not in
#     (select  a.id from xmo.users a ,users b where  a.useremail=CONVERT(b.email USING utf8) COLLATE utf8_unicode_ci)
#     and user_status='Active'
#     and useremail like '%i-click.com'
#     SQL
#
#     #xmo中用户不重复 非i-click邮箱账号导入
#     execute <<-SQL
#     insert into users(username,real_name,encrypted_password,reset_password_token,tel,created_at,updated_at,role_id,user_state,is_active,email)
#     select username, name,'$2a$10$Ko6x1q/gQNamG6yxaybNSuGwSvmX6idmQKVLnLYcHFgj6Vg9VzZyK',id, usercontact,now(),now(),
#     1,'inactive',false,useremail
#     from xmo.users where id not in
#     (select  a.id from xmo.users a ,users b where  a.useremail=CONVERT(b.email USING utf8) COLLATE utf8_unicode_ci)
#     and user_status='Active'
#     and username not in (select username from xmo.users where user_status='Active' group by username having count(*)>1)
#     and useremail not like '%i-click%'
#     and username not in(select username from users);
#     SQL
#
# #xmo中用户重复且在saleBooking中无相同用户账号导入
#   execute <<-SQL
#   insert into users(username,real_name,encrypted_password,reset_password_token,tel,created_at,updated_at,role_id,user_state,is_active,email)
#   select username, name,'$2a$10$Ko6x1q/gQNamG6yxaybNSuGwSvmX6idmQKVLnLYcHFgj6Vg9VzZyK',id, usercontact,now(),now(),
#   1,'inactive',false,useremail
#   from xmo.users where id not in
#   (select  a.id from xmo.users a ,users b where  a.useremail=CONVERT(b.email USING utf8) COLLATE utf8_unicode_ci)
#   and username not in  (select CONVERT(username USING utf8) COLLATE utf8_unicode_ci  from users )
#   and user_status='Active'
#   and useremail not like '%i-click%'
#   group by username having count(*)>1;
#   SQL
#
   end
 end
