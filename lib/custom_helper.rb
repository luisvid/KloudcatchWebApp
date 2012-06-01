class CustomHelper
  def self.debug(content)
    p content if Rails.env.eql?("development")
  end

  def self.app_url(req=nil)
    uri = "http://localhost:3000"
    unless Rails.env.eql?("development")
      if req.present?
        domain = req.url.split("http://")[1][0..2]
        case domain
        when "www"
          uri = "http://www.kloudcatch.com"
        else
          uri = "http://kloudcatch.com"
        end
      else
        uri = "http://www.kloudcatch.com"
      end
    end
    return uri
  end
end
