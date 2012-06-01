class User < ActiveRecord::Base
  belongs_to :account
  has_many :droplets, :dependent => :destroy
  has_many :droplet_histories, :dependent => :destroy

  authenticates_with_sorcery!
  attr_accessible :username, :email, :password, :password_confirmation, :remember, :delete_files, :dropbox_access_token, :password_hint, :account_id

  validates_presence_of :password, :on => :create

  validates :email, :presence => true,
                    :uniqueness => true,
                    :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}


  before_create :setup_account
  before_destroy :delete_local_directory

  def setup_account
    self.account = Account.find_by_name("basic")
  end

  def admin?
    return admin
  end

  def name
    return self.username.present? ? self.username : self.email
  end

  def self.deliver_signup_confirmation(id)
    user = User.find(id)
    UserMailer.signup_confirmation(user).deliver
  end

  def delete_local_directory
    dir = File.join(Configuration::DOWNLOAD_PATH, self.email)
    if File.exists?(dir)
      `rm -rf #{dir}`
    end
    return true
  end
end
