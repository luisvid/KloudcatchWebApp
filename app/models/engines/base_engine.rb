class BaseEngine
  protected
  def make_dir
    FileUtils.makedirs(@dir) unless File.exists?(@dir)
  end
end
