module RGen
  class Generator
    class Resources
      attr_accessor :top_level

      def create(options = {}, &block)
        # Refresh the target to start all settings from scratch each time
        # This is an easy way to reset all registered values
        RGen.app.reload_target!
        RGen.tester.generating = :program
        sub_flow = @top_level
        @top_level = true unless @top_level
        job.output_file_body = options.delete(:name).to_s if options[:name]
        if sub_flow
          interface = RGen.interface
          interface.resources_mode do
            opts = RGen.generator.option_pipeline.pop || {}
            interface.instance_exec(opts, &block)
          end
          interface.close(sub_resource: true)
        else
          RGen.log.info "Generating... #{RGen.file_handler.current_file.basename}"
          interface = RGen.reset_interface(options)
          interface.resources_mode do
            interface.instance_eval(&block)
          end
          interface.close
        end
      end

      def reset
        @top_level = false
      end

      def job
        RGen.app.current_job
      end
    end
  end
end
