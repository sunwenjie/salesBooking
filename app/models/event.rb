class Event < ActiveRecord::Base
  has_and_belongs_to_many :groups, join_table: "#{SendMenu::DbConnection}.event_groups"
  has_and_belongs_to_many :users, join_table: "#{SendMenu::DbConnection}.event_users"

  serialize :roles
  def self.round_group_emails(*groups)
    round_group_emails = User.with_emails(groups)
    if round_group_emails.size>0
      round_group_emails
    else
      []
    end
  end

  def self.event_user_emails(notify_method, triger_user)
    @event=self.find_by_notify_method(notify_method)
    notify_type=@event.notify_type
    roles=@event.roles
    triger_user=User.where(User.user_conditions(triger_user))[0]
    event_user_emails=[]
    if notify_type=="absolute"
      round_group_emails=[]
      event_user_emails=@event.users.map(&:useremail).flatten.uniq if @event.present?
      round_group_emails= self.round_group_emails(@event.groups.ids) if @event.groups.ids.present?
      event_user_emails=event_user_emails+round_group_emails
    elsif notify_type=="relative"
      # triger_user_groups=triger_user.groups.ids ||[]
      # event_users=@event.users.ids ||[]
      # event_group_users=User.with_groups(@event.groups.ids) ||[]
      # event_users= event_users + event_group_users
      # event_users.each{|user_id|
      #   user=User.find(user_id)
      #   roles.each{|role|
      #     user_innergroups=user.innergroups["#{role}"] ||[]
      #     event_user_emails<<user.useremail if (triger_user_groups &  user_innergroups).size>0
      #   }
      # }
    end
    event_user_emails = event_user_emails.flatten.uniq
    return event_user_emails
  end


end
