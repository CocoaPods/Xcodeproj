module Xcodeproj
  # This modules groups all the constants known to Xcodeproj.
  #
  module Constants
    # @return [String] The last known iOS SDK (stable).
    #
    LAST_KNOWN_IOS_SDK = '7.1'

    # @return [String] The last known OS X SDK (stable).
    #
    LAST_KNOWN_OSX_SDK  = '10.9'

    # @return [String] The last known archive version to Xcodeproj.
    #
    LAST_KNOWN_ARCHIVE_VERSION = 1

    # @return [String] The last known object version to Xcodeproj.
    #
    LAST_KNOWN_OBJECT_VERSION  = 46

    # @return [String] The last known object version to Xcodeproj.
    #
    LAST_UPGRADE_CHECK  = '0510'

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
      :application      => 'com.apple.product-type.application',
      :framework        => 'com.apple.product-type.framework',
      :dynamic_library  => 'com.apple.product-type.library.dynamic',
      :static_library   => 'com.apple.product-type.library.static',
      :bundle           => 'com.apple.product-type.bundle',
      :unit_test_bundle => 'com.apple.product-type.bundle.unit-test',
    }.freeze

    # @return [Hash] The extensions or the various product UTIs.
    #
    PRODUCT_UTI_EXTENSIONS = {
      :application     => 'app',
      :framework       => 'framework',
      :dynamic_library => 'dylib',
      :static_library  => 'a',
      :bundle          => 'bundle',
    }.freeze

    # @return [Hash] The common build settings grouped by platform, and build
    #         configuration name.
    #
    COMMON_BUILD_SETTINGS = {
      :all => {
        'GCC_PRECOMPILE_PREFIX_HEADER'      => 'YES',
        'PRODUCT_NAME'                      => '$(TARGET_NAME)',
        'SKIP_INSTALL'                      => 'YES',
        'DSTROOT'                           => '/tmp/xcodeproj.dst',
        'ALWAYS_SEARCH_USER_PATHS'          => 'NO',
        'INSTALL_PATH'                      => '$(BUILT_PRODUCTS_DIR)',
        'OTHER_LDFLAGS'                     => '',
        'COPY_PHASE_STRIP'                  => 'YES',
      }.freeze,
      :debug => {
        'GCC_DYNAMIC_NO_PIC'                => 'NO',
        'GCC_PREPROCESSOR_DEFINITIONS'      => ['DEBUG=1', '$(inherited)'],
        'GCC_SYMBOLS_PRIVATE_EXTERN'        => 'NO',
        'GCC_OPTIMIZATION_LEVEL'            => '0',
        'COPY_PHASE_STRIP'                  => 'NO',
      }.freeze,
      :release => {
        'OTHER_CFLAGS'                      => ['-DNS_BLOCK_ASSERTIONS=1', '$(inherited)'],
        'OTHER_CPLUSPLUSFLAGS'              => ['-DNS_BLOCK_ASSERTIONS=1', '$(inherited)'],
      }.freeze,
      :ios => {
        'IPHONEOS_DEPLOYMENT_TARGET'        => '4.3',
        'PUBLIC_HEADERS_FOLDER_PATH'        => '$(TARGET_NAME)',
        'SDKROOT'                           => 'iphoneos',
      }.freeze,
      :osx => {
        'GCC_ENABLE_OBJC_EXCEPTIONS'        => 'YES',
        'GCC_VERSION'                       => 'com.apple.compilers.llvm.clang.1_0',
        'MACOSX_DEPLOYMENT_TARGET'          => '10.7',
        'SDKROOT'                           => 'macosx',
        'COMBINE_HIDPI_IMAGES'              => 'YES',
      }.freeze,
      [:osx, :debug] => {
        # Empty?
      }.freeze,
      [:osx, :release] => {
        'DEBUG_INFORMATION_FORMAT'          => 'dwarf-with-dsym',
      }.freeze,
      [:ios, :debug] => {
        # Empty?
      }.freeze,
      [:ios, :release] => {
        'VALIDATE_PRODUCT'                  => 'YES',
      }.freeze,
    }.freeze

    # @return [Hash] The default build settings for a new project.
    #
    PROJECT_DEFAULT_BUILD_SETTINGS = {
      :all => {
        'ALWAYS_SEARCH_USER_PATHS'         => 'NO',
        'CLANG_CXX_LANGUAGE_STANDARD'      => 'gnu++0x',
        'CLANG_CXX_LIBRARY'                => 'libc++',
        'CLANG_ENABLE_OBJC_ARC'            => 'YES',
        'CLANG_WARN_BOOL_CONVERSION'       => 'YES',
        'CLANG_WARN_CONSTANT_CONVERSION'   => 'YES',
        'CLANG_WARN_DIRECT_OBJC_ISA_USAGE' => 'YES',
        'CLANG_WARN_EMPTY_BODY'            => 'YES',
        'CLANG_WARN_ENUM_CONVERSION'       => 'YES',
        'CLANG_WARN_INT_CONVERSION'        => 'YES',
        'CLANG_WARN_OBJC_ROOT_CLASS'       => 'YES',
        'CLANG_ENABLE_MODULES'             => 'YES',
        'GCC_C_LANGUAGE_STANDARD'          => 'gnu99',
        'GCC_WARN_64_TO_32_BIT_CONVERSION' => 'YES',
        'GCC_WARN_ABOUT_RETURN_TYPE'       => 'YES',
        'GCC_WARN_UNDECLARED_SELECTOR'     => 'YES',
        'GCC_WARN_UNINITIALIZED_AUTOS'     => 'YES',
        'GCC_WARN_UNUSED_FUNCTION'         => 'YES',
        'GCC_WARN_UNUSED_VARIABLE'         => 'YES',
      },
      :release => {
        'COPY_PHASE_STRIP'                 => 'NO',
        'ENABLE_NS_ASSERTIONS'             => 'NO',
        'VALIDATE_PRODUCT'                 => 'YES',
      }.freeze,
      :debug => {
        'ONLY_ACTIVE_ARCH'                 => 'YES',
        'COPY_PHASE_STRIP'                 => 'YES',
        'GCC_DYNAMIC_NO_PIC'               => 'NO',
        'GCC_OPTIMIZATION_LEVEL'           => '0',
        'GCC_PREPROCESSOR_DEFINITIONS'     => ['DEBUG=1', '$(inherited)'],
        'GCC_SYMBOLS_PRIVATE_EXTERN'       => 'NO',
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

    # @return [Hash] The extensions which are associated with header files.
    #
    HEADER_FILES_EXTENSIONS = %w(.h .hh .hpp .ipp).freeze
  end
end
