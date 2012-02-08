require 'mkmf'

$LDFLAGS << ' -framework CoreFoundation'

$CFLAGS = $CFLAGS.sub('$(cflags) ', '')
$CFLAGS += ' ' + ENV['CFLAGS'] if ENV['CFLAGS']

checking_for "-std=c99 option to compiler" do
  $CFLAGS += " -std=c99" if try_compile '', '-std=c99'
end

have_header 'CoreFoundation/CoreFoundation.h'

create_makefile 'xcodeproj_ext'
