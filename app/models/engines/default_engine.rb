require 'open-uri'

class DefaultEngine < BaseEngine

  def download(url, dir)
    @url = url
    @dir = dir
    get_source
    find_title
    make_dir
    html_to_pdf
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
    unless vidtitle.nil?
      @title = vidtitle[0].gsub("<meta name=\"title\" content=\"","").gsub("\">","").gsub(/ /,'_').gsub(/\W+/, '')[0...64]+".pdf"
      return
    end
    
    rgtitlesearch = Regexp.new(/\<title>.*<\/title>/)
    vidtitle = rgtitlesearch.match(@source)
    unless vidtitle.nil?
      @title = vidtitle[0].gsub("<title>","").gsub("<\/title>","").gsub(/ /,'_').gsub(/\W+/, '')[0...64]+".pdf"
      return
    end
    
    if @title.nil?
      @title = @url.to_s.gsub(/ /,'_').gsub(/\W+/, '')[0...64]+".pdf"
    end
  end
  
  def html_to_pdf
    #@file = File.join(@dir, @title)
    #pdf = `sudo wkhtmltopdf #{@url} #{@file}`
    kit = PDFKit.new(@url)
    @file = File.join(@dir, @title)
    kit.to_file(@file)
  end

end
