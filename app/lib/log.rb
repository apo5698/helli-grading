module Log
  def self.new(name)
    dir = "log/#{Rails.env}/#{name}"
    FileUtils.mkdir_p(dir)
    file = File.open("#{dir}/#{Time.zone.today}.log", File::WRONLY | File::APPEND | File::CREAT)
    Logger.new(file, 'daily')
  end
end
