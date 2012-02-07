require 'mkmf'
$LDFLAGS << ' -framework CoreFoundation'
create_makefile 'xcodeproj_ext'
