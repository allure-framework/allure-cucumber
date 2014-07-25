require 'rexml/text'
require 'nokogiri'

module AllureCucumber

  class Builder
    class << self
      attr_accessor :suites
      MUTEX = Mutex.new
      
      def init_suites
        MUTEX.synchronize {
          self.suites ||= {}
        }
      end
      
      def start_suite(title)
        init_suites
        MUTEX.synchronize do
          puts "Starting suite : #{title}"
          self.suites[title] = {
                                :title => title,
                                :start => timestamp,
                                :tests => {},
                               }
        end
      end

      def start_test(suite, test, severity = :normal)
        MUTEX.synchronize do
          puts "Starting test : #{test}"
          self.suites[suite][:tests][test] = {
                                              :title => test,
                                              :start => timestamp,
                                              :severity => severity,
                                              :failure => nil,
                                              :steps => {},
                                              :attachments => []
                                             }
        end
      end

      def stop_test(suite, test, result = {})
        self.suites[suite][:tests][test][:steps].each do |step_title, step|
          if step[:stop].nil? || step[:stop] == 0
            stop_step(suite, test, step_title, result[:status])
          end
        end
        MUTEX.synchronize do
          puts "Stopping test : #{test}"
          self.suites[suite][:tests][test][:stop] = timestamp(result[:finished_at])
          self.suites[suite][:tests][test][:start] = timestamp(result[:started_at])
          self.suites[suite][:tests][test][:status] = result[:status]
          if (result[:status].to_sym != :passed)
            self.suites[suite][:tests][test][:failure] = {
                                                          :stacktrace => escape((result[:caller] || []).map { |s| s.to_s }.join("\r\n")),
                                                          :message => escape(result[:exception].to_s),
                                                         } 
          end

        end
      end

      def escape(text)
        text
      end

      def start_step(suite, test, step, time = nil, severity = :normal)
        MUTEX.synchronize do
          puts "Starting step : #{step}"
          self.suites[suite][:tests][test][:steps][step] = {
                                                            :title => step,
                                                            :start => timestamp(time),
                                                            :severity => severity || :normal,
                                                            :attachments => []
                                                           }
        end
      end

      def add_attachment(suite, test, attachment, step = nil)
        attach = {
                  :title => attachment[:title],
                  :source => attachment[:source],
                  :type => attachment[:type],
                  :size => attachment[:size],
                 }
        if step.nil?
          self.suites[suite][:tests][test][:attachments] << attach
        else
          self.suites[suite][:tests][test][:steps][step][:attachments] << attach
        end
      end

      def stop_step(suite, test, step, status = :passed, time = nil)
        MUTEX.synchronize do
          puts "Stopping step : #{step}"
          self.suites[suite][:tests][test][:steps][step][:stop] = timestamp(time)
          self.suites[suite][:tests][test][:steps][step][:status] = status
        end
      end

      def stop_suite(title)
        init_suites
        MUTEX.synchronize do
          puts "Stopping suite : #{title}"
          self.suites[title][:stop] = timestamp
        end
      end

      def timestamp(time = nil)
        ((time || Time.now).to_f * 1000).to_i
      end

      def each_suite_build(&block)
        suites_xml = []
        self.suites.each do |suite_title, suite|
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.send "ns2:test-suite", :start => suite[:start] || 0, :stop => suite[:stop] || 0, 'xmlns' => '', "xmlns:ns2" => "urn:model.allure.qatools.yandex.ru" do
              xml.send "name", suite_title
              xml.send "test-cases" do
                suite[:tests].each do |test_title, test|
                  xml.send "test-case", :start => test[:start] || 0, :stop => test[:stop] || 0, :status => test[:status] do
                    xml.send "name", test_title
                    unless test[:failure].nil?
                      xml.failure do
                        xml.message test[:failure][:message]
                        xml.send "stack-trace", test[:failure][:stacktrace]
                      end
                    end
                    xml.steps do
                      test[:steps].each do |step_title, step_obj|
                        xml.step(:start => step_obj[:start] || 0, :stop => step_obj[:stop] || 0, :status => step_obj[:status]) do
                          xml.send "name", step_title
                          xml.attachments do
                            step_obj[:attachments].each do |attach|
                              xml.attachment :source => attach[:source], :title => attach[:title], :size => attach[:size], :type => attach[:type]
                            end
                          end
                        end
                      end
                    end
                    xml.attachments do
                      test[:attachments].each do |attach|
                        xml.attachment :source => attach[:source], :title => attach[:title], :size => attach[:size], :type => attach[:type]
                      end
                    end
                    xml.labels do
                      xml.label :name => "severity", :value => test[:severity]
                    end
                    xml.parameters
                  end
                end
              end
            end
          end
          xml = builder.to_xml
          yield suite, xml
          suites_xml << xml
        end
        suites_xml
      end
    end
  end
end
