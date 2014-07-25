require 'digest'
require 'mimemagic'
module AllureCucumber
  module DSL

    ALLOWED_ATTACH_EXTS = %w[txt html xml png jpg json]

    def attach_file(title, file)
      step = __current_step
      dir = Pathname.new(AllureCucumber::Config.output_dir)
      FileUtils.mkdir_p(dir)
      file_extname = File.extname(file.path.downcase)
      type = MimeMagic.by_path(file.path) || "text/plain"
      attachment = dir.join("#{Digest::SHA256.file(file.path).hexdigest}-attachment#{(file_extname.empty?) ? '' : file_extname}")
      FileUtils.cp(file.path, attachment)
      suite = self.example.metadata[:example_group][:description_args].first
      test = self.example.metadata[:description]
      AllureCucumber::Builder.add_attachment(suite, test, {
          :type => type,
          :title => title,
          :source => attachment.basename,
          :size => File.stat(attachment).size
      }, step)
    end

  end
end
