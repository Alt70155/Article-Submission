# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:development)
Time.zone = "Tokyo"
ActiveRecord::Base.default_timezone = :local

class Category < ActiveRecord::Base
end
