
## Master

###### Breaking

* Added support for Xcode 5 (`ARCHS` are not set anymore).  
  [CocoaPods#1352](https://github.com/CocoaPods/CocoaPods/issues/1352)

* [PBXNativeTarget] Added `#add_system_framework`, `#add_system_frameworks`,
  `#add_system_library`, `#add_system_libraries`.

* [Project] `#add_system_framework` was deprecated.

###### Enhancements

* [Command] Added new subcommand `sort`, to sort projects from the command
  line. This command is useful for sorting projects as well to easy comparison
  of existing projects.

* Decode XML entities in project paths when reading workspace files. This
  prevents double-encoding the entities (for example, &amp;apos;) when writing
  the file.  
  [amolloy](https://github.com/amolloy)

* [Project::Object] Added `#sort`.

* [Project] Added `#sort`, `#add_system_library`.

* [Project] Deprecated `#add_system_framework`.

* [Project::ObjectList] Added `#move` and `#move_from`.

* [PBXNativeTarget] Improve `#add_dependency` to avoid duplicates.

* [PBXFileReference, PBXGroup] Added `set_source_tree` and `#set_path`.

* [PBXGroup] Added `find_file_by_path`.

* [AbstractBuildPhase] Added `#file_display_names`, `#build_file`, and `#include`.

###### Bug Fixes

* [Command] Fixed opening existing projects.

* [GroupableHelper] Improved handling of ambiguous parents.

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
