require 'thor'

module LicenseFinder
  module CLI
    class Base < Thor
      class_option :project_path,
                   desc: 'Path to the project. Defaults to current working directory.'
      class_option :decisions_file,
                   desc: 'Where decisions are saved. Defaults to doc/dependency_decisions.yml.'

      no_commands do
        def decisions
          license_finder.decisions
        end
      end

      private

      def license_finder
        @lf ||= LicenseFinder::Core.new(license_finder_config)
        fail "Project path '#{@lf.config.project_path}' does not exist!" unless @lf.config.valid_project_path?
        @lf
      end

      def fail(message)
        say(message) && exit(1)
      end

      def license_finder_config
        extract_options(
          :project_path,
          :decisions_file,
          :go_full_version,
          :gradle_command,
          :gradle_include_groups,
          :maven_include_groups,
          :maven_options,
          :pip_requirements_path,
          :python_path,
          :rebar_command,
          :rebar_deps_dir,
          :mix_command,
          :mix_deps_dir,
          :save,
          :prepare
        ).merge(
          logger: logger_config
        )
      end

      def logger_config
        quiet = LicenseFinder::Logger::MODE_QUIET
        debug = LicenseFinder::Logger::MODE_DEBUG
        info = LicenseFinder::Logger::MODE_INFO
        mode = extract_options(quiet, debug)
        if mode[quiet]
          { mode: quiet }
        elsif mode[debug]
          { mode: debug }
        else
          { mode: info }
        end
      end

      def say_each(coll)
        if coll.any?
          coll.each do |item|
            say(block_given? ? yield(item) : item)
          end
        else
          say '(none)'
        end
      end

      def assert_some(things)
        raise ArgumentError, 'wrong number of arguments (0 for 1+)', caller unless things.any?
      end

      def extract_options(*keys)
        result = {}
        keys.each do |key|
          result[key.to_sym] = options[key.to_s] if options.key? key.to_s
        end
        result
      end
    end
  end
end
