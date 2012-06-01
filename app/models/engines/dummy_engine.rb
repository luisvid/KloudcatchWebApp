class DummyEngine < BaseEngine

  def download(url, dir)
    p "No matching engine for url: #{url}"
  end

end