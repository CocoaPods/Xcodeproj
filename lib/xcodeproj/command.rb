module Xcodeproj
  require 'colored'

  class Command
    autoload :TargetDiff,  'xcodeproj/command/target_diff'
    autoload :ProjectDiff, 'xcodeproj/command/project_diff'
    autoload :Show,        'xcodeproj/command/show'
    autoload :Sort,        'xcodeproj/command/sort'

    class Help < StandardError
      def initialize(command_class, argv, unrecognized_command = nil)
        @command_class, @argv, @unrecognized_command = command_class, argv, unrecognized_command
      end

      def message
        message = [
          '',
          @command_class.banner.gsub(/\$ pod (.*)/, '$ pod \1'.green),
          '',
          'Options:',
          '',
          options,
          "\n",
        ].join("\n")
        message << "[!] Unrecognized command: `#{@unrecognized_command}'\n".red if @unrecognized_command
        message << "[!] Unrecognized argument#{@argv.count > 1 ? 's' : ''}: `#{@argv.join(' - ')}'\n".red unless @argv.empty?
        message
      end

      private

      def options
        options  = @command_class.options
        keys     = options.map(&:first)
        key_size = keys.reduce(0) { |size, key| key.size > size ? key.size : size }
        options.map { |key, desc| "    #{key.ljust(key_size)}   #{desc}" }.join("\n")
      end
    end

    class ARGV < Array
      def options
        select { |x| x.to_s[0, 1] == '-' }
      end

      def arguments
        self - options
      end

      def option(name)
        !!delete(name)
      end

      def shift_argument
        (arg = arguments[0]) && delete(arg)
      end
    end

    def self.banner
      commands = ['target-diff', 'project-diff', 'show', 'sort']
      banner   = "To see help for the available commands run:\n\n"
      banner + commands.map { |cmd| "  * $ xcodeproj #{cmd.green} --help" }.join("\n")
    end

    def self.options
      [
        ['--help',     'Show help information'],
        # ['--silent',   'Print nothing'],
        # ['--no-color', 'Print output without color'],
        # ['--verbose',  'Print more information while working'],
        ['--version',  'Prints the version of Xcodeproj'],
      ]
    end

    def self.run(*argv)
      sub_command = parse(*argv)
      sub_command.run

    rescue Interrupt
      puts '[!] Cancelled'.red
      # Config.instance.verbose? ? raise : exit(1)
      exit(1)

    rescue => e
      puts e.message
      unless e.is_a?(Informative) || e.is_a?(Help)
        puts e.backtrace
      end
      exit 1
    end

    def self.parse(*argv)
      argv = ARGV.new(argv)
      if argv.option('--version')
        require 'xcodeproj/gem_version'
        puts VERSION
        exit!(0)
      end

      show_help = argv.option('--help')

      String.send(:define_method, :colorize) { |string, _| string } if argv.option('--no-color')

      command_class = case command_argument = argv.shift_argument
                      when 'target-diff'  then TargetDiff
                      when 'project-diff' then ProjectDiff
                      when 'show'         then Show
                      when 'sort'         then Sort
                      end

      if command_class.nil?
        raise Help.new(self, argv, command_argument)
      elsif show_help
        raise Help.new(command_class, argv)
      else
        command_class.new(argv)
      end
    end

    def initialize(argv)
      raise Help.new(self.class, argv)
    end

    def xcodeproj_path
      unless @xcodeproj_path
        projects = Dir.glob('*.xcodeproj')
        if projects.size == 1
          xcodeproj_path = projects.first
        elsif projects.size > 1
          raise Informative, 'There are more than one Xcode project documents ' \
                             'in the current working directory. Please specify ' \
                             'which to use with the `--project` option.'
        else
          raise Informative, 'No Xcode project document found in the current ' \
                             'working directory. Please specify which to use ' \
                             'with the `--project` option.'
        end
        @xcodeproj_path = File.expand_path(xcodeproj_path)
      end
      @xcodeproj_path
    end

    def xcodeproj
      @xcodeproj ||= Project.open(xcodeproj_path)
    end
  end
end
