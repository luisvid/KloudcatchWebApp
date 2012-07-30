class CustomHelper
  def self.debug(content)
    p content if Rails.env.eql?("development")
  end

  def self.app_url(req=nil)
    "http://#{Rails.env.development?  ? "localhost:3000" : (req.try(:host) || "kloudcatch.com")}"
  end
end
