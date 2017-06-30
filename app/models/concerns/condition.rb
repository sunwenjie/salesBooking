module Concerns

  module Condition


    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def client_conditions(client)
        clients = Client.table_name
        conditions = case client
                       when String then
                         {"#{clients}.name" => client}
                       when Client then
                         {"#{clients}.id" => client.id}
                       else
                         {"#{clients}.id" => client.to_i}
                     end
      end

      def user_conditions(user)
        users = User.table_name
        conditions = case user
                       when String then
                         {"#{users}.name" => user}
                       when User then
                         {"#{users}.id" => user.id}
                       when Array then
                         {"#{users}.id" => user}
                       else
                         {"#{users}.id" => user.to_i}
                     end
      end

      def industry_conditions(industry)
        industries = Industry.table_name
        conditions = case industry
                       when String then
                         {"#{industries}.name" => industry}
                       when Industry then
                         {"#{industries}.id" => industry.id}
                       else
                         {"#{industries}.id" => industry.to_i}
                     end
      end

      def group_conditions(group)
        groups = Group.table_name
        conditions = case group
                       when String then
                         {"#{groups}.group_name" => group}
                       when Group then
                         {"#{groups}.id" => group.id}
                       when Array then
                         {"#{groups}.id" => group}
                       else
                         {"#{groups}.id" => group.to_i}
                     end
      end

      def date_range_condition(date)
        #时间范围条件封装
        end_date = (Time.now + 1.days).strftime('%Y/%m/%d')
        if date == 'all' || date.nil?
          range_condition = " where 1=1"
        else
          case date
            when 'week' then
              begin_date = (Time.now - 7.days).strftime('%Y-%m-%d')
            when '1month' then
              begin_date = (Time.now - 1.months).strftime('%Y-%m-%d')
            when '3month' then
              begin_date = (Time.now - 3.months).strftime('%Y-%m-%d')
          end
          where_column = self.name == 'Order' ? 'm.last_update_time' : 'm.updated_at'
          range_condition = " where  #{where_column} between date_format('#{begin_date}','%Y-%m-%d %H:%i:%s') and date_format('#{end_date}','%Y-%m-%d %H:%i:%s') "
        end
        return range_condition
      end
    end
  end
end