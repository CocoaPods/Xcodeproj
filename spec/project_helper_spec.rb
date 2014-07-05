require File.expand_path('../spec_helper', __FILE__)

module ProjectHelperSpecs
  describe Xcodeproj::Project::ProjectHelper do

    def subject
      Xcodeproj::Project::ProjectHelper
    end

    shared 'configuration settings' do
      extend SpecHelper::ProjectHelper
      built_settings = subject.common_build_settings(configuration, platform, nil, product_type, (language rescue nil))
      compare_settings(built_settings, fixture_settings[configuration])
    end

    shared 'target settings' do
      describe configuration: :base do
        behaves_like 'configuration settings'
      end

      describe configuration: :debug do
        behaves_like 'configuration settings'
      end

      describe configuration: :release do
        behaves_like 'configuration settings'
      end
    end

    def target_from_fixtures(path)
      shared path do
        extend SpecHelper::ProjectHelper

        @path = path
        def self.fixture_settings
          Hash[[:base, :debug, :release].map { |c| [c, load_settings(@path, c)] }]
        end

        behaves_like 'target settings'
      end

      return path
    end

    describe '::common_build_settings' do

      describe platform: :osx do
        describe product_type: :bundle do
          behaves_like target_from_fixtures 'OSX_Bundle'
        end

        describe language: :objc do
          describe product_type: :dynamic_library do
            behaves_like target_from_fixtures 'Objc_OSX_DynamicLibrary'
          end

          describe product_type: :framework do
            behaves_like target_from_fixtures 'Objc_OSX_Framework'
          end

          describe product_type: :application do
            behaves_like target_from_fixtures 'Objc_OSX_Native'
          end

          describe product_type: :static_library do
            behaves_like target_from_fixtures 'Objc_OSX_StaticLibrary'
          end
        end

        describe language: :swift do
          describe product_type: :framework do
            behaves_like target_from_fixtures 'Swift_OSX_Framework'
          end

          describe product_type: :application do
            behaves_like target_from_fixtures 'Swift_OSX_Native'
          end
        end
      end

      describe platform: :ios do

        # TODO: Create a target and dump its config
        #describe product_type: :bundle do
        #  behaves_like target_from_fixtures 'iOS_Bundle'
        #end

        describe language: :objc do
          describe product_type: :framework do
            behaves_like target_from_fixtures 'Objc_iOS_Framework'
          end

          describe product_type: :application do
            behaves_like target_from_fixtures 'Objc_iOS_Native'
          end

          describe product_type: :static_library do
            behaves_like target_from_fixtures 'Objc_iOS_StaticLibrary'
          end
        end

        describe language: :swift do
          describe product_type: :framework do
            behaves_like target_from_fixtures 'Swift_iOS_Framework'
          end

          describe product_type: :application do
            behaves_like target_from_fixtures 'Swift_iOS_Native'
          end
        end

      end

    end
  end
end
