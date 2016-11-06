module Xcodeproj
  # This modules groups all the constants known to Xcodeproj.
  #
  module Constants
    # @return [String] The last known iOS SDK (stable).
    #
    LAST_KNOWN_IOS_SDK = '10.0'

    # @return [String] The last known OS X SDK (stable).
    #
    LAST_KNOWN_OSX_SDK = '10.12'

    # @return [String] The last known tvOS SDK (stable).
    LAST_KNOWN_TVOS_SDK = '10.0'

    # @return [String] The last known watchOS SDK (stable).
    LAST_KNOWN_WATCHOS_SDK = '3.0'

    # @return [String] The last known archive version to Xcodeproj.
    #
    LAST_KNOWN_ARCHIVE_VERSION = 1

    # @return [String] The default object version for Xcodeproj.
    DEFAULT_OBJECT_VERSION = 46

    # @return [String] The last known object version to Xcodeproj.
    #
    LAST_KNOWN_OBJECT_VERSION = 48

    # @return [String] The last known object version to Xcodeproj.
    #
    LAST_UPGRADE_CHECK = '0700'

    # @return [String] The last known object version to Xcodeproj.
    #
    LAST_SWIFT_UPGRADE_CHECK = '0730'

    # @return [String] The version of `.xcscheme` files supported by Xcodeproj
    #
    XCSCHEME_FORMAT_VERSION = '1.3'

    # @return [Hash] The all the known ISAs grouped by superclass.
    #
    KNOWN_ISAS = {
      'AbstractObject' => %w(
        PBXBuildFile
        AbstractBuildPhase
        PBXBuildRule
        XCBuildConfiguration
        XCConfigurationList
        PBXContainerItemProxy
        PBXFileReference
        PBXGroup
        PBXProject
        PBXTargetDependency
        PBXReferenceProxy
        AbstractTarget
      ),

      'AbstractBuildPhase' => %w(
        PBXCopyFilesBuildPhase
        PBXResourcesBuildPhase
        PBXSourcesBuildPhase
        PBXFrameworksBuildPhase
        PBXHeadersBuildPhase
        PBXShellScriptBuildPhase
      ),

      'AbstractTarget' => %w(
        PBXNativeTarget
        PBXAggregateTarget
        PBXLegacyTarget
      ),

      'PBXGroup' => %w(
        XCVersionGroup
        PBXVariantGroup
      ),
    }.freeze

    # @return [Hash] The known file types corresponding to each extension.
    #
    FILE_TYPES_BY_EXTENSION = {
      'a'           => 'archive.ar',
      'app'         => 'wrapper.application',
      'bundle'      => 'wrapper.plug-in',
      'dylib'       => 'compiled.mach-o.dylib',
      'framework'   => 'wrapper.framework',
      'h'           => 'sourcecode.c.h',
      'm'           => 'sourcecode.c.objc',
      'markdown'    => 'text',
      'mdimporter'  => 'wrapper.cfbundle',
      'octest'      => 'wrapper.cfbundle',
      'pch'         => 'sourcecode.c.h',
      'plist'       => 'text.plist.xml',
      'sh'          => 'text.script.sh',
      'swift'       => 'sourcecode.swift',
      'xcassets'    => 'folder.assetcatalog',
      'xcconfig'    => 'text.xcconfig',
      'xcdatamodel' => 'wrapper.xcdatamodel',
      'xcodeproj'   => 'wrapper.pb-project',
      'xctest'      => 'wrapper.cfbundle',
      'xib'         => 'file.xib',
    }.freeze

    # @return [Hash] The uniform type identifier of various product types.
    #
    PRODUCT_TYPE_UTI = {
      :application          => 'com.apple.product-type.application',
      :framework            => 'com.apple.product-type.framework',
      :dynamic_library      => 'com.apple.product-type.library.dynamic',
      :static_library       => 'com.apple.product-type.library.static',
      :bundle               => 'com.apple.product-type.bundle',
      :octest_bundle        => 'com.apple.product-type.bundle',
      :unit_test_bundle     => 'com.apple.product-type.bundle.unit-test',
      :ui_test_bundle       => 'com.apple.product-type.bundle.ui-testing',
      :app_extension        => 'com.apple.product-type.app-extension',
      :command_line_tool    => 'com.apple.product-type.tool',
      :watch_app            => 'com.apple.product-type.application.watchapp',
      :watch2_app           => 'com.apple.product-type.application.watchapp2',
      :watch_extension      => 'com.apple.product-type.watchkit-extension',
      :watch2_extension     => 'com.apple.product-type.watchkit2-extension',
      :tv_extension         => 'com.apple.product-type.tv-app-extension',
      :messages_application => 'com.apple.product-type.application.messages',
      :messages_extension   => 'com.apple.product-type.app-extension.messages',
      :sticker_pack         => 'com.apple.product-type.app-extension.messages-sticker-pack',
      :xpc_service          => 'com.apple.product-type.xpc-service',
    }.freeze

    # @return [Hash] The extensions or the various product UTIs.
    #
    PRODUCT_UTI_EXTENSIONS = {
      :application      => 'app',
      :framework        => 'framework',
      :dynamic_library  => 'dylib',
      :static_library   => 'a',
      :bundle           => 'bundle',
      :octest_bundle    => 'octest',
      :unit_test_bundle => 'xctest',
      :app_extension    => 'appex',
      :watch2_extension => 'appex',
      :watch2_app       => 'app',
    }.freeze

    # @return [Hash] The common build settings grouped by platform, and build
    #         configuration name.
    #
    COMMON_BUILD_SETTINGS = {
      :all => {
        'ENABLE_STRICT_OBJC_MSGSEND'        => 'YES',
        'GCC_NO_COMMON_BLOCKS'              => 'YES',
        'PRODUCT_NAME'                      => '$(TARGET_NAME)',
      }.freeze,
      [:debug] => {
        'DEBUG_INFORMATION_FORMAT'          => 'dwarf',
        'MTL_ENABLE_DEBUG_INFO'             => 'YES',
      }.freeze,
      [:release] => {
        'DEBUG_INFORMATION_FORMAT'          => 'dwarf-with-dsym',
        'MTL_ENABLE_DEBUG_INFO'             => 'NO',
      }.freeze,
      [:ios] => {
        'SDKROOT'                           => 'iphoneos',
      }.freeze,
      [:osx] => {
        'SDKROOT'                           => 'macosx',
      }.freeze,
      [:tvos] => {
        'SDKROOT'                           => 'appletvos',
      }.freeze,
      [:watchos] => {
        'SDKROOT'                           => 'watchos',
      }.freeze,
      [:debug, :osx] => {
        # Empty?
      }.freeze,
      [:release, :osx] => {
        # Empty?
      }.freeze,
      [:debug, :ios] => {
        # Empty?
      }.freeze,
      [:debug, :application, :swift] => {
        'SWIFT_OPTIMIZATION_LEVEL'          => '-Onone',
      }.freeze,
      [:debug, :swift] => {
        'SWIFT_OPTIMIZATION_LEVEL'          => '-Onone',
      }.freeze,
      [:debug, :static_library, :swift] => {
      }.freeze,
      [:framework] => {
        'VERSION_INFO_PREFIX'               => '',
        'DYLIB_COMPATIBILITY_VERSION'       => '1',
        'DEFINES_MODULE'                    => 'YES',
        'DYLIB_INSTALL_NAME_BASE'           => '@rpath',
        'CURRENT_PROJECT_VERSION'           => '1',
        'VERSIONING_SYSTEM'                 => 'apple-generic',
        'DYLIB_CURRENT_VERSION'             => '1',
        'SKIP_INSTALL'                      => 'YES',
        'INSTALL_PATH'                      => '$(LOCAL_LIBRARY_DIR)/Frameworks',
      }.freeze,
      [:ios, :framework] => {
        'LD_RUNPATH_SEARCH_PATHS'           => ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks'],
        'CODE_SIGN_IDENTITY[sdk=iphoneos*]' => 'iPhone Developer',
        'TARGETED_DEVICE_FAMILY'            => '1,2',
      }.freeze,
      [:osx, :framework] => {
        'LD_RUNPATH_SEARCH_PATHS'           => ['$(inherited)', '@executable_path/../Frameworks', '@loader_path/Frameworks'],
        'FRAMEWORK_VERSION'                 => 'A',
        'CODE_SIGN_IDENTITY'                => '-',
        'COMBINE_HIDPI_IMAGES'              => 'YES',
      }.freeze,
      [:watchos, :framework] => {
        'APPLICATION_EXTENSION_API_ONLY'    => 'YES',
        'LD_RUNPATH_SEARCH_PATHS'           => ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks'],
        'TARGETED_DEVICE_FAMILY'            => '4',
      }.freeze,
      [:tvos, :framework] => {
        'LD_RUNPATH_SEARCH_PATHS'           => ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks'],
        'TARGETED_DEVICE_FAMILY'            => '3',
      }.freeze,
      [:framework, :swift] => {
        'DEFINES_MODULE'                    => 'YES',
      }.freeze,
      [:osx, :static_library] => {
        'CODE_SIGN_IDENTITY'                => '-',
        'EXECUTABLE_PREFIX'                 => 'lib',
      }.freeze,
      [:ios, :static_library] => {
        'CODE_SIGN_IDENTITY[sdk=iphoneos*]' => 'iPhone Developer',
        'OTHER_LDFLAGS'                     => '-ObjC',
        'SKIP_INSTALL'                      => 'YES',
      }.freeze,
      [:watchos, :static_library] => {
        'OTHER_LDFLAGS'                     => '-ObjC',
        'SKIP_INSTALL'                      => 'YES',
      }.freeze,
      [:tvos, :static_library] => {
        'OTHER_LDFLAGS'                     => '-ObjC',
        'SKIP_INSTALL'                      => 'YES',
      }.freeze,
      [:osx, :dynamic_library] => {
        'CODE_SIGN_IDENTITY'                => '-',
        'DYLIB_COMPATIBILITY_VERSION'       => '1',
        'DYLIB_CURRENT_VERSION'             => '1',
        'EXECUTABLE_PREFIX'                 => 'lib',
      }.freeze,
      [:application] => {
        'ASSETCATALOG_COMPILER_APPICON_NAME' => 'AppIcon',
      }.freeze,
      [:ios, :application] => {
        'CODE_SIGN_IDENTITY[sdk=iphoneos*]' => 'iPhone Developer',
        'LD_RUNPATH_SEARCH_PATHS'           => ['$(inherited)', '@executable_path/Frameworks'],
        'TARGETED_DEVICE_FAMILY'            => '1,2',
      }.freeze,
      [:osx, :application] => {
        'COMBINE_HIDPI_IMAGES'              => 'YES',
        'CODE_SIGN_IDENTITY'                => '-',
        'LD_RUNPATH_SEARCH_PATHS'           => ['$(inherited)', '@executable_path/../Frameworks'],
      }.freeze,
      [:watchos, :application] => {
        'SKIP_INSTALL'                      => 'YES',
        'TARGETED_DEVICE_FAMILY'            => '4',
      }.freeze,
      [:watchos, :application, :swift] => {
        'EMBEDDED_CONTENT_CONTAINS_SWIFT'   => 'YES',
      }.freeze,
      [:tvos, :application] => {
        'ASSETCATALOG_COMPILER_APPICON_NAME' => 'App Icon & Top Shelf Image',
        'ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME' => 'LaunchImage',
        'TARGETED_DEVICE_FAMILY'            => '3',
        'LD_RUNPATH_SEARCH_PATHS'           => ['$(inherited)', '@executable_path/Frameworks'],
      }.freeze,
      [:bundle] => {
        'PRODUCT_NAME'                      => '$(TARGET_NAME)',
        'WRAPPER_EXTENSION'                 => 'bundle',
        'SKIP_INSTALL'                      => 'YES',
      }.freeze,
      [:ios, :bundle] => {
        'SDKROOT'                           => 'iphoneos',
      }.freeze,
      [:osx, :bundle] => {
        'CODE_SIGN_IDENTITY'                => '-',
        'COMBINE_HIDPI_IMAGES'              => 'YES',
        'INSTALL_PATH'                      => '$(LOCAL_LIBRARY_DIR)/Bundles',
        'SDKROOT'                           => 'macosx',
      }.freeze,
    }.freeze

    # @return [Hash] The default build settings for a new project.
    #
    PROJECT_DEFAULT_BUILD_SETTINGS = {
      :all => {
        'ALWAYS_SEARCH_USER_PATHS'           => 'NO',
        'CLANG_ANALYZER_NONNULL'             => 'YES',
        'CLANG_CXX_LANGUAGE_STANDARD'        => 'gnu++0x',
        'CLANG_CXX_LIBRARY'                  => 'libc++',
        'CLANG_ENABLE_MODULES'               => 'YES',
        'CLANG_ENABLE_OBJC_ARC'              => 'YES',
        'CLANG_WARN__DUPLICATE_METHOD_MATCH' => 'YES',
        'CLANG_WARN_BOOL_CONVERSION'         => 'YES',
        'CLANG_WARN_CONSTANT_CONVERSION'     => 'YES',
        'CLANG_WARN_DIRECT_OBJC_ISA_USAGE'   => 'YES',
        'CLANG_WARN_EMPTY_BODY'              => 'YES',
        'CLANG_WARN_ENUM_CONVERSION'         => 'YES',
        'CLANG_WARN_INT_CONVERSION'          => 'YES',
        'CLANG_WARN_OBJC_ROOT_CLASS'         => 'YES',
        'CLANG_WARN_UNREACHABLE_CODE'        => 'YES',
        'GCC_C_LANGUAGE_STANDARD'            => 'gnu99',
        'GCC_WARN_64_TO_32_BIT_CONVERSION'   => 'YES',
        'GCC_WARN_ABOUT_RETURN_TYPE'         => 'YES',
        'GCC_WARN_UNDECLARED_SELECTOR'       => 'YES',
        'GCC_WARN_UNINITIALIZED_AUTOS'       => 'YES',
        'GCC_WARN_UNUSED_FUNCTION'           => 'YES',
        'GCC_WARN_UNUSED_VARIABLE'           => 'YES',
      },
      :release => {
        'COPY_PHASE_STRIP'                   => 'YES',
        'ENABLE_NS_ASSERTIONS'               => 'NO',
        'VALIDATE_PRODUCT'                   => 'YES',
      }.freeze,
      :debug => {
        'COPY_PHASE_STRIP'                   => 'NO',
        'ENABLE_TESTABILITY'                 => 'YES',
        'GCC_DYNAMIC_NO_PIC'                 => 'NO',
        'GCC_OPTIMIZATION_LEVEL'             => '0',
        'GCC_PREPROCESSOR_DEFINITIONS'       => ['DEBUG=1', '$(inherited)'],
        'GCC_SYMBOLS_PRIVATE_EXTERN'         => 'NO',
        'ONLY_ACTIVE_ARCH'                   => 'YES',
      }.freeze,
    }.freeze

    # @return [Hash] The corresponding numeric value of each copy build phase
    #         destination.
    #
    COPY_FILES_BUILD_PHASE_DESTINATIONS = {
      :absolute_path      =>  '0',
      :products_directory => '16',
      :wrapper            =>  '1',
      :resources          =>  '7', # default
      :executables        =>  '6',
      :java_resources     => '15',
      :frameworks         => '10',
      :shared_frameworks  => '11',
      :shared_support     => '12',
      :plug_ins           => '13',
    }.freeze

    # @return [Hash] The corresponding numeric value of each proxy type for
    #         PBXContainerItemProxy.
    PROXY_TYPES = {
      :native_target => '1',
      :reference     => '2',
    }.freeze

    # @return [Array] The extensions which are associated with header files.
    #
    HEADER_FILES_EXTENSIONS = %w(.h .hh .hpp .ipp .tpp .hxx .def).freeze
  end
end
