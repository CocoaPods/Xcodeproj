require File.expand_path('../../spec_helper', __FILE__)

module ProjectHelperSpecs
  describe Xcodeproj::Project::ProjectHelper do
    #
    # These specs run `Xcodeproj::Project::ProjectHelper::common_build_settings`
    # against the xcconfig files in spec/fixtures/CommonBuildSettings/configs
    # with various parameter combinations.
    #
    # To update the fixtures, you can do the following:
    #
    # 1. Open a new term and exec the following rake task.
    #
    #    `rake common_build_settings:rebuild`
    #
    #    This will:
    #      * Delete the existing project and its contents.
    #      * Create a new Xcode Project.
    #      * Give an interactive guide to create the needed targets
    #      * Dump the build settings to xcconfig files
    #
    # 2. Add the files to git and commit
    #
    #    ```
    #    git add spec/fixtures/CommonBuildSettings
    #    git commit -m "[Fixtures] Updated CommonBuildSettings"
    #    ````
    #
    # 3. Run specs and modify lib/xcodeproj/constants.rb until all tests succeed
    #
    #    `rake spec:single[spec/project/project_helper_integration_spec.rb]`
    #

    def subject
      Xcodeproj::Project::ProjectHelper
    end

    shared 'configuration settings' do
      extend SpecHelper::ProjectHelper
      lang = language if respond_to?(:language)
      built_settings = subject.common_build_settings(configuration, platform, nil, product_type, lang)
      built_settings = apply_exclusions(built_settings, fixture_settings[:base]) if configuration != :base
      compare_settings(built_settings, fixture_settings[configuration], [configuration, platform, product_type, lang])
    end

    shared 'target settings' do
      describe 'in base configuration' do
        define :configuration => :base
        behaves_like 'configuration settings'
      end

      describe 'in Debug configuration' do
        define :configuration => :debug
        behaves_like 'configuration settings'
      end

      describe 'in Release configuration' do
        define :configuration => :release
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

      path
    end

    describe '::common_build_settings' do
      describe 'on platform OSX' do
        define :platform => :osx

        describe 'for product type bundle' do
          define :product_type => :bundle
          behaves_like target_from_fixtures 'OSX_Bundle'
        end

        describe 'in language Objective-C' do
          define :language => :objc

          describe 'for product type Dynamic Library' do
            define :product_type => :dynamic_library
            behaves_like target_from_fixtures 'Objc_OSX_DynamicLibrary'
          end

          describe 'for product type Framework' do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Objc_OSX_Framework'
          end

          describe 'for product type Application' do
            define :product_type => :application
            behaves_like target_from_fixtures 'Objc_OSX_Native'
          end

          describe 'for product type Static Library' do
            define :product_type => :static_library
            behaves_like target_from_fixtures 'Objc_OSX_StaticLibrary'
          end
        end

        describe 'in language Swift' do
          define :language => :swift

          describe 'for product type Framework' do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Swift_OSX_Framework'
          end

          describe 'for product type Application' do
            define :product_type => :application
            behaves_like target_from_fixtures 'Swift_OSX_Native'
          end
        end
      end

      describe 'on platform iOS' do
        define :platform => :ios

        # TODO: Create a target and dump its config
        # describe "for product type Bundle" do
        #  define product_type: :bundle
        #  behaves_like target_from_fixtures 'iOS_Bundle'
        # end

        describe 'in language Objective-C' do
          define :language => :objc

          describe 'for product type Framework' do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Objc_iOS_Framework'
          end

          describe 'for product type Application' do
            define :product_type => :application
            behaves_like target_from_fixtures 'Objc_iOS_Native'
          end

          describe 'for product type Static Library' do
            define :product_type => :static_library
            behaves_like target_from_fixtures 'Objc_iOS_StaticLibrary'
          end
        end

        describe 'in language Swift' do
          define :language => :swift

          describe 'for product type Framework' do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Swift_iOS_Framework'
          end

          describe 'for product type Application' do
            define :product_type => :application
            behaves_like target_from_fixtures 'Swift_iOS_Native'
          end
        end
      end

      describe 'on platform watchOS' do
        define :platform => :watchos

        # TODO: Create a target and dump its config
        # describe "for product type Bundle" do
        #  define product_type: :bundle
        #  behaves_like target_from_fixtures 'watchOS_Bundle'
        # end

        describe 'in language Objective-C' do
          define :language => :objc

          describe 'for product type Framework' do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Objc_watchOS_Framework'
          end

          describe 'for product type Application' do
            define :product_type => :application
            behaves_like target_from_fixtures 'Objc_watchOS_Native'
          end

          describe 'for product type Static Library' do
            define :product_type => :static_library
            behaves_like target_from_fixtures 'Objc_watchOS_StaticLibrary'
          end
        end

        describe 'in language Swift' do
          define :language => :swift

          describe 'for product type Framework' do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Swift_watchOS_Framework'
          end

          describe 'for product type Application' do
            define :product_type => :application
            behaves_like target_from_fixtures 'Swift_watchOS_Native'
          end
        end
      end

      describe 'on platform tvOS' do
        define :platform => :tvos

        # TODO: Create a target and dump its config
        # describe "for product type Bundle" do
        #  define product_type: :bundle
        #  behaves_like target_from_fixtures 'tvOS_Bundle'
        # end

        describe 'in language Objective-C' do
          define :language => :objc

          describe 'for product type Framework' do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Objc_tvOS_Framework'
          end

          describe 'for product type Application' do
            define :product_type => :application
            behaves_like target_from_fixtures 'Objc_tvOS_Native'
          end

          describe 'for product type Static Library' do
            define :product_type => :static_library
            behaves_like target_from_fixtures 'Objc_tvOS_StaticLibrary'
          end
        end

        describe 'in language Swift' do
          define :language => :swift

          describe 'for product type Framework' do
            define :product_type => :framework
            behaves_like target_from_fixtures 'Swift_tvOS_Framework'
          end

          describe 'for product type Application' do
            define :product_type => :application
            behaves_like target_from_fixtures 'Swift_tvOS_Native'
          end
        end
      end
    end
  end
end
