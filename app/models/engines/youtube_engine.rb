require 'open-uri'

class YoutubeEngine < BaseEngine

  def download(url, dir)
    @url = url
    @dir = dir
    get_source
    find_title
    find_link
    make_dir
    download_video
    return @title, @file
  end
  
  private
  def get_source
    file = open(@url)
    raise "bad status" unless file.status[0].eql? "200"
    @source = file.read
  end
  
  def find_title
    rgtitlesearch = Regexp.new(/\<meta name="title" content=.*/)
    vidtitle = rgtitlesearch.match(@source)
    @title = vidtitle[0].gsub("<meta name=\"title\" content=\"","").gsub("\">","").gsub(/ /,'_').gsub(/\W+/, '')+".flv"
  end
  
  def find_link
    rglinksearch = Regexp.new(/,url=.*\\u0026quality=/)
    vidlink = rglinksearch.match(@source)
    vidlink[0].split(",url=").each do |foundlinks|
    @link = foundlinks.gsub(",url=","").gsub("\\u0026quality=","").gsub("%3A",":").gsub("%2F","/").gsub("%3F","?").gsub("%3D","=").gsub("%252C",",").gsub("%253A",":").gsub("%26","&")
    end
  end
    

  def download_video
    @file = File.join(@dir, @title)
    out = open(@file, "wb")
    out.write(open(@link).read)
  rescue
    # Something went wrong
  ensure
    out.close
  end

end
