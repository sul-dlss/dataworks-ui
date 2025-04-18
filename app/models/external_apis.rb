class ExternalApis
  require 'net/http'
  require 'uri'
  require 'csv'
  def retrieve_dataset_metadata(source, source_identifier)
    # Which service do we use
    api_instance = external_api_class(source).new
    api_instance.retrieve_metadata(source_identifier)
  end

  def external_api_class(source)
    puts "EXTERNAL API CLASS #{source}"
    case source
    when "Dryad"
      Dryad
    when "DataCite"
      Datacite
    when "Redivis"
      Redivis
    when "Data.gov"
      Datagov
    when "SDR"
      Sdr
    when "Zenodo"
      Zenodo
    end
  end

  def dataset_preview(dataset_download_url)
    #headers = "test"
    #uri = URI(dataset_download_url)
    #req = Net::HTTP::Get.new(uri.path, { 'User-Agent' => 'Mozilla/5.0 (etc...)' })
    #Net::HTTP.start(uri.host, uri.port) { |http|
    #  resp = http.request(req)
      # head(uri.path)
      #resp.each { |k, v| headers += "#{k}: #{v}" }
    #}
   
    #http.finish if http.started?
    #headers
    resp = fetch(dataset_download_url, 5)
    read_csv_url(dataset_download_url)
    #csv_headings(resp)
    # This gives us http headers, we want actual CSV headers
    #resp.each { |k, v| "#{k}: #{v}" }.join("<br>")
  end

  # Copied from https://stackoverflow.com/questions/6934185/ruby-net-http-following-redirects
  def fetch(uri_str, limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  
    url = URI.parse(uri_str)
    req = Net::HTTP::Get.new(url.path, { 'User-Agent' => 'Mozilla/5.0 (etc...)' })
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| 
      http.request(req)
    }
    case response
    when Net::HTTPSuccess     then response
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end

  def csv_headings(response)
    CSV.foreach(response, :headers => :first_row).first
  end

  def read_csv_url(url)
    CSV.foreach(URI.open(url), :headers => :first_row).take(10)
  end

end