module GradingHelper
  def self.upload(files, dest)
    UploadHelper.upload(files, dest)
  end

  def self.delete(files)
    UploadHelper.delete(files)
  end

  def self.delete!(files)
    UploadHelper.delete!(files)
  end

  def self.unzip(zip, dest)
    UploadHelper.unzip(zip, dest, from_moodle: true)
  end

  def self.exec(cmd, *args)
    args = args.join(' ')
    puts "#{'exec>'.bold} #{cmd.green} #{args}"

    full_cmd = "#{cmd} #{args}"
    output = []
    Open3.popen3(full_cmd) do |_, stdout, stderr, _|
      output = [stdout.read.gsub(%r{[/\w]+/}, '').strip,
                stderr.read.gsub(%r{[/\w]+/}, '').strip]
    end
    puts "  #{'stdout:'.magenta.bold} #{output[0].gsub("\n", "\n#{' ' * 10}")}"
    puts "  #{'stderr:'.magenta.bold} #{output[1].gsub("\n", "\n#{' ' * 10}")}"
    output
  end
end
