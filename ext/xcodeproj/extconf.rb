require 'mkmf'

# backport from 1.9.x
unless defined?(have_framework) == "method"
  def have_framework(fw, &b)
    checking_for fw do
      src = cpp_include("#{fw}/#{fw}.h") << "\n" "int main(void){return 0;}"
      if try_link(src, opt = "-ObjC -framework #{fw}", &b)
        $defs.push(format("-DHAVE_FRAMEWORK_%s", fw.tr_cpp))
        $LDFLAGS << " " << opt
        true
      else
        false
      end
    end
  end
end

# Ensure that we can actually set the -std flag
$CFLAGS = $CFLAGS.sub('$(cflags) ', '')
$CFLAGS += ' ' + ENV['CFLAGS'] if ENV['CFLAGS']

checking_for "-std=c99 option to compiler" do
  $CFLAGS += " -std=c99" if try_compile '', '-std=c99'
end

unless have_framework('CoreFoundation')
  if have_library('CoreFoundation')
    # this is needed for opencflite, assume it's on linux
    $defs << '-DTARGET_OS_LINUX'
  else
    $stderr.puts "CoreFoundation is needed to build the Xcodeproj C extension."
    exit -1
  end
end

have_header 'CoreFoundation/CoreFoundation.h'
have_header 'CoreFoundation/CFStream.h'
have_header 'CoreFoundation/CFPropertyList.h'
have_header 'ruby/st.h' or have_header 'st.h' or abort 'xcodeproj currently requires the (ruby/)st.h header'

create_header
create_makefile 'xcodeproj_ext'
