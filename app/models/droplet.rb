class Droplet < ActiveRecord::Base
  scope :pending, where(:status_id => Status.find_by_name("pending").id, :in_queue => false)
  belongs_to :user
  belongs_to :status
  has_many :droplet_histories
  attr_accessible :url, :file, :name, :storage, :user, :status, :in_queue

  validates_presence_of :user, :status
    
  after_save :update_history

  def self.enqueue_downloads
    CustomHelper.debug("pending: #{pending.all.size}")
    pending.all.each do |droplet|
      CustomHelper.debug("found droplet to download")
      droplet.in_queue = true
      droplet.save
      QC.enqueue("Droplet.process_queue", droplet.id)
    end
  end

  def self.process_queue(id)
    CustomHelper.debug("processing queue item")
    droplet = find(id)
    droplet.in_queue = false
    droplet.save
    droplet.download
  end

  def download
    store = get_storage 
    #check if file in local storage
    if self.file.blank? || (self.file.present? && !File.exists?(self.file))
      dir = File.join(Configuration::DOWNLOAD_PATH, user.email)
      update_status("downloading")
      self.name, self.file = EngineFactory.get(url).download(url, dir)
    end
    manage_file(store) unless store == "inactive"
  rescue
    update_status("pending")
  end

  def upload(name, data)
    dir = File.join(Configuration::DOWNLOAD_PATH, user.email)
    FileUtils.makedirs(dir)
    self.name = name
    self.file = File.join(dir, name)
    File.open(self.file, 'wb' ) do |file|
      file.write(data.read)
    end
    store = get_storage
    manage_file(store) unless store == "inactive"
  end
  
  def update_status(name)
    self.status_id = Status.find_by_name(name).id
    save
  end

  def synch
    unless File.exists?(self.file)
      temp_file = nil
      store = get_storage
      case store
      when "dropbox"
        dropbox_session = DropboxSession.deserialize(self.user.dropbox_access_token)
        client = DropboxClient.new(dropbox_session)
        file_path = "/" + self.name
        # fetch file from dropbox
        begin
          temp_file, metadata = client.get_file_and_metadata(file_path)
        rescue Exception => e
          if e.message.scan("not found").size > 0
            CustomHelper.debug("file not found in Dropbox")
          end
          raise
        end
      when "amazon"
        s3 = AWS::S3.new
        bucket = s3.buckets["kloud_catch"] 
        amazon_key = self.user.email + "/" + self.name
        temp_file = bucket.objects[amazon_key].read
      end 
      if temp_file.present?
        File.open(self.file, "wb") do |f|
          f.write(temp_file)
        end
      end
    end
    self.update_status("synched")
  end

  def confirm
    #remove file form corresponding storage
    if File.exists?(self.file)
      case self.storage
      when "Dropbox"
        if self.user.delete_files
          dropbox_session = DropboxSession.deserialize(self.user.dropbox_access_token)
          client = DropboxClient.new(dropbox_session)
          file_path = "/" + self.name
          client.file_delete(file_path)
        end
      when "Kloud Catch"
        s3 = AWS::S3.new
        bucket = s3.buckets["kloud_catch"] 
        amazon_key = self.user.email + "/" + self.name
        bucket.objects[amazon_key].delete
      end 
      File.delete(self.file)
    end
  end
  
  private
  def update_history
    DropletHistory.create!(:droplet => self, :status => status, :user => user)
  end

  def get_storage
    store = "inactive"
    if user.account.name == "basic"
      if user.dropbox_access_token.present?
        store = "dropbox"
      else
        CustomHelper.debug("inactive dropbox")
        if user.inactive_dropbox_email_sent_at.blank? || user.inactive_dropbox_email_sent_at < DateTime.now - 1.days
          CustomHelper.debug("sending inactive dropbox alert")
          UserMailer.inactive_dropbox_email(user).deliver
        end
        raise
      end
    else
      store = "amazon"
    end
    return store
  end

  def manage_file(store)
    case store
    when "dropbox"
      CustomHelper.debug("using dropbox...")
      self.storage = "Dropbox"
      dropbox_session = DropboxSession.deserialize(user.dropbox_access_token)
      client = DropboxClient.new(dropbox_session)

      # check access token validity
      begin
        info = client.account_info()
      rescue Exception => e
        CustomHelper.debug("invalid access token")
        if e.message.scan("Unauthorized").size > 0
          user.dropbox_access_token = ""
          user.save
        end
        raise
      end
      free_mb = (info["quota_info"]["quota"] - (info["quota_info"]["shared"] + info["quota_info"]["normal"])) / 1024 / 1024
      UserMailer.dropbox_quota_warning(user).deliver if free_mb < 100
      begin
        client.metadata(self.name)
      rescue Exception => e
        if e.message.scan("not found").size > 0
          CustomHelper.debug("uploading to dropbox account")
          file = File.open(self.file)
          client.put_file("/" + self.name, file)
        else
          CustomHelper.debug("error desconocido al solictar Dropbox metadata para droplet: #{self.name}")
          raise
        end
      end
    when "amazon"
      CustomHelper.debug("using amazon...")
      self.storage = "Kloud Catch"
      s3 = AWS::S3.new
      s3.buckets.create("kloudcatch_downloads") unless s3.buckets["kloudcatch_downloads"].exists?
      bucket = s3.buckets["kloudcatch_downloads"] 
      amazon_key = user.email + "/" + self.name
      unless bucket.objects[amazon_key].exists?
        s3_file = bucket.objects[amazon_key]
        s3_file.write(:file => self.file)
      end
    end

    # delete file if local storage full
    File.delete(self.file) if Configuration.external_storage_required?
    update_status("downloaded")
  end
end
