# Xcodeproj

Xcodeproj lets you create and modify Xcode projects from [MacRuby][macruby].
Script boring management tasks or build Xcode-friendly libraries. Also includes
support for Xcode workspaces (.xcworkspace) and configuration files (.xcconfig).

It is used in [CocoaPods](https://github.com/cocoapods/cocoapods) to create a
static library from scratch, for both iOS and OSX.


## Installing Xcodeproj

You’ll need MacRuby. xcodeproj itself installs through RubyGems, the Ruby
package manager. Download and install [version 0.10][macruby-dl] and then
perform the following command:

    $ sudo macgem install xcodeproj

The load time can be improved a bit by compiling the Ruby source files:

    $ sudo macgem install rubygems-compile
    $ sudo macgem compile xcodeproj


## Colaborate

All Xcodeproj development happens on [GitHub][xcodeproj]. Contributing patches
is really easy and gratifying. You even get push access when one of your patches
is accepted.

Follow [@CocoaPodsOrg][twitter] to get up to date information about what's
going on in the CocoaPods world.

If you're really oldschool and you want to discuss Xcodeproj development you
can join #cocoapods on irc.freenode.net.


## Contributors

* [Nolan Waite](https://github.com/nolanw)


## LICENSE

These works are available under the MIT license. See the [LICENSE][license] file
for more info.

Included in this package is the [inflector part of ActiveSupport][activesupport]
which is also available under the MIT license.

[twitter]: http://twitter.com/CocoaPodsOrg
[macruby]: http://www.macruby.org
[macruby-dl]: http://www.macruby.org/files
[xcodeproj]: https://github.com/cocoapods/xcodeproj
[tickets]: https://github.com/cocoapods/xcodeproj/issues
[license]: xcodeproj/blob/master/LICENSE
[activesupport]: https://github.com/rails/rails/tree/2-3-stable/activesupport
