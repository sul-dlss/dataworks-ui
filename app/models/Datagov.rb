class Datagov < Ckan
  def initialize
    @base_datasets_url = "https://catalog.data.gov/api/3/action/package_show"
  end
end