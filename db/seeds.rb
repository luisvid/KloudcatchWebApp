["pending", "downloading", "downloaded", "synched", "removed"].each do |s|  
  Status.find_or_create_by_name s  
end  

Account.find_or_create_by_name_and_description_and_cost("basic", "Dropbox", "0")
