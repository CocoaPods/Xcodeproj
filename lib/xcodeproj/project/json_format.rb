require 'atomos'
require 'fileutils'
require 'open3'
require 'pathname'
require 'tmpdir'

module Xcodeproj
  class Project
    # Reads and writes projects that use the JSON project format. Xcode 27.2
    # added this format, which stores a project in `project.xcproj` instead of
    # `project.pbxproj`.
    #
    # Xcodeproj does not parse the JSON format itself. Xcode can convert a
    # project between the two formats with `xcodebuild -convert-project`. This
    # module copies the project into a temporary project, converts the copy,
    # and reads or writes the `project.pbxproj` there with the same code that
    # handles plist projects. The project on disk only changes when a save
    # succeeds.
    #
    # The JSON format stores an identifier for only some objects, such as
    # targets and their products. xcodebuild computes the identifiers of the
    # other objects during the conversion, and those identifiers can be
    # different after the project changes. A remote Swift package reference
    # gets a new identifier on every conversion. Do not keep the UUID of an
    # object after the project is saved or opened again.
    #
    module JSONFormat
      # @return [String] The name of the file that holds a JSON format project.
      #
      FILE_NAME = 'project.xcproj'.freeze

      # @return [String] The `xcodebuild -convert-project` name of the plist
      #         format that projects are converted to when they are read.
      #
      # shortcut: this is the newest plist format in Xcode 27.2. Update it
      # when a newer Xcode adds a plist format, so that projects using newer
      # features keep them during the conversion.
      #
      PLIST_FORMAT_NAME = 'Xcode 27.0'.freeze

      # @return [String] The `xcodebuild -convert-project` name of the JSON
      #         format.
      #
      JSON_FORMAT_NAME = 'Xcode Project'.freeze

      # Reads a JSON format project.
      #
      # The conversion runs on a copy next to the project when the directory
      # of the project is writable. xcodebuild leaves out `lastKnownFileType`
      # values and target dependency names when the copy is not next to the
      # files that the project refers to.
      #
      # @param  [Pathname] xcodeproj_path
      #         The path of the `.xcodeproj` directory.
      #
      # @return [Hash] The contents the project would have as a
      #         `project.pbxproj` file.
      #
      def self.read(xcodeproj_path)
        directory = [xcodeproj_path.dirname.to_s, Dir.tmpdir].find { |candidate| File.writable?(candidate) }
        in_temporary_project(directory) do |temporary_path|
          FileUtils.cp(xcodeproj_path + FILE_NAME, temporary_path)
          convert(temporary_path, PLIST_FORMAT_NAME)
          Plist.read_from_path(temporary_path + 'project.pbxproj')
        end
      end

      # Writes a project in the JSON format.
      #
      # @param  [Pathname, String] xcodeproj_path
      #         The path of the `.xcodeproj` directory to write
      #         `project.xcproj` into.
      #
      # @yieldparam [IO] file
      #         The file to write the `project.pbxproj` contents to. The
      #         contents are converted to the JSON format afterwards.
      #
      # @return [void]
      #
      def self.write(xcodeproj_path, &block)
        in_temporary_project do |temporary_path|
          File.open(temporary_path + 'project.pbxproj', 'w', &block)
          convert(temporary_path, JSON_FORMAT_NAME)
          Atomos.atomic_write((Pathname(xcodeproj_path) + FILE_NAME).to_s) do |file|
            file.write(File.read(temporary_path + FILE_NAME))
          end
        end
      end

      # Creates an empty `.xcodeproj` directory in the given directory, or in
      # the system temporary directory, and deletes it after the block returns.
      # The name starts with a dot so that a search for `*.xcodeproj` does not
      # find it.
      #
      def self.in_temporary_project(directory = nil)
        Dir.mktmpdir(['.', '.xcodeproj'], directory) { |path| yield Pathname(path) }
      end

      # Converts the project at the given path in place.
      #
      def self.convert(xcodeproj_path, format_name)
        output, status = Open3.capture2e('xcodebuild', '-convert-project', format_name, '-project', xcodeproj_path.to_s)
        return if status.success?

        # An xcodebuild without `-convert-project` prints its whole usage text
        # after the error. The message keeps only the output before that text.
        raise Informative, conversion_error_message(format_name, output.partition(/^Usage: /).first)
      rescue SystemCallError => e
        raise Informative, conversion_error_message(format_name, e.message)
      end

      # Explains a failed conversion. The details are the xcodebuild output,
      # or the system error when xcodebuild could not run.
      #
      def self.conversion_error_message(format_name, details)
        "Unable to convert a project to the `#{format_name}` format with " \
        '`xcodebuild -convert-project`. Xcodeproj needs Xcode 27.2 or later to ' \
        "open and save projects that use `#{FILE_NAME}`.\n#{details}"
      end

      private_class_method :in_temporary_project, :convert, :conversion_error_message
    end
  end
end
