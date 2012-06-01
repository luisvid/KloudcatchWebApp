PDFKit.configure do |config|
  config.wkhtmltopdf =  "/usr/bin/wkhtmltopdf" #uncomment and adapt path for production
  config.default_options = {
     :page_size => 'A4',
     :print_media_type => true
  }
  config.root_url = "http://www.kloudcatch.com"
  #config.root_url = "http://localhost" #development
end
