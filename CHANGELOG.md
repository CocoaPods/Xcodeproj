# Xcodeproj Changelog

## master

###### Enhancements

* [PlistHelper] The xcode native extension has been removed and it has been
  removed in favour of the usage of the `plutil` tool to read ASCII property
  list files.  
  [Fabio Pelosin](https://github.com/irrationalfab)
  [Xcodeproj#168](https://github.com/CocoaPods/Xcodeproj/pull/168)
  [Xcodeproj#167](https://github.com/CocoaPods/Xcodeproj/issues/167)

* [PBXFileReference] If a file reference represents an external Xcode project
  and is removed from the project then all items related to the external
  project will also be removed.
  [JP Simard](https://github.com/jpsim)
  [Eloy Durán](https://github.com/alloy)
  [Xcodeproj#158](https://github.com/CocoaPods/Xcodeproj/issues/158)
  [Xcodeproj#161](https://github.com/CocoaPods/Xcodeproj/pull/161)

###### Bug fixes

* [Workspace] Fixed adding a project to a workspace.
  [Alessandro Orrù](https://github.com/alessandroorru)
  [Xcodeproj#155](https://github.com/CocoaPods/Xcodeproj/pull/155)

## 0.17.0

###### Enhancements

* [Workspace] Added support for file references.  
  [Kyle Fuller](https://github.com/kylef)
  [Fabio Pelosin](https://github.com/irrationalfab)
  [Xcodeproj#105](https://github.com/CocoaPods/Xcodeproj/pull/150)

## 0.16.1

###### Minor Enhancements

* [Constants] Added support for .ipp files as headers.  
  [Samuel E. Giddins](https://github.com/segiddins)

###### Bug Fixes

* [Xcodeproj::Project#reference_for_path] Support for string parameter.  
  [jlj](https://github.com/jlj)

## 0.16.0

###### Breaking

* [Constants] Disable errors on warnings for default build settings  
  [Fabio Pelosin](https://github.com/irrationalfab)


## 0.15.3

###### Bug Fixes

* [Extension] Fixed build on OS X 10.9's system Ruby (2.0.0).
  [Eloy Durán](https://github.com/alloy)


## 0.15.1

###### Bug Fixes

* [Constants] Temporarily reverting the changes to `OTHER_LDFLAGS` as the were
  creating issues in CocoaPods.  
  [Fabio Pelosin](https://github.com/irrationalfab)


## 0.15.0

###### Breaking

* [Project] Now the provided path is always expanded on initialization.  
  [Gordon Fontenot](https://github.com/gfontenot)
  [#121](https://github.com/CocoaPods/Xcodeproj/pull/121)

###### Enhancements

* [Constants] Bumped last know SDK versions.  
  [Fabio Pelosin](https://github.com/irrationalfab)
  [#141](https://github.com/CocoaPods/Xcodeproj/pull/141)

* [Constants] Removed empty `OTHER_LDFLAGS` setting to match Xcode's behaviour.  
  [Gordon Fontenot](https://github.com/gfontenot)

* [Constants] Bumped last known Xcode version to `5.1`.  
  [Romans Karpelcevs](https://github.com/coverback)
  [#138](https://github.com/CocoaPods/Xcodeproj/pull/138)

###### Bug Fixes

* [Extension] Fixed intermittent `Xcodeproj::PlistHelper.write_plist` error.  
  [Eloy Durán](https://github.com/alloy)


## 0.14.1

###### Enhancements

* Add support for absolute, group and container project references in workspaces  
  [Kyle Fuller](https://github.com/kylef)
  [#118](https://github.com/CocoaPods/Xcodeproj/issues/118)

###### Bug Fixes

* [Gem] On MRI 1.8.7 /dev/tty is considered writable when not configured,
  leading to an exception when ran in an environment without a TTY.  
  [Eloy Durán](https://github.com/alloy)
  [#111](https://github.com/CocoaPods/Xcodeproj/issues/111)
  [#112](https://github.com/CocoaPods/Xcodeproj/issues/112)

* [Gem] Ensure rake is installed.  
  [Johannes Würbach](https://github.com/johanneswuerbach)
  [#110](https://github.com/CocoaPods/Xcodeproj/pull/110)

* [bin] Ensure the version file is loaded before trying to print it.  
  [Eloy Durán](https://github.com/alloy)
  [#107](https://github.com/CocoaPods/Xcodeproj/issues/107)


## 0.14.0

###### Bug Fixes

* [Scheme] Generate correct ReferencedContainer attribute when the Xcode project
  has a non-empty `projectDirPath`.  
  [Per Eckerdal](https://github.com/pereckerdal)
  [#102](https://github.com/CocoaPods/Xcodeproj/pull/102)

###### Enhancements

* [Gem] Provide prebuilt binary versions of the C extension for the stock Ruby
  versions on both OS X 10.8 (MRI 1.8.7) and 10.9 (MRI 2.0.0). Due to the ABI
  of MRI’s C ext API not always being consistent, these will **not** install on
  Ruby versions you have installed yourself. To override the default behaviour
  you can use the `XCODEPROJ_BUILD` environment variable. Set it to `1` to
  _always_ build the C extension or to `0` to _never_ build the C extension.  
  [Eloy Durán](https://github.com/alloy)
  [#88](https://github.com/CocoaPods/Xcodeproj/issues/88)

* [Scheme] Add support for aggregate targets to `#add_build_target`.  
  [Per Eckerdal](https://github.com/pereckerdal)
  [#102](https://github.com/CocoaPods/Xcodeproj/pull/102)

* [PBXNativeTarget] Add support for subproject targets in `#add_dependency`.  
  [Per Eckerdal](https://github.com/pereckerdal)
  [#101](https://github.com/CocoaPods/Xcodeproj/pull/101)

* [Project] Add `#reference_for_path` for retrieving a file reference for a
  given absolute path.  
  [Per Eckerdal](https://github.com/pereckerdal)
  [#101](https://github.com/CocoaPods/Xcodeproj/pull/101)


## 0.13.1

###### Bug Fixes

* Fix `Unable to read data from Model.xcdatamodeld/.xccurrentversion` when
  there are more Data model versions.  
  [Pim Snel](https://github.com/mipmip)

###### Enhancements

* [AbstractTarget] Added default value for `default_configuration_name`
  attribute.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [XCConfigurationList] `common_resolved_build_setting` will now ignore nil
  values. This is an heuristic which might not closely match Xcode behaviour.
  This is done because some information, like the SDK, is usually considered at
  the target level but it might actually differ in the build configurations.
  For example nothing prevents a target to build with the iOS sdk in one
  configuration and with the OS X in another.  
  [Fabio Pelosin](https://github.com/irrationalfab)
  [CocoaPods/CocoaPods#1462](https://github.com/CocoaPods/CocoaPods/issues/1462)


## 0.13.0

###### Breaking

* [AbstractTarget] The `#sdk` method now raises if the value is not the same
  across all the build configurations. This has been done to prevent clients
  from accidentally using arbitrary values.  
  [Fabio Pelosin](https://github.com/irrationalfab)

###### Enhancements

* [AbstractTarget] Added `#resolved_build_setting` and
  `#common_resolved_build_setting`.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [XCConfigurationList] Added `#get_setting` and `#set_setting`.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [Project] Added `#build_configuration_list`.  
  [Fabio Pelosin](https://github.com/irrationalfab)


## 0.12.0

###### Breaking

* [PBXGroup] `#new_static_library` has been replaced by the more versatile
  `#new_product_ref_for_target`.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [XCScheme] Overhauled interface to support multiple targets.  
  [Jason Prado](https://github.com/jasonprado)
  [#95](https://github.com/CocoaPods/Xcodeproj/pull/95)

* [PBXGroup] renamed `#recursively_sort_by_type` to
  `#sort_recursively_by_type`.
  [Fabio Pelosin](https://github.com/irrationalfab)

###### Enhancements

* [PBXNativeTarget] `#add_system_framework` now adds the system frameworks
  relative to the developer directory. Xcode behaviour is following: if the
  target has the same SDK of the project it adds the reference relative to the
  SDK root otherwise the reference is added relative to the Developer
  directory. This can create confusion or duplication of the references of
  frameworks linked by iOS and OS X targets. For this reason the new Xcodeproj
  behaviour is to add the frameworks in a subgroup according to the platform.
  The method will also honor the SDK version of the target if available
  (otherwise the last known version is used).
  [Fabio Pelosin](https://github.com/irrationalfab)

* [Project] The project can now recreate it schemes from scratch and optionally
  hide them.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* Added support for booleans in the C extension which handles Property list
  files.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* Improvements to the generation of new targets.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [Project] Added possibility to specify the position of groups while sorting.
  [Fabio Pelosin](https://github.com/irrationalfab)

* [PBXGroup] Now defaults to sorting by name.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [XCScheme] The string representation of schemes now closely matches Xcode
  behaviour.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [PBXGroup, PBXFileReference] Added `#parents`.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [PBXGroup] Added `#recursive_children_groups`.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* [AbstractTarget] Add #sdk_version.  
  [Fabio Pelosin](https://github.com/irrationalfab)

* Added default build settings to new projects according to Xcode defaults.  
  [Fabio Pelosin](https://github.com/irrationalfab)


## 0.11.1

###### Bug Fixes

* No longer allow `PBXTargetDependency` to sort recursively. When two targets
  depend on each other, this would lead to the two targets endlessly sorting
  each other and finally crashing with a stack overflow.  
  [Eloy Durán](https://github.com/alloy)
  [CocoaPods#1384](https://github.com/CocoaPods/CocoaPods/issues/1384)


## 0.11.0

###### Breaking

* Added support for Xcode 5.

* The `ARCHS` option is not set anymore and will use Xcode’s defaults. This
  fixes the build and archive issue with the new `arm64` architecture.
  [CocoaPods#1352](https://github.com/CocoaPods/CocoaPods/issues/1352)

* The default of the `ONLY_ACTIVE_ARCH` setting has changed to `YES`
  in the `Debug` configuration. This means that if this is a static library,
  the application that links the library in will have to make the same
  adjustment, or the build will fail.

* [Project] `#add_system_framework` has been removed in favor of
  `PBXNativeTarget#add_system_framework`.

###### Enhancements

* [Command] Added new subcommand `sort`, to sort projects from the command
  line. This command is useful for sorting projects as well to easy comparison
  of existing projects.

* [Project::Object] Added `#sort`.

* [Project] Added `#sort`, `#add_system_library`.

* [Project::ObjectList] Added `#move` and `#move_from`.

* [PBXNativeTarget] Improve `#add_dependency` to avoid duplicates.

* [PBXNativeTarget] Added `#add_system_framework`, `#add_system_frameworks`,
  `#add_system_library`, `#add_system_libraries`.

* [PBXFileReference, PBXGroup] Added `set_source_tree` and `#set_path`.

* [PBXGroup] Added `find_file_by_path`.

* [AbstractBuildPhase] Added `#file_display_names`, `#build_file`, and `#include`.

###### Bug Fixes

* [Command] Fixed opening existing projects.

* [GroupableHelper] Improved handling of ambiguous parents.

* Decode XML entities in project paths when reading workspace files. This
  prevents double-encoding the entities (for example, `&amp;apos;`) when writing
  the file.
  [amolloy](https://github.com/amolloy)

* Fix C-ext memory leak by closing and releasing the CFWriteStream used to write
  projects when done.
  [#93](https://github.com/CocoaPods/Xcodeproj/pull/93)
  [jasonprado](https://github.com/jasonprado)


## 0.10.1

###### Enhancements

* Build configurations are now deeply copied.
  [CocoaPods/CocoaPods#1288](https://github.com/CocoaPods/CocoaPods/issues/1322),

## 0.10.0

###### Breaking

* To initialize a project a path is required even is the project is being
  initialized from scratch.

* To open an existing project `Xcodeproj::Project.open` should be used in place
  of `Xcodeproj::Project.new`, which now is deprecated for that purpose.

* `Project#save_as` has been renamed to `Project#save` which uses the path
  provided during initialization by default.

* The parameter to specify a subgroup of the helper methods to create file
  references and new groups (e.g. `#new_file`, `#group`)  has been deprecated.

* Removed `PBXGroup#new_xcdatamodel_group`.

* [PBXFileReference] `#update_last_known_file_type` has been renamed to
  `#set_last_known_file_type`. Added `#set_explicit_file_type`.

* [PBXGroup] Renamed `#sort_by_type!` to `#sort_by_type`.

* [Project] `#add_system_framework` now adds the reference to the frameworks
  build phase of the target as well.

###### Enhancements

* CoreData versioned models are now properly handled respecting the contents of
  the `.xccurrentversion` file.  
  [CocoaPods/CocoaPods#1288](https://github.com/CocoaPods/CocoaPods/issues/1288),
  [#83](https://github.com/CocoaPods/Xcodeproj/pull/83)  
  [Ashton-W](https://github.com/Ashton-W)

* [PBXGroup, PBXFileReference] Improved source tree handling in creation
  helpers. Now it is possible to specify the source tree which will be used to
  adjust the provided path as needed.

* Added `PBXGroup#parent`, `PBXGroup#real_path`, `PBXFileReference#parent`
  (replaces `#group`), and `PBXFileReference#real_path`.

* Xcodeproj will automatically utilize the
  [xcproj](https://github.com/0xced/xcproj) command line tool if available in
  the path of the user to touch saved projects. This will result in projects
  serialized in the exact format used by Xcode.

* [PBXGroup] Improved deletion.

* [PBXGroup] Added `#recursively_sort_by_type`.

* [PBXGroup, PBXFileReference] Added `#move`.

* [AbstractTarget] Added `#add_build_configuration`.


## 0.9.0

###### Enhancements

* Frameworks are added using the last sdks version reported by the xcodebuild if
  the target links against the last SDK.

* Improvements in the handling of file references to frameworks.

* Improvements to the schemes logic.

* Added support for resources bundle targets.

* Project::Group#new_file will now create XCVersionGroup for xcdatamodeld file.

###### Bug Fixes

* The file type of the frameworks file references has be corrected.

