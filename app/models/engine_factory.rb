class EngineFactory

  def self.get(url)
    case url
    when /.*youtube.com.*/ then YoutubeEngine.new
    else DefaultEngine.new
    end
  end
  
end
