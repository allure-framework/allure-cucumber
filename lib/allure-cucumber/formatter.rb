require 'pathname'
require 'uuid'

module AllureCucumber
  class Formatter

    def initialize(step_mother, io, options)
      dir = Pathname.new(AllureCucumber::Config.output_dir)      
      FileUtils.rm_rf(dir)
      @tracker = AllureCucumber::FeatureTracker.create
    end
    
    def before_feature(feature)
      @has_background = false
      @tracker.feature_name =  feature.name.gsub!(/\n/, " ")
      AllureRSpec::Builder.start_suite(@tracker.feature_name)
    end

    def before_background(*args)
      @in_background = true
      @has_background = true
      @background_steps = []
    end

    def after_background(*args)
      @in_background = false
    end

    def before_feature_element(feature_element)
     feature_element.instance_of?(Cucumber::Ast::ScenarioOutline) ? @scenario_outline = true : @scenario_outline = false
    end

    def scenario_name(keyword, name, file_colon_line, source_indent)
      @tracker.scenario_name = (name.nil? || name == "") ? "Unnamed scenario" : name.split("\n")[0]
      AllureCucumber::Builder.start_test(@tracker.feature_name, @tracker.scenario_name)
      if @has_background
        @background_steps.each do |step|
          @tracker.step_name = "Background : #{step[:step].name}"
          AllureCucumber::Builder.start_step(@tracker.feature_name, @tracker.scenario_name, @tracker.step_name, step[:time])
          attach_multiline_arg(step[:step].multiline_arg)
          AllureCucumber::Builder.stop_step(@tracker.feature_name, @tracker.scenario_name, @tracker.step_name, step[:step].status.to_sym)        
        end
        @background_steps = []
      end
    end

    def before_steps(steps)
      @example_steps = []
      @exception = nil
    end

    def before_step(step)
      unless step.background?
        unless @scenario_outline
          @tracker.step_name = step.name
          AllureCucumber::Builder.start_step(@tracker.feature_name, @tracker.scenario_name, @tracker.step_name) 
          attach_multiline_arg(step.multiline_arg)
        else
          @example_steps << {:step => step, :time => Time.now}
        end
      else
        @background_steps << {:step => step, :time => Time.now}
      end
    end

    def after_step(step)
      unless step.background? or @scenario_outline
        @tracker.step_name = step.name
         AllureCucumber::Builder.stop_step(@tracker.feature_name, @tracker.scenario_name, @tracker.step_name, step.status.to_sym) 
      end
    end
    
    def after_steps(steps)
      return if @in_background || @in_examples || @scenario_outline
      result = { status: steps.status, exception: steps.exception }
      AllureCucumber::Builder.stop_test(@tracker.feature_name, @tracker.scenario_name, result)
    end

    def before_outline_table(outline_table)
      headers = outline_table.headers
      rows = outline_table.rows
      @current_row = -1
      @table = []
      rows.each do |element|
        row_hash = {}
        element.each_with_index do |item, index|
          row_hash[headers[index]] = item
        end
       @table << row_hash
      end
    end

    def before_examples(*args)
      @header_row = true
      @in_examples = true
    end
    
    def before_table_row(table_row)
      return unless @in_examples
      unless @header_row
        @current_row += 1
        @example_steps.each do |step| 
          @tracker.step_name = transform_step_name_for_outline(step[:step].name, @current_row)
          AllureCucumber::Builder.start_step(@tracker.feature_name, @tracker.scenario_name, @tracker.step_name, step[:time])
          attach_multiline_arg(step[:step].multiline_arg)  
        end
      end
    end
    
    def after_table_row(table_row)
      return unless @in_examples and Cucumber::Ast::OutlineTable::ExampleRow === table_row
      unless @header_row
        @outline_status = :passed
        @exception = ''
        @example_steps.each do |step| 
          @tracker.step_name = transform_step_name_for_outline(step[:step].name, @current_row)
          if table_row.status == :failed
            @outline_status = :failed
            @exception = table_row.exception
          end      
          AllureCucumber::Builder.stop_step(@tracker.feature_name, @tracker.scenario_name, @tracker.step_name, table_row.status)
        end
      end
      @header_row = false if @header_row
    end

    def after_outline_table(*args)
      @in_examples = false
      AllureCucumber::Builder.stop_test(@tracker.feature_name, @tracker.scenario_name, {status: @outline_status, exception: @exception})
    end
    
    def after_feature(feature)
      AllureCucumber::Builder.stop_suite(@tracker.feature_name)
    end

    def after_features(features)
      AllureCucumber::Builder.each_suite_build do |suite, xml|
        dir = Pathname.new(AllureCucumber::Config.output_dir)
        FileUtils.mkdir_p(dir)
        out_file = dir.join("#{UUID.new.generate}-testsuite.xml")
        File.open(out_file, 'w+') do |file|
          file.write(xml)
        end
      end
    end
    
    private
    
    def transform_step_name_for_outline(step_name, row_num)
      transformed_name = ''
      @table[row_num].each do |k, v| 
        transformed_name == '' ? transformed_name = step_name.gsub(k, v) : transformed_name = transformed_name.gsub(k,v)
      end
      "Example #{row_num + 1} : #{transformed_name}"
    end

    def attach_multiline_arg(multiline_arg)
      if multiline_arg
        File.open('tmp_file.txt', 'w'){ |file| file.write(multiline_arg.to_s.gsub(/\e\[(\d+)(;\d+)*m/,'')) }
        AllureCucumber::DSL.attach_file("table", File.open('tmp_file.txt'))
      end
    end
    
  end

end
