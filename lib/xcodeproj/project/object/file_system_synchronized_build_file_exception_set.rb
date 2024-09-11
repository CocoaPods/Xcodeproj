require 'xcodeproj/project/object_attributes'
require 'xcodeproj/project/object/helpers/groupable_helper'

module Xcodeproj
  class Project
    module Object
      # This class represents a file system synchronized build file exception set.
      class PBXFileSystemSynchronizedBuildFileExceptionSet < AbstractObject
        has_one :target, AbstractTarget
        attribute :membership_exceptions, Array

        def display_name
          "Exceptions for \"#{GroupableHelper.parent(self).display_name}\" folder in \"#{target.name}\" target"
        end
      end
    end
  end
end
