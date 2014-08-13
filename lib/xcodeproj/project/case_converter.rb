module Xcodeproj
  class Project
    module Object
      # Converts between camel case names used in the xcodeproj plist files
      # and the ruby symbols used to represent them.
      #
      module CaseConverter
        # @return [String] The plist equivalent of the given Ruby name.
        #
        # @param  [Symbol, String] name
        #         The name to convert
        #
        # @param  [Symbol, Nil] type
        #         The type of conversion. Pass `nil` for normal camel case and
        #         `:lower` for camel case starting with a lower case letter.
        #
        # @example
        #   CaseConverter.convert_to_plist(:project_ref) #=> ProjectRef
        #
        def self.convert_to_plist(name, type = nil)
          case name
          when :remote_global_id_string
            'remoteGlobalIDString'
          else
            if type == :lower
              cache = plist_cache[:lower] ||= {}
              cache[name] ||= name.to_s.camelize(:lower)
            else
              cache = plist_cache[:normal] ||= {}
              cache[name] ||= name.to_s.camelize
            end
          end
        end

        # @return [Symbol] The Ruby equivalent of the given plist name.
        #
        # @param  [String] name
        #         The name to convert
        #
        # @example
        #   CaseConverter.convert_to_ruby('ProjectRef') #=> :project_ref
        #
        def self.convert_to_ruby(name)
          name.to_s.underscore.to_sym
        end

        # @return [Hash] A cache for the conversion to the Plist format.
        #
        # @note   A cache is used because this operation is performed for each
        #         attribute of the project when it is saved and caching it has
        #         an important performance benefit.
        #
        def self.plist_cache
          @plist_cache ||= {}
        end
      end
    end
  end
end
