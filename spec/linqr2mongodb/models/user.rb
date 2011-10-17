class User
  include Mongoid::Document

  field :login
  field :email
  field :role

  referenced_in :site, :inverse_of => :users
  references_many :articles, :foreign_key => :author_id
  references_and_referenced_in_many :children, :class_name => "User"
  references_one :record

  embeds_one :profile


  def admin?
    false
  end
end
