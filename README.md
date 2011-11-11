# xcodeproj

xcodeproj is an Xcode project, workspace, and configuration helper.


## Installing xcodeproj

You’ll need MacRuby. xcodeproj itself installs through RubyGems, the Ruby
package manager. Download and install [version 0.10][macruby] and then perform
the following command:

    $ sudo macgem install xcodeproj

The load time can be improved a bit by compiling the Ruby source files:

    $ sudo macgem install rubygems-compile
    $ sudo macgem compile xcodeproj


## Contributing

* File [tickets][tickets] for anything you need!

* It'd be nice to support plain Ruby as well as MacRuby. (MacRuby is currently 
  only used for property list (de)serialization and UUID generation.)


## Contact

* #cocoapods on `irc.freenode.net` (xcodeproj is borne of CocoaPods.)

Eloy Durán:

* http://github.com/alloy
* http://twitter.com/alloy
* eloy.de.enige@gmail.com


## LICENSE

These works are available under the MIT license. See the [LICENSE][license] file
for more info.


[macruby]: http://www.macruby.org/files
[xcodeproj]: https://github.com/alloy/xcodeproj
[tickets]: https://github.com/alloy/xcodeproj/issues
[license]: xcodeproj/blob/master/LICENSE
