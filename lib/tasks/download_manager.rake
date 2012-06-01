namespace :kloud do
  #desc "Start downloading next file if there are enough resources"
  #task :catch => :environment do
  #  active = Droplet.where(:status_id => status_id("downloading")).count
  #  
  #  if(active < Configuration::MAX_DOWNLOADS)
  #    droplet = Droplet.where(:status_id => status_id("pending")).first
  #    droplet.download unless droplet.nil?
  #  end
  #end
  #
  desc "Enqueue droplet downloads"
  task :catch => :environment do
    Droplet.where(:status_id => status_id("pending")).all.each do |droplet|
      QC.enqueue("Droplet.download_droplet", droplet.id)
    end
  end
  
  def status_id(name)
    Status.find_by_name(name).id
  end
end
