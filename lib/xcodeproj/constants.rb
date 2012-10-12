module Xcodeproj

  # This modules groups all the constants known to Xcodeproj.
  #
  module Constants

    # The last known archive version to Xcodeproj.
    #
    LAST_KNOWN_ARCHIVE_VERSION = 1

    # The last known object version to Xcodeproj.
    #
    LAST_KNOWN_OBJECT_VERSION  = 46

    # The list of all the known ISAs.
    #
    KNOWN_ISAS = {
      'AbstractObject' => %w[
      PBXBuildFile
      AbstractBuildPhase
      PBXBuildRule
      XCBuildConfiguration
      XCConfigurationList
      PBXContainerItemProxy
      PBXFileReference
      PBXGroup
      PBXNativeTarget
      PBXProject
      PBXTargetDependency
      ],

      'AbstractBuildPhase' => %w[
      PBXCopyFilesBuildPhase
      PBXResourcesBuildPhase
      PBXSourcesBuildPhase
      PBXFrameworksBuildPhase
      PBXHeadersBuildPhase
      PBXShellScriptBuildPhase
      ],

      'PBXGroup' => %w[
      XCVersionGroup
      PBXVariantGroup
      ]
    }.freeze

    # The known file types corresponding to each extension.
    #
    FILE_TYPES_BY_EXTENSION = {
      'a'           => 'archive.ar',
      'application' => 'wrapper.application',
      'dylib'       => 'compiled.mach-o.dylib',
      'framework'   => 'wrapper.framework',
      'h'           => 'sourcecode.c.h',
      'm'           => 'sourcecode.c.objc',
      'xcconfig'    => 'text.xcconfig',
      'xcdatamodel' => 'wrapper.xcdatamodel',
    }.freeze

    # The uniform type identifier of various product types.
    #
    PRODUCT_TYPE_UTI = {
      :application     => 'com.apple.product-type.application',
      :dynamic_library => 'com.apple.product-type.library.dynamic',
      :static_library  => 'com.apple.product-type.library.static',
    }.freeze

    # The common build settings grouped by platform, and build configuration
    # name.
    #
    COMMON_BUILD_SETTINGS = {
      :all => {
        'GCC_VERSION'                       => 'com.apple.compilers.llvm.clang.1_0',
        'GCC_PRECOMPILE_PREFIX_HEADER'      => 'YES',
        'PRODUCT_NAME'                      => '$(TARGET_NAME)',
        'SKIP_INSTALL'                      => 'YES',
        'DSTROOT'                           => '/tmp/xcodeproj.dst',
        'ALWAYS_SEARCH_USER_PATHS'          => 'NO',
        'GCC_C_LANGUAGE_STANDARD'           => 'gnu99',
        'INSTALL_PATH'                      => "$(BUILT_PRODUCTS_DIR)",
        'OTHER_LDFLAGS'                     => '',
        'COPY_PHASE_STRIP'                  => 'YES',
      }.freeze,
      :debug => {
        'GCC_DYNAMIC_NO_PIC'                => 'NO',
        'GCC_PREPROCESSOR_DEFINITIONS'      => ["DEBUG=1", "$(inherited)"],
        'GCC_SYMBOLS_PRIVATE_EXTERN'        => 'NO',
        'GCC_OPTIMIZATION_LEVEL'            => '0',
        'COPY_PHASE_STRIP'                  => 'NO',
      }.freeze,
      :release => {
        # Empty?
      }.freeze,
      :ios => {
        'ARCHS'                             => "$(ARCHS_STANDARD_32_BIT)",
        'IPHONEOS_DEPLOYMENT_TARGET'        => '4.3',
        'PUBLIC_HEADERS_FOLDER_PATH'        => "$(TARGET_NAME)",
        'SDKROOT'                           => 'iphoneos',
      }.freeze,
      :osx => {
        'ARCHS'                             => "$(ARCHS_STANDARD_64_BIT)",
        'GCC_ENABLE_OBJC_EXCEPTIONS'        => 'YES',
        'GCC_VERSION'                       => 'com.apple.compilers.llvm.clang.1_0',
        'MACOSX_DEPLOYMENT_TARGET'          => '10.7',
        'SDKROOT'                           => 'macosx',
        'COMBINE_HIDPI_IMAGES'              => 'YES',
      }.freeze,
      [:osx, :debug] => {
        'ONLY_ACTIVE_ARCH'                  => 'YES',
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

  end
end
