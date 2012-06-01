class Configuration
  MAX_DOWNLOADS = 3
  DOWNLOAD_PATH = "/home/jochen/apps/kloudcatch/downloads/" #production!
  #DOWNLOAD_PATH = "/home/joito/Programmierung/kloudcatch/downloads/"

  def self.external_storage_required?
    disk_free = %x(df -h .)
    used = disk_free.match(/\d{1,3}(%)/)[0].split("%")[0].to_i
    used > 75
  end
end
