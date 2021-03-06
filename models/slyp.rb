require './models/user_slyp.rb'
require './models/user.rb'
require './models/topic.rb'


class Slyp < ActiveRecord::Base
  has_many :user_slyps
  has_many :users, through: :user_slyps
  has_many :slyp_chats

  belongs_to :topic
  enum slyp_type: [:video, :article]

  def get_friends(user_id)
    sql = "select u.id, u.email, x.slyp_chat_id, count(distinct scm.id) as unread_messages "\
          +"from ( "\
          +  "select scu.slyp_chat_id, scu.last_read_at "\
          +    "from slyp_chats sc "\
          +  "join slyp_chat_users scu "\
          +  "on (sc.id = scu.slyp_chat_id) "\
          +  "where scu.user_id = "+user_id.to_s+" and sc.slyp_id="+self.id.to_s+" "\
          +") x "\
          +"join slyp_chat_users scu "\
          +"on (scu.slyp_chat_id = x.slyp_chat_id and scu.user_id <> "+user_id.to_s+") "\
          +"join users u "\
          +"on (scu.user_id = u.id) "\
          +"left join slyp_chat_messages scm "\
          +"on (scm.user_id = u.id and scm.slyp_chat_id = x.slyp_chat_id and scm.created_at >= x.last_read_at) "\
          +"group by u.id, u.email; "
    return ActiveRecord::Base.connection.select_all(sql)
  end

  def get_unread_messages_count(user_id)
    sql = "select count(scm.id) unread_messages "\
          +"from slyp_chats sc "\
          +"join slyp_chat_users scu "\
          +"on (sc.id = scu.slyp_chat_id) "\
          +"join slyp_chat_messages scm "\
          +"on (scm.slyp_chat_id = sc.id) "\
          +"where scu.user_id = "+user_id.to_s+" and sc.slyp_id = "+self.id.to_s+" and scm.user_id <> "+user_id.to_s+" and scm.created_at > scu.last_read_at; "
    return ActiveRecord::Base.connection.select_all(sql).first()["unread_messages"]
  end

  def get_user_slyp(user_id)
    return self.user_slyps.find_by(user_id: user_id)    
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :url
    expose :raw_url
    expose :author
    expose :date
    expose :text
    expose :summary
    expose :description
    expose :top_image
    expose :site_name
    expose :video_url
    expose :created_at do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_i      
      slyp.get_user_slyp(user_id).created_at
    end
    expose :topic, using: Topic::Entity
    expose :archived do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_i      
      slyp.get_user_slyp(user_id).archived
    end
    expose :starred do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_i            
      slyp.get_user_slyp(user_id).starred
    end
    expose :engaged do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_i      
      slyp.get_user_slyp(user_id).engaged
    end
    expose :users do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_i
      slyp.get_friends(user_id)
    end
    expose :unread_messages do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_i
      slyp.get_unread_messages_count(user_id)
    end
    expose :sender, using: User::Entity do |slyp, options|
      user_id = options[:env]["api.endpoint"].cookies["user_id"].to_i      
      sender_id = slyp.get_user_slyp(user_id).sender_id
      User.find_by(id: sender_id)
    end
  end
end