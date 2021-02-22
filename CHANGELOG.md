# Xcodeproj Changelog

## Master

##### Enhancements

* Add support for group options when using the sort command
  [zanchee](https://github.com/Zanchee)
  [imachumphries](https://github.com/imachumphries)
  [#807](https://github.com/CocoaPods/Xcodeproj/pull/807)

* Add support for pre/post-actions in scheme actions  
  [thiagohmcruz](https://github.com/thiagohmcruz)
  [#401](https://github.com/CocoaPods/CocoaPods/issues/401)

* Bump Xcode version constants for Xcode 12.3  
  [chuganzy](https://github.com/chuganzy)
  [amorde](https://github.com/amorde)
  [#793](https://github.com/CocoaPods/Xcodeproj/pull/793)

##### Bug Fixes

* Update Swift packages annotations to match Xcode
  [Tommaso Madonia](https://github.com/Frugghi)

* Update format of generated schemes to match the ordering Xcode uses,
  minimizing the amount of time it takes to open projects in Xcode.  
  [Samuel Giddins](https://github.com/segiddins)


## 1.19.0 (2020-10-09)

##### Enhancements

* Add support of c++ files (`hpp` and `cpp`) in `PBXFileReference:set_last_known_file_type`.  
  [romanmikhailov](https://github.com/romanmikhailov)
  [#783](https://github.com/CocoaPods/Xcodeproj/issues/783)

* Add support of dependency analysis option in `PBXShellScriptBuildPhase:always_out_of_date`.  
  [lemonspike](https://github.com/LemonSpike)
  [#785](https://github.com/CocoaPods/Xcodeproj/issues/785)

* Update default build settings for Xcode 12  
  [Samuel Giddins](https://github.com/segiddins), [Eric Amorde](https://github.com/amorde)
  [#767](https://github.com/CocoaPods/Xcodeproj/pull/767)

##### Bug Fixes

* None.  


## 1.18.0 (2020-08-12)

##### Enhancements

* Add `:application_on_demand_install_capable` product type to support App Clips.  
  [Igor Makarov](https://github.com/igor-makarov)
  [#768](https://github.com/CocoaPods/Xcodeproj/pull/768)

##### Bug Fixes

* None.  


## 1.17.1 (2020-07-17)

##### Enhancements

* Bump mininum Nanaimo gem version for Ruby 2.7 support.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#776](https://github.com/CocoaPods/Xcodeproj/pull/776)

##### Bug Fixes

* None.  


## 1.17.0 (2020-06-23)

##### Enhancements

* Add Xcode 12 object version  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#764](https://github.com/CocoaPods/Xcodeproj/pull/764)

* target_dependency: Add target proxy to `to_tree_hash`.
  [Ben Yohay](https://github.com/byohay)

##### Bug Fixes

* Prevent duplicate project references from being added to the generated workspace.  
  [Sean Reinhardt](https://github.com/seanreinhardtapps)
  [#8481](https://github.com/CocoaPods/CocoaPods/issues/8481)
  
* Fix small bug where product references have a trailing dot  
  [nickgravelyn](https://github.com/nickgravelyn)
  [#757](https://github.com/CocoaPods/Xcodeproj/pull/757)


## 1.16.0 (2020-04-10)

##### Enhancements

* Add Xcode 11.4 object version.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#744](https://github.com/CocoaPods/Xcodeproj/issues/744)

* Add new APIs to set testables or entries in schemes.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#707](https://github.com/CocoaPods/Xcodeproj/pull/707)

* Add support for macro expansions to launch actions.  
  [Eric Amorde](https://github.com/amorde)
  [#738](https://github.com/CocoaPods/Xcodeproj/pull/738)

##### Bug Fixes

* Handle project_dir_path attribute for project location.  
  [Paul Beusterien](https://github.com/paulb777)
  [Andrew](https://github.com/mad-rain)
  [#739](https://github.com/CocoaPods/Xcodeproj/pull/739)

## 1.15.0 (2020-02-04)

##### Enhancements

* None.  

##### Bug Fixes

* Fix incorrect formatting of build settings with modifiers  
  [revolter](https://github.com/revolter)
  [#706](https://github.com/CocoaPods/Xcodeproj/pull/706)


## 1.14.0 (2019-12-14)

##### Enhancements

* Provide option to look into xcconfigs for common build settings.
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#722](https://github.com/CocoaPods/Xcodeproj/pull/722)

##### Bug Fixes

* Properly serialize array settings when running `config-dump`.  
  [Samuel Giddins](https://github.com/segiddins)

* Add iMessage extensions.  
  [wade0317](https://github.com/wade0317)
  [#723](https://github.com/CocoaPods/Xcodeproj/pull/723)

* Fix errors when using mutually recursive build settings.  
  [revolter](https://github.com/revolter)
  [#727](https://github.com/CocoaPods/Xcodeproj/pull/727)


## 1.13.0 (2019-10-16)

##### Enhancements

* Add `PBXShellScriptBuildPhase` dependency file.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#705](https://github.com/CocoaPods/Xcodeproj/pull/705)
  
* Add `to_h` alias to `Config`
  [Eric Amorde](https://github.com/amorde/)
  [#710](https://github.com/CocoaPods/Xcodeproj/pull/710)

* Update PBXProject known_regions attribute to include 'Base'  
  [Liam Nichols](https://github.com/liamnichols)
  [#9187](https://github.com/CocoaPods/CocoaPods/issues/9187)

##### Bug Fixes

* Add support for `productRef` attribute for `PBXTargetDependency`.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#715](https://github.com/CocoaPods/Xcodeproj/issues/715)

* Add support for `runOncePerArchitecture` attribute for `PBXBuildRule`.  
  [Alon Karasik](https://github.com/alon-k/)
  [#712](https://github.com/CocoaPods/Xcodeproj/pull/712)


## 1.12.0 (2019-08-02)

##### Enhancements

* Add #pretty_print to PBXCopyFilesBuildPhase and PBXShellScriptBuildPhase  
  [Alex Coomans](https://github.com/drcapulet)
  [#702](https://github.com/CocoaPods/Xcodeproj/pull/702)

##### Bug Fixes

* None.  


## 1.11.1 (2019-08-02)

##### Enhancements

* None.  

##### Bug Fixes

* When resolving build settings against `xcconfig`s, allow the referenced file to be missing,
  as Xcode does.  
  [Samuel Giddins](https://github.com/segiddins)


## 1.11.0 (2019-07-09)

##### Enhancements

* Add watchapp2-container product type.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#690](https://github.com/CocoaPods/Xcodeproj/pull/690)

* Add `platformFilter` Xcode 11 entry.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#693](https://github.com/CocoaPods/Xcodeproj/issues/693)

##### Bug Fixes

* None.  


## 1.10.0 (2019-06-12)

##### Enhancements

* Support for Xcode 11 attributes and objects.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#687](https://github.com/CocoaPods/Xcodeproj/pull/687)

##### Bug Fixes

* None.  


## 1.9.0 (2019-05-02)

##### Enhancements

* Updated latest SDK versions for the release of Xcode 10.2.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* Use modern localization identifier 'en' for the development region.  
  [Steffen Matthischke](https://github.com/heeaad)
  [#669](https://github.com/CocoaPods/Xcodeproj/pull/669)

* Generating deterministic UUIDs for a project also updates `TargetAttributes`.  
  [Samuel Giddins](https://github.com/segiddins)


## 1.8.2 (2019-03-27)

##### Enhancements

* None.  

##### Bug Fixes

* Set root object compatibility version depending on object version.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso) & [Doug Mead](https://github.com/dmead28)
  [#668](https://github.com/CocoaPods/Xcodeproj/pull/668)

* Normalize xcconfig path when generating includes.  
  [bclymer](https://github.com/bclymer)


## 1.8.1 (2019-02-19)

##### Enhancements

* None.  

##### Bug Fixes

* Fix build setting variable substitution for array settings.  
  [Samuel Giddins](https://github.com/segiddins)

* Properly loads both project schemes and workspaces schemes on init and
  prevents overriding of incorrect project paths.  
  [joshdholtz](https://github.com/joshdholtz)
  [#656](https://github.com/CocoaPods/CocoaPods/pull/656)

* Serialize `BuildableReference` attributes in schemes in the same order as Xcode.  
  [Samuel Giddins](https://github.com/segiddins)

* Ensure a `GroupReference`'s path includes its parent `GroupReference`'s path. 
  Both `FileReference`s and `GroupReference`s only prepend the parent path if
  the child has a type of `group`.  
  [Kesi Maduka](https://github.com/k3zi)
  [#657](https://github.com/CocoaPods/Xcodeproj/issues/657)

* Stop leaking file handles when initializing schemes from files.  
  [Samuel Giddins](https://github.com/segiddins)


## 1.8.0 (2019-01-25)

##### Enhancements

* Add support to generating deterministic UUIDs for a list of projects.  
  [Sebastian Shanus](https://github.com/sebastianv1)
  [#627](https://github.com/CocoaPods/Xcodeproj/pull/627) 

* Add support for tbd libraries  
  [raptorxcz](https://github.com/raptorxcz)
  [#379](https://github.com/CocoaPods/Xcodeproj/issues/379)

* Add support for disableMainThreadChecker and stopOnEveryMainThreadCheckerIssue flags
  [Jacek Suliga](https://github.com/jmkk)
  [#619](https://github.com/CocoaPods/Xcodeproj/pull/619)

##### Bug Fixes

* Update default script phase values to match Xcode 10.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#652](https://github.com/CocoaPods/Xcodeproj/pull/652)

* Workspace file references now take parent group location into account  
  [Albert So](https://github.com/kingfai)
  [#630](https://github.com/CocoaPods/Xcodeproj/issues/630)  


## 1.7.0 (2018-10-17)

##### Enhancements

* Add support for launchable targets from a scheme.  
  [Derek Ostrander](https://github.com/dostrander)
  [#614](https://github.com/CocoaPods/Xcodeproj/pull/614)
  
* Update last known SDKs to iOS 12, macOS 10.14, tvOS 12, and watchOS 5  
  [Minh Nguyễn](http://github.com/1ec5/)
  [#609](https://github.com/CocoaPods/Xcodeproj/pull/609)

##### Bug Fixes

* Fix Scheme's configure_with_targets setting test targets as build. 
  [Derek Ostrander](https://github.com/dostrander)
  [#618](https://github.com/CocoaPods/Xcodeproj/issues/618)

* Support embedded workspace parsing issue 605  
  [LizCira](https://github.com/LizCira)
  [#605](https://github.com/CocoaPods/CocoaPods/issues/605) 

* Add missing Swift settings in base project template  
  [amorde](https://github.com/amorde)
  [CocoaPods #8063](https://github.com/CocoaPods/CocoaPods/issues/8063)


## 1.6.0 (2018-08-16)

##### Enhancements

* Add `.inc` file extension to header file extensions.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#597](https://github.com/CocoaPods/Xcodeproj/issues/597)

* Extend API to allow specifying platform and deployment target for `PBXAggregateTarget`.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#593](https://github.com/CocoaPods/Xcodeproj/pull/593)

* Xcode 10 changes for test schemes.  
  [Jenn Kaplan](https://github.com/jkap)
  [#583](https://github.com/CocoaPods/Xcodeproj/issues/583)

* Update default build settings for Xcode 10 beta 3.  
  [Samuel Giddins](https://github.com/segiddins)

* Allow parsing `.xcconfig` files that use `${inherited}` with multiple
  definitions for the same key.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* Only `require 'digest'` once instead of per call to `uuid_for_path`.  
  [Eric Amorde](https://github.com/amorde)
  [#580](https://github.com/CocoaPods/Xcodeproj/pull/580)

* Xcode 10 support for input file list and output file list.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#7835](https://github.com/CocoaPods/CocoaPods/issues/7835)

* Create new targets with the Xcode 10 default ordering for build phases.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#7833](https://github.com/CocoaPods/CocoaPods/issues/7833)

* Document param `product_group` of `Project.new_target`.  
  [janpio](https://github.com/janpio)
  [#594](https://github.com/CocoaPods/CocoaPods/pull/594)


## 1.5.9 (2018-05-15)

##### Enhancements

* None.

##### Bug Fixes

* Add a missing `require 'set'` so the library can be loaded.  
  [Samuel Giddins](https://github.com/segiddins)
  [#572](https://github.com/CocoaPods/Xcodeproj/issues/572)


## 1.5.8 (2018-05-09)

##### Enhancements

* Update LAST_KNOWN_IOS_SDK to 11.3  
  [Piasy](https://github.com/Piasy)

* Create new static library targets without linking against
  system frameworks, for new build system compatibility.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* Fix `add_build_configuration` for `PBXAggregateTarget`  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#565](https://github.com/CocoaPods/Xcodeproj/pull/565)  

* Fixed `undefined method isa for nil:NilClass` when deleting a Xcodeproj target.
  [JanC](https://github.com/JanC)
  [#462](https://github.com/CocoaPods/Xcodeproj/issues/462)

* Fix parsing of build settings when a key and value are not
  seprated from the `=` by whitespace
  [Daniel Petri](https://github.com/stocc)
  [#566](https://github.com/CocoaPods/Xcodeproj/issues/566)

* Serialize arrays in Xcode projects based upon the project's object version.  
  [Samuel Giddins](https://github.com/segiddins)

* Warn when encountering unknown attributes instead of bailing out.  
  [theoriginalgri](https://github.com/theoriginalgri)
  [#535](https://github.com/CocoaPods/CocoaPods/issues/535)

## 1.5.7 (2018-03-22)

##### Enhancements

* None.  

##### Bug Fixes

* Make Workspace.load_schemes load schemes in the workspace container  
  [loufranco](https://github.com/loufranco)
  [#557](https://github.com/CocoaPods/Xcodeproj/issues/557)

* Fix expanding build settings when the current build setting is a string but
  the inherited value is an array.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#7421](https://github.com/CocoaPods/CocoaPods/issues/7421)

## 1.5.6 (2018-02-04)

##### Enhancements

* None.  

##### Bug Fixes

* Disable Objective-C weak references by default for new targets
  whose deployment targets do not support them.  
  [Samuel Giddins](https://github.com/segiddins)
  [#544](https://github.com/CocoaPods/Xcodeproj/issues/544)


## 1.5.5 (2018-02-02)

##### Enhancements

* Atomically write `project.pbxproj` files, so that Xcode will never see them
  in a half-written state.  
  [Samuel Giddins](https://github.com/segiddins)

* Update default build settings for Xcode 9.3.  
  [Samuel Giddins](https://github.com/segiddins)

* Allow to create a buildable reference to another project's target.  
  [Simon Seyer](https://github.com/simonseyer)
  [#543](https://github.com/CocoaPods/Xcodeproj/pull/543)

##### Bug Fixes

* Save `.xcscheme` files with double-quoted strings, consistent with Xcode.  
  [Samuel Giddins](https://github.com/segiddins)

* [XCBuildConfiguration] Support environment variables in #resolve_build_setting  
  [Ruenzuo](https://github.com/Ruenzuo)
  [#510](https://github.com/CocoaPods/Xcodeproj/issues/510)

* Ensure `--no-ansi` disables output of escape sequences.  
  [Samuel Giddins](https://github.com/segiddins)
  [#540](https://github.com/CocoaPods/Xcodeproj/issues/540)


## 1.5.4 (2017-12-16)

##### Enhancements

* Made it possible to configure a scheme to launch a Today extension  
  [Eldorado234](https://github.com/Eldorado234)
  [#520](https://github.com/CocoaPods/CocoaPods/issues/520)

##### Bug Fixes

* Fixing the method recreate_user_scheme for targets other than type PBXNativeTarget.  
  [Yadir Hernandez](https://github.com/yadirhb)
  [#531](https://github.com/CocoaPods/CocoaPods/issues/531)

* Verify container portal when checking dependency target membership.  
  [izaakschroeder](https://github.com/izaakschroeder)
  [#513](https://github.com/CocoaPods/Xcodeproj/issues/513)

* [XCBuildConfiguration] Fix infinite recursion in #resolve_build_setting  
  [Ruenzuo](https://github.com/Ruenzuo)
  [#511](https://github.com/CocoaPods/Xcodeproj/issues/511)

* Add .inl as a recognized header file ending  
  [bes](https://github.com/bes)
  [#7283](https://github.com/CocoaPods/CocoaPods/issues/7283)

## 1.5.3 (2017-10-24)

##### Enhancements

* Allowed to simply save a scheme after it was saved with a path before  
  [Eldorado234](https://github.com/Eldorado234)
  [#519](https://github.com/CocoaPods/CocoaPods/issues/519)

##### Bug Fixes

* [Config] Make #to_bash include import statements  
  [Ruenzuo](https://github.com/Ruenzuo)
  [#505](https://github.com/CocoaPods/Xcodeproj/issues/505)

## 1.5.2 (2017-09-24)

##### Enhancements

* Resolve variable substitution for xcconfig declared build settings
  [Ruenzuo](https://github.com/Ruenzuo)
  [#501](https://github.com/CocoaPods/Xcodeproj/issues/501)

##### Bug Fixes

* Don’t share build settings between resources bundle configurations  
  [jmesmith](https://github.com/jmesmith)
  [#502](https://github.com/CocoaPods/Xcodeproj/pull/502)

## 1.5.1 (2017-07-19)

##### Enhancements

* Update default build settings for Xcode 9.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* Narrows regex for SCM conflict marker detection
  [allenhumphreys](https://github.com/allenhumphreys)
  [#495](https://github.com/CocoaPods/Xcodeproj/pull/495)

## 1.5.0 (2017-06-06)

##### Enhancements

* Add add_legacy_target method to ProjectHelper  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#491](https://github.com/CocoaPods/Xcodeproj/pull/491)

* Provide ability to update schemes as they are being recreated  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#490](https://github.com/CocoaPods/Xcodeproj/pull/490)

* Use `test_target_type?` when adding testable reference  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#487](https://github.com/CocoaPods/Xcodeproj/pull/487)

* Add test reference to xcscheme if target is of type test  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#485](https://github.com/CocoaPods/Xcodeproj/pull/485)

* Make build settings parsing optionally take into account any associated
  xcconfig files and project settings.  
  [Renzo Crisóstomo](https://github.com/ruenzuo)
  [#180](https://github.com/CocoaPods/Xcodeproj/pull/180)

* Add command_line_arguments to TestAction.  
  [Brently Jones](https://github.com/brentleyjones)
  [Danielle Tomlinson](https://github.com/dantoml)
  [#492](https://github.com/CocoaPods/Xcodeproj/pull/492)

##### Bug Fixes

* Do not crash when there are no `BuildActionEntries` in a scheme.  
  [Danielle Tomlinson](https://github.com/dantoml)
  [#486](https://github.com/CocoaPods/Xcodeproj/pull/486)


## 1.4.4 (2017-04-07)

##### Enhancements

* `ui_test_bundle` product are treated as xctest bundles.  
  [Rajinder Ramgarhia](https://github.com/1nput0utput)
  [#467](https://github.com/CocoaPods/Xcodeproj/pull/467)

* Remove the dependency upon `activesupport`.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* None.  


## 1.4.3 (2017-03-31)

##### Enhancements

* Updated Common Build Settings with Xcode 8.3.  
  [Louis D'hauwe](https://github.com/louisdh)
  [#474](https://github.com/CocoaPods/Xcodeproj/pull/474)

* Updated Common Build Settings with Xcode 8.2.1.  
  [Louis D'hauwe](https://github.com/louisdh)
  [#468](https://github.com/CocoaPods/Xcodeproj/pull/468)

* Return file references when adding system frameworks to a target.  
  [Keith Smiley](https://github.com/keith)
  [#466](https://github.com/CocoaPods/Xcodeproj/pull/466)

* Add more Xcode file type references by file extension.  
  [Keith Smiley](https://github.com/keith)
  [#465](https://github.com/CocoaPods/Xcodeproj/pull/465)

##### Bug Fixes

* Reference proxy display name always returns "ReferenceProxy".
  Behavior corrected to return the name or path of the reference.  
  [Barak Weiss](https://github.com/barakwei)
  [#472](https://github.com/CocoaPods/Xcodeproj/issues/472)


## 1.4.2 (2016-12-19)

##### Enhancements

* Better error message when a target_dependency is invalid.  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#448](https://github.com/CocoaPods/Xcodeproj/pull/448)

##### Bug Fixes

* Require 'colored' in xcodeproj.rb  
  [Dimitris Koutsogiorgas](https://github.com/dnkoutso)
  [#374](https://github.com/CocoaPods/Xcodeproj/issues/374)

* Allow initializing an Xcode project without the `classes` attribute.  
  [Samuel Giddins](https://github.com/segiddins)
  [#446](https://github.com/CocoaPods/Xcodeproj/issues/446)


## 1.4.1 (2016-11-02)

##### Enhancements

* Added RemoteRunnable wrapper to achieve Apple Watch compatibility  
  [Eldorado234](https://github.com/Eldorado234)
  [#518](https://github.com/CocoaPods/CocoaPods/issues/518)

##### Bug Fixes

* None.  


## 1.4.0 (2016-10-28)

##### Enhancements

* Use Nanaimo for native ruby ASCII plist parsing and serialization.
  Removes the dependency on Xcode, FFI, and macOS.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* None.  


## 1.3.3 (2016-10-20)

##### Enhancements

* None.  

##### Bug Fixes

* Fix regression resulting in projects existing product ref groups being altered  
  [Rashin Arab](https://github.com/rasharab)
  [#429](https://github.com/CocoaPods/Xcodeproj/pull/429)

* Fixed handling of xcdatamodeld packages in subfolders.  
  [Simon Seyer](https://github.com/Eldorado234)
  [#427](https://github.com/CocoaPods/Xcodeproj/pull/427)


## 1.3.2 (2016-10-10)

##### Enhancements

* None.  

##### Bug Fixes

* Cover more cases of the Dir.chdir breakages.  
  [Danielle Tomlinson](https://github.com/dantoml)
  [#421](https://github.com/CocoaPods/Xcodeproj/pull/421)


## 1.3.1 (2016-09-10)

##### Enhancements

* None.  

##### Bug Fixes

* Bump last known object version to support Xcode 8.0.  
  [Boris Bügling](https://github.com/neonichu)
  [#412](https://github.com/CocoaPods/Xcodeproj/issues/412)
  [#414](https://github.com/CocoaPods/Xcodeproj/pull/414)


## 1.3.0 (2016-09-02)

##### Enhancements

* Add new Messages application product types to constants.  
  [Ben Asher](https://github.com/benasher44)
  [#400](https://github.com/CocoaPods/Xcodeproj/pull/400)

* Add support for identify the host of an embedded target,
  when the embedded target belongs to a sub-project  
  [Ben Asher](https://github.com/benasher44)
  [#396](https://github.com/CocoaPods/Xcodeproj/pull/396)

##### Bug Fixes

* None.  


## 1.2.0 (2016-07-11)

##### Enhancements

* Expand `Project` helpers for finding a target's extension targets
  and their hosts to include all embedded targets  
  [Ben Asher](https://github.com/benasher44)
  [#385](https://github.com/CocoaPods/Xcodeproj/pull/385)

* Add helpers to `Project` for finding an extension target's host targets
  and a host target's extension targets.  
  [Ben Asher](https://github.com/benasher44)
  [#382](https://github.com/CocoaPods/Xcodeproj/pull/382)

* Add accessors for working with skipped tests inside TestAction  in `.xcscheme` files.  
  [Eduard Panasiuk](https://github.com/somedev)
  [#380](https://github.com/CocoaPods/Xcodeproj/pull/380)
  [#383](https://github.com/CocoaPods/Xcodeproj/pull/383)

* Add new Messages extension product types to constants.  
  [Boris Bügling](https://github.com/neonichu)
  [#390](https://github.com/CocoaPods/Xcodeproj/pull/390)

* Fix plist serialization with Xcode 8 beta 1.  
  [Boris Bügling](https://github.com/neonichu)
  [#389](https://github.com/CocoaPods/Xcodeproj/pull/389)


##### Bug Fixes

* None.  


## 1.1.0 (2016-06-01)

##### Enhancements

* Add test target and extension target helpers to `PBXNativeTarget`.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* None.  


## 1.0.0 (2016-05-10)

##### Enhancements

* Support for UI test bundles.  
  [Boris Bügling](https://github.com/neonichu)
  [#372](https://github.com/CocoaPods/Xcodeproj/pull/372)

##### Bug Fixes

* None.  


## 1.0.0.rc.2 (2016-05-04)

##### Enhancements

* Update constants for Xcode 7.3.  
  [Samuel Giddins](https://github.com/segiddins)
  [#370](https://github.com/CocoaPods/Xcodeproj/issues/370)

##### Bug Fixes

* Support initializing a workspace that is missing a
  `contents.xcworkspacedir`.  
  [Roger Hu](https://github.com/rogerhu)
  [CocoaPods#4998](https://github.com/CocoaPods/CocoaPods/issues/4998)


## 1.0.0.rc.1 (2016-04-30)

##### Enhancements

* None.  

##### Bug Fixes

* None.  


## 1.0.0.beta.4 (2016-04-14)

##### Enhancements

* Add support for `outputFilesCompilerFlags` in a custom `PBXBuildRule`.  
  [Samuel Giddins](https://github.com/segiddins)
  [#362](https://github.com/CocoaPods/Xcodeproj/issues/362)

##### Bug Fixes

* Improve the error when attempting to get the absolute path for a workspace
  file reference of `developer` type.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#5107](https://github.com/CocoaPods/CocoaPods/issues/5107)


## 1.0.0.beta.3 (2016-02-24)

##### Bug Fixes

* Fix ASCII .xcodeproj serialization with Xcode 7.3.  
  [Boris Bügling](https://github.com/neonichu)
  [#356](https://github.com/CocoaPods/Xcodeproj/pull/356)

* Ensure that new targets have the right build settings for custom build
  configurations.  
  [Samuel Giddins](https://github.com/segiddins)
  [#354](https://github.com/CocoaPods/Xcodeproj/issues/354)


## 1.0.0.beta.2 (2015-12-30)

##### Bug Fixes

* Depend upon CLAide 1.0.  
  [Samuel Giddins](https://github.com/segiddins)


## 1.0.0.beta.1 (2015-12-30)

##### Enhancements

* Add accessors for working with Environment Variables in `.xcscheme` files.  
  [Justin Martin](https://github.com/justinseanmartin)
  [#326](https://github.com/CocoaPods/Xcodeproj/pull/326)

* Add method to create new variant groups (groups for localized versions of
  the same file).  
  [Tim Bodeit](https://github.com/timbodeit)
  [#315](https://github.com/CocoaPods/Xcodeproj/pull/315)

* Added target type for TV application extensions.  
  [Boris Bügling](https://github.com/neonichu)
  [#318](https://github.com/CocoaPods/Xcodeproj/pull/318)

* Added .hxx to the list of recognized header file extensions.  
  [Jason Vasquez](https://github.com/jasonvasquez)
  [#320](https://github.com/CocoaPods/Xcodeproj/pull/320)

* Added basic `Xcodeproj::Workspace` APIs to support groups.  
  [David Parton](https://github.com/dparton)
  [#322](https://github.com/CocoaPods/Xcodeproj/pull/322)

* Added a helper to set the deployment target on a target based on its
  platform.  
  [Samuel Giddins](https://github.com/segiddins)

* Added support for projects tracking if they have been modified.  
  [Samuel Giddins](https://github.com/segiddins)
  [#202](https://github.com/CocoaPods/Xcodeproj/issues/202)

* The plist serializer can now be switched to different implementations,
  which will get autoloaded on-demand.  
  [Samuel Giddins](https://github.com/segiddins)

* Simply requiring `xcodeproj` on a ruby installation without the `fiddle` gem
  will not cause an exception -- that exception has been delayed until actually
  attempting to serialize / load a plist file.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* Avoid duplicating settings with multiple values in common when merging.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#3652](https://github.com/CocoaPods/CocoaPods/issues/3652)

* Avoid duplicating settings with common prefixes when merging.  
  [Samuel Giddins](https://github.com/segiddins)

* Escape XML entities in project names when writing workspace.  
  [Caesar Wirth](https://github.com/cjwirth)
  [CocoaPods#4446](https://github.com/CocoaPods/CocoaPods/issues/4446)

* Serialized configs will now have a trailing newline appended.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.28.2 (2015-10-09)

##### Bug Fixes

* Silence `dyld` warnings appearing on OS X 10.11.  
  [Boris Bügling](https://github.com/neonichu)
  [#312](https://github.com/CocoaPods/Xcodeproj/pull/312)


## 0.28.1 (2015-10-05)

##### Bug Fixes

* Handle non-string values when serializing an XCConfig.  
  [Samuel Giddins](https://github.com/)
  [CocoaPods#4291](https://github.com/CocoaPods/CocoaPods/issues/4291)


## 0.28.0 (2015-10-01)

##### Enhancements

* Add `tvos` as a new platform.  
  [Boris Bügling](https://github.com/neonichu)
  [Xcodeproj#301](https://github.com/CocoaPods/Xcodeproj/pull/301)

* Allow accessing the new Xcode 7's Clang code coverage setting on XCSchemes
  ("Gather Code Coverage" checkbox).  
  [Olivier Halligon](https://github.com/AliSoftware)
  [#307](https://github.com/CocoaPods/Xcodeproj/pull/307)

* Adds `Xcodeproj::XCScheme#save!` to save in place when
  the `XCScheme` object was initialized from an existing file.  
  [Olivier Halligon](https://github.com/AliSoftware)
  [#308](https://github.com/CocoaPods/Xcodeproj/pull/308)

##### Bug Fixes

* Allow opening and saving projects that have circular target dependencies.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#4229](https://github.com/CocoaPods/CocoaPods/issues/4229)

* Fix the generation of deterministic UUIDs for `.xcdatamodeld` bundles.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#4187](https://github.com/CocoaPods/CocoaPods/issues/4187)


## 0.27.2 (2015-09-02)

##### Enhancements

* Cache some calculations in deterministic UUID generation.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.27.1 (2015-08-28)

##### Bug Fixes

* This release fixes a file permissions error when using the RubyGem.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.27.0 (2015-08-26)

##### Enhancements

* Added the ability to load an existing `.xcscheme` file and manipulate
  it using `Xcodeproj::XCScheme`.  
  [Olivier Halligon](https://github.com/AliSoftware)
  [#288](https://github.com/CocoaPods/Xcodeproj/pull/288)

 * Sorting is now done in a case-insensitive manner.  
  [Emma Koszinowski](http://github.com/emkosz)
  [CocoaPods#3684](https://github.com/CocoaPods/CocoaPods/issues/3684)

* Trailing whitespace is stripped when serializing XCConfig files.  
  [Samuel Giddins](https://github.com/segiddins)

* XCConfig values that are only `$(inherited)` will be omitted during
  serialization.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.26.3 (2015-07-26)

##### Bug Fixes

* Fix a crash when calling `xcodeproj config-dump`.  
  [Samuel Giddins](https://github.com/segiddins)

* Reduces the number of cases un which deterministic UUIDs would yield
  duplicates. Downgraded duplicate generated UUIDs to a warning from an
  exception.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#3823](https://github.com/CocoaPods/CocoaPods/issues/3823)
  [CocoaPods#3850](https://github.com/CocoaPods/CocoaPods/issues/3850)


## 0.26.2 (2015-07-18)

##### Bug Fixes

* Fix a crash when using the `xcodeproj` CLI.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.26.1 (2015-07-05)

##### Enhancements

* Vastly speed up deterministic UUID generation for large projects.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.26.0 (2015-07-02)

##### Enhancements

* Allow transforming a project's UUIDs into predictable replacements.  
  [Samuel Giddins](https://github.com/segiddins)
  [#175](https://github.com/CocoaPods/Xcodeproj/issues/175)


## 0.25.1 (2015-06-27)

##### Bug Fixes

* Allow `xcodeproj show` to accept `--no-color` as an option without crashing.  
  [Samuel Giddins](https://github.com/segiddins)
  [#267](https://github.com/CocoaPods/Xcodeproj/issues/267)

* Actually fix crashing when using Xcode 7 betas 1 & 2.  
  [Samuel Giddins](https://github.com/segiddins)
  [#278](https://github.com/CocoaPods/Xcodeproj/issues/278)


## 0.25.0 (2015-06-27)

##### Enhancements

* Ensure that duplicate resources or source files aren't added to a target.  
  [Samuel Giddins](https://github.com/segiddins)

* Support for native watch app targets.  
  [Boris Bügling](https://github.com/neonichu)
  [Xcodeproj#272](https://github.com/CocoaPods/Xcodeproj/pull/272)

* Update default build and scheme settings for Xcode 7.0 beta 1/2.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Boris Bügling](https://github.com/neonichu)
  [Xcodeproj#271](https://github.com/CocoaPods/Xcodeproj/pull/271)

##### Bug Fixes

* Fix the help output for `xcodeproj config-dump`.  
  [Samuel Giddins](https://github.com/segiddins)
  [#274](https://github.com/CocoaPods/Xcodeproj/issues/274)

* Add support for project serialization with Xcode 7 Beta 2.  
  [Samuel Giddins](https://github.com/segiddins)
  [Boris Bügling](https://github.com/neonichu)
  [#278](https://github.com/CocoaPods/Xcodeproj/issues/278)
  [CocoaPods#3723](https://github.com/CocoaPods/CocoaPods/issues/3723)


## 0.24.3 (2015-06-27)

##### Bug Fixes

* Actually fix crashing when using Xcode 7 betas 1 & 2.  
  [Samuel Giddins](https://github.com/segiddins)
  [#278](https://github.com/CocoaPods/Xcodeproj/issues/278)


## 0.24.2 (2015-05-27)

##### Enhancements

* `Constants`: Adds support for Command Line Tool as a product type.  
  [Nick Jordan](https://github.com/nickkjordan)
  [Xcodeproj#268](https://github.com/CocoaPods/Xcodeproj/pull/264)


## 0.24.1 (2015-04-28)

##### Enhancements

* Support for Xcode 6.3 compatible projects.  
  [Boris Bügling](https://github.com/neonichu)
  [Xcodeproj#253](https://github.com/CocoaPods/Xcodeproj/pull/253)


## 0.24.0 (2015-04-18)

##### Enhancements

* Return a list of project targets including only native targets by
  `native_targets`.  
  [Marc Boquet](https://github.com/apalancat)
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#256](https://github.com/CocoaPods/Xcodeproj/pull/256)

* `ProjectHelper`: Allow to create aggregate targets.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#260](https://github.com/CocoaPods/Xcodeproj/pull/260)

* `ProjectHelper`: Give optional parameter of `configuration_list`
  and `common_build_settings` the default value `nil`.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#260](https://github.com/CocoaPods/Xcodeproj/pull/260)

#### Bug Fixes

* Save xcconfig files also if only the includes where modified by fixing the
  equality method implementation.  
  [Brian Partridge](https://github.com/brianpartridge)
  [Xcodeproj#255](https://github.com/CocoaPods/Xcodeproj/pull/255)

* Use `xcode-select --print-path` to be compatible with OS X 10.8.  
  [Boris Bügling](https://github.com/neonichu)
  [CocoaPods#3387](https://github.com/CocoaPods/CocoaPods/issues/3387)


## 0.23.1 (2015-03-26)

#### Bug Fixes

* Do not apply `fix_encoding` workaround when writing ASCII plists.  
  [Boris Bügling](https://github.com/neonichu)
  [CocoaPods#3298](https://github.com/CocoaPods/CocoaPods/issues/3298)


## 0.23.0 (2015-03-10)

##### Enhancements

* `ProjectHelper`: Allow to specify the primary language of the target.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#244](https://github.com/CocoaPods/Xcodeproj/pull/244)

#### Bug Fixes

* Depend on pathname so components such as PlistHelper can be used directly.  
  [Vincent Isambart](https://github.com/vincentisambart)
  [Kyle Fuller](https://github.com/kylef)
  [#243](https://github.com/CocoaPods/Xcodeproj/issues/243)


## 0.22.0 (2015-02-25)

##### Enhancements

* Use the `DVTFoundation.framework` of Xcode to serialize projects as ASCII
  plists. This makes the optional installation of `xcproj` unnecessary to
  retain the project file format.  
  [Boris Bügling](https://github.com/neonichu)
  [Xcodeproj#199](https://github.com/CocoaPods/Xcodeproj/issues/199)
  [Xcodeproj#203](https://github.com/CocoaPods/Xcodeproj/issues/203)

* `PlistHelper`: Add support for plist files with numbers (`real`, `integer`).  
  [Vincent Isambart](https://github.com/vincentisambart)

#### Bug Fixes

* Use the correct value for `COPY_PHASE_STRIP` when creating build
  configurations.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [#3062](https://github.com/CocoaPods/CocoaPods/issues/3062)

* handle .H header files as headers and remove from the compile
  sources build phase.  
  [banjun](https://github.com/banjun)
  [Xcodeproj#239](https://github.com/CocoaPods/Xcodeproj/pull/239)

## 0.21.2 (2015-01-27)

##### Bug Fixes

* Include common build settings on custom build configurations.  
  [Kyle Fuller](https://github.com/kylef)

## 0.21.1 (2015-01-27)

##### Bug Fixes

* `Project` The `new_target` method now creates build configurations
  corresponding to all configurations of the project, not just Debug
  and Release.  
  [Boris Bügling](https://github.com/neonichu)
  [Xcodeproj#228](https://github.com/CocoaPods/Xcodeproj/issues/228)
  [CocoaPods#3055](https://github.com/CocoaPods/CocoaPods/issues/3055)

* Use `#sub` instead of `#gsub` to remove spaces near first `=` when
  generating scheme files.  
  [Almas Sapargali](http://github.com/almassapargali)
  [Xcodeproj#225](https://github.com/CocoaPods/Xcodeproj/pull/225)


## 0.21.0 (2014-12-25)

##### Breaking

* `Constants` The build settings match now those from Xcode 6.1.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Kyle Fuller](https://github.com/kylef)
  [Xcodeproj#166](https://github.com/CocoaPods/Xcodeproj/pull/166)


##### Enhancements

* `ProjectHelper` The `::common_build_settings` method supports now a new
  parameter `language` to select the language used in the target. Acceptable
  options are either `:objc` or `:swift`.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#166](https://github.com/CocoaPods/Xcodeproj/pull/166)

* `ProjectHelper` Supports to create framework targets for iOS & OSX with the
  correct build settings.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#166](https://github.com/CocoaPods/Xcodeproj/pull/164)

* `Commands` Xcodeproj CLI has a new command `config-dump`, which allows to
  read the build settings from all configurations of all targets of a given
  Xcode project and serialize them to .xcconfig files.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#166](https://github.com/CocoaPods/Xcodeproj/pull/166)


##### Development Enhancements

* `Rakefile` Brings a set of new tasks to interactively generate fixture targets
  for all target configurations supported by Xcode to update the xcconfig
  fixtures used for the new specs, which check the build settings constants.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#166](https://github.com/CocoaPods/Xcodeproj/pull/166)


## 0.20.2 (2014-11-15)

##### Bug Fixes

* `FileReference` Fixes an issue that caused project names containing
  `"`, `'`, `&`, `<` or `>` to produce a workspace that Xcode could not open.  
  [Hugo Tunius](https://github.com/K0nserv)
  [CocoaPods#2807](https://github.com/CocoaPods/CocoaPods/issues/2807)


## 0.20.1 (2014-10-28)

###### Minor Enhancements

* `Project` Make `#==` a fast shallow comparison method, which operates only on
  its root object UUID and its path on disk. For full data comparisons, use the
  `#eql?` method instead.  
  [Eloy Durán](https://github.com/alloy)
  [Xcodeproj#216](https://github.com/CocoaPods/Xcodeproj/pull/216)

* `NativeTarget` Make adding a target dependency O(1) constant speed.  
  [Eloy Durán](https://github.com/alloy)
  [Xcodeproj#216](https://github.com/CocoaPods/Xcodeproj/pull/216)

* `Object` Cache an object's plist name, which is used very often during project
  generation.  
  [Eloy Durán](https://github.com/alloy)
  [Xcodeproj#216](https://github.com/CocoaPods/Xcodeproj/pull/216)

###### Bug Fixes

* `CoreFoundation` Hopefully fix a Ruby constant lookup issue. We have been
  unable to reproduce this, but since more than one person has reported it,
  we're including this fix in the hope it fixes this esoteric issue.  
  [Eloy Durán](https://github.com/alloy)
  [CocoaPods#2632](https://github.com/CocoaPods/CocoaPods/issues/2632)
  [CocoaPods#2739](https://github.com/CocoaPods/CocoaPods/issues/2739)


## 0.20.0 (2014-10-26)

###### Breaking

* Support for Ruby < 2.0.0 has been dropped. Xcodeproj now depends on
  Ruby 2.0.0 or greater.  
  [Kyle Fuller](https://github.com/kylef)


###### Enhancements

* `Project`: Recognize merge conflicts and raise a helpful error.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#192](https://github.com/CocoaPods/Xcodeproj/pull/192)

* `PBXContainerItemProxy`: Allow access to the proxied object.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#178](https://github.com/CocoaPods/Xcodeproj/pull/178)


###### Minor Enhancements

* `PBXCopyFilesBuildPhase`: Add a convenience method `symbol_dst_subfolder_spec`
  to set the destination subfolder specification by a symbol.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#187](https://github.com/CocoaPods/Xcodeproj/pull/187)

* `PBXNativeTarget`: Return newly created build files by `add_file_references`
  and yield each one to allow direct modification of its settigs.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#187](https://github.com/CocoaPods/Xcodeproj/pull/187)


###### Bug Fixes

* `PBXNativeTarget`: Fixed the creation of target dependencies, which refer
  to subprojects.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#178](https://github.com/CocoaPods/Xcodeproj/pull/178)

* `PBXReferenceProxy`: Added the missing attribute name, which could appear when
  external frameworks are referenced.
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#189](https://github.com/CocoaPods/Xcodeproj/pull/189)


## 0.19.4 (2014-10-15)

###### Bug Fixes

* `PlistHelper`: Add support for Ruby 1.9.3's implementation of `Fiddle`.  
  [Eloy Durán](https://github.com/alloy)
  [Xcodeproj#206](https://github.com/CocoaPods/Xcodeproj/issues/206)

* Stop re-writing config files if they have not changed.  
  [Kyle Fuller](https://github.com/kylef)
  [Boris Bügling](https://github.com/neonichu)


## 0.19.3 (2014-10-07)

###### Bug Fixes

* `PlistHelper`: Drop usage of the `CFPropertyList` gem and `plutil` and replace
  it with a version that uses the native `CFPropertyList` APIs from the OS X
  `CoreFoundation` framework, like the previous C extension did. Except this
  time we use Ruby's Fiddle API (MRI >= 1.9.3) to interface with it instead of
  the need to compile a C extension.  
  This release still includes a prebuilt version of the C extension for Ruby
  1.8.7 support (OS X 10.8.x), but this will soon be dropped completely.  
  [Eloy Durán](https://github.com/alloy)
  [CocoaPods#2483](https://github.com/CocoaPods/CocoaPods/issues/2483)
  [Xcodeproj#198](https://github.com/CocoaPods/Xcodeproj/issues/198)
  [Xcodeproj#200](https://github.com/CocoaPods/Xcodeproj/pull/200)


## 0.19.2 (2014-09-25)

###### Bug Fixes

* `PlistHelper`: Only try to use `plutil` if it's in the exact location where
  we expect it to be on OS X, instead of relying on the user's `$PATH`.
  [Eloy Durán](https://github.com/alloy)
  [CocoaPods#2502](https://github.com/CocoaPods/CocoaPods/issues/2502)


## 0.19.1 (2014-09-12)

###### Bug Fixes

* `Config`: Remove space after -l flag in other linker flags.  
  [Fabio Pelosin](https://github.com/fabiopelosin)


## 0.19.0 (2014-09-11)

* `PlistHelper`: Now the `plutil` tool is used to save the files if available
  to produce output consistent with Xcode.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* `Project`: Added support for adding file references to sub-projects.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* `Config`: The config class now properly handles quotes in `OTHER_LDFLAGS`.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* `PBXGroup`: Now file references to Xcode projects are properly handled and
  setup. Also the `ObjectDictionary` class has been improved and now can be
  used to edit the attributes using it.
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [Xcodeproj#172](https://github.com/CocoaPods/Xcodeproj/pull/172)

* `Constants`: Support XCTest as product type and don't fail for
  `PBXNativeTarget#symbol_type` on unknown product types.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [Xcodeproj#176](https://github.com/CocoaPods/Xcodeproj/pull/176)

* `Workspace`: Now a template is used to produce the same formatting of Xcode.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* `Project`: Improved validation of object attributes.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* `Project`: Completed support for dictionaries.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* `Project`: Added possibility to disable `xcproj` via an environment variable.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

###### Bug Fixes

* `Project`: Fixed reference counting issue when deleting sub-projects.


## 0.18.0 (2014-07-24)

###### Enhancements

* [PlistHelper] The native extension has been removed in favour of the usage of
  the `plutil` tool to read ASCII property list files.  
  [Fabio Pelosin](https://github.com/fabiopelosin)
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


## 0.17.0 (2014-05-19)

###### Enhancements

* [Workspace] Added support for file references.  
  [Kyle Fuller](https://github.com/kylef)
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [Xcodeproj#105](https://github.com/CocoaPods/Xcodeproj/pull/150)


## 0.16.1 (2014-04-15)

###### Minor Enhancements

* [Constants] Added support for .ipp files as headers.  
  [Samuel E. Giddins](https://github.com/segiddins)

###### Bug Fixes

* [Xcodeproj::Project#reference_for_path] Support for string parameter.  
  [jlj](https://github.com/jlj)


## 0.16.0 (2014-03-31)

###### Breaking

* [Constants] Disable errors on warnings for default build settings  
  [Fabio Pelosin](https://github.com/fabiopelosin)


## 0.15.3 (2014-03-29)

###### Bug Fixes

* [Extension] Fixed build on OS X 10.9's system Ruby (2.0.0).
  [Eloy Durán](https://github.com/alloy)


## 0.15.1 (2014-03-29)

###### Bug Fixes

* [Constants] Temporarily reverting the changes to `OTHER_LDFLAGS` as the were
  creating issues in CocoaPods.  
  [Fabio Pelosin](https://github.com/fabiopelosin)


## 0.15.0 (2014-03-27)

###### Breaking

* [Project] Now the provided path is always expanded on initialization.  
  [Gordon Fontenot](https://github.com/gfontenot)
  [#121](https://github.com/CocoaPods/Xcodeproj/pull/121)

###### Enhancements

* [Constants] Bumped last know SDK versions.  
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [#141](https://github.com/CocoaPods/Xcodeproj/pull/141)

* [Constants] Removed empty `OTHER_LDFLAGS` setting to match Xcode's behaviour.  
  [Gordon Fontenot](https://github.com/gfontenot)

* [Constants] Bumped last known Xcode version to `5.1`.  
  [Romans Karpelcevs](https://github.com/coverback)
  [#138](https://github.com/CocoaPods/Xcodeproj/pull/138)

###### Bug Fixes

* [Extension] Fixed intermittent `Xcodeproj::PlistHelper.write_plist` error.  
  [Eloy Durán](https://github.com/alloy)


## 0.14.1 (2013-11-01)

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


## 0.14.0 (2013-10-24)

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


## 0.13.1 (2013-10-10)

###### Bug Fixes

* Fix `Unable to read data from Model.xcdatamodeld/.xccurrentversion` when
  there are more Data model versions.  
  [Pim Snel](https://github.com/mipmip)

###### Enhancements

* [AbstractTarget] Added default value for `default_configuration_name`
  attribute.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [XCConfigurationList] `common_resolved_build_setting` will now ignore nil
  values. This is an heuristic which might not closely match Xcode behaviour.
  This is done because some information, like the SDK, is usually considered at
  the target level but it might actually differ in the build configurations.
  For example nothing prevents a target to build with the iOS sdk in one
  configuration and with the OS X in another.  
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [CocoaPods/CocoaPods#1462](https://github.com/CocoaPods/CocoaPods/issues/1462)


## 0.13.0 (2013-10-09)

###### Breaking

* [AbstractTarget] The `#sdk` method now raises if the value is not the same
  across all the build configurations. This has been done to prevent clients
  from accidentally using arbitrary values.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

###### Enhancements

* [AbstractTarget] Added `#resolved_build_setting` and
  `#common_resolved_build_setting`.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [XCConfigurationList] Added `#get_setting` and `#set_setting`.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [Project] Added `#build_configuration_list`.  
  [Fabio Pelosin](https://github.com/fabiopelosin)


## 0.12.0 (2013-10-08)

###### Breaking

* [PBXGroup] `#new_static_library` has been replaced by the more versatile
  `#new_product_ref_for_target`.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [XCScheme] Overhauled interface to support multiple targets.  
  [Jason Prado](https://github.com/jasonprado)
  [#95](https://github.com/CocoaPods/Xcodeproj/pull/95)

* [PBXGroup] renamed `#recursively_sort_by_type` to
  `#sort_recursively_by_type`.
  [Fabio Pelosin](https://github.com/fabiopelosin)

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
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [Project] The project can now recreate it schemes from scratch and optionally
  hide them.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* Added support for booleans in the C extension which handles Property list
  files.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* Improvements to the generation of new targets.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [Project] Added possibility to specify the position of groups while sorting.
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [PBXGroup] Now defaults to sorting by name.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [XCScheme] The string representation of schemes now closely matches Xcode
  behaviour.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [PBXGroup, PBXFileReference] Added `#parents`.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [PBXGroup] Added `#recursive_children_groups`.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* [AbstractTarget] Add #sdk_version.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

* Added default build settings to new projects according to Xcode defaults.  
  [Fabio Pelosin](https://github.com/fabiopelosin)


## 0.11.1 (2013-09-21)

###### Bug Fixes

* No longer allow `PBXTargetDependency` to sort recursively. When two targets
  depend on each other, this would lead to the two targets endlessly sorting
  each other and finally crashing with a stack overflow.  
  [Eloy Durán](https://github.com/alloy)
  [CocoaPods#1384](https://github.com/CocoaPods/CocoaPods/issues/1384)


## 0.11.0 (2013-09-20)

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


## 0.10.1 (2013-09-04)

###### Enhancements

* Build configurations are now deeply copied.
  [CocoaPods/CocoaPods#1288](https://github.com/CocoaPods/CocoaPods/issues/1322),


## 0.10.0 (2013-09-04)

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


## 0.9.0 (2013-08-02)

###### Enhancements

* Frameworks are added using the last sdks version reported by the xcodebuild if
  the target links against the last SDK.

* Improvements in the handling of file references to frameworks.

* Improvements to the schemes logic.

* Added support for resources bundle targets.

* Project::Group#new_file will now create XCVersionGroup for xcdatamodeld file.

###### Bug Fixes

* The file type of the frameworks file references has be corrected.
