require 'digest'
require 'mimemagic'
module AllureCucumber
  module DSL

    def attach_file(title, file)
      @tracker = AllureCucumber::FeatureTracker.tracker
      dir = Pathname.new(AllureCucumber::Config.output_dir)
      FileUtils.mkdir_p(dir)
      file_extname = File.extname(file.path.downcase)
      type = MimeMagic.by_path(file.path) || "text/plain"
      attachment = dir.join("#{Digest::SHA256.file(file.path).hexdigest}-attachment#{(file_extname.empty?) ? '' : file_extname}")
      FileUtils.cp(file.path, attachment)
      AllureCucumber::Builder.add_attachment(@tracker.feature_name, @tracker.scenario_name, {
                                                                                             :type => type,
                                                                                             :title => title,
                                                                                             :source => attachment.basename,
                                                                                             :size => File.stat(attachment).size
                                                                                            }, @tracker.step_name)
    end

  end
end
