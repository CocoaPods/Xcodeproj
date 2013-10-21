use_prebuilt = case ENV['XCODEPROJ_BUILD']
               when '1'
                 false
               when '0'
                 true
               else
                 require 'rbconfig'
                 if Config::CONFIG['prefix'] =~ %r{^/System/Library/Frameworks/Ruby.framework/}
                   prebuilt_dir = File.expand_path('../prebuilt', __FILE__)
                   prebuilt_ext = File.join(prebuilt_dir, "#{RUBY_PLATFORM}-#{RUBY_VERSION}", 'xcodeproj_ext.bundle')
                   File.exist?(prebuilt_ext)
                 else
                   false
                 end
               end

if use_prebuilt
  # TODO It might be important that we communicate this, but there is no other way than this hack.
  #      Can't change the spec anymore to have a post install message nor can we output to stdout/stderr,
  #      because RubyGems catches all output and only shows it in case of a build failure.
  #
  #      Do we want this?
  #
  if File.writable?('/dev/tty')
    File.open('/dev/tty', 'w') do |out|
      out.puts "[!] You are using the prebuilt binary version of the xcodeproj gem."
    end
  end
  # TODO Check if a clean OS X install (or only Xcode.app installed) includes `make`.
  # Create a dummy Makefile.
  File.open(File.expand_path('../Makefile', __FILE__), 'w') do |file|
    file.puts "all:"
    file.puts "\ttrue"
    file.puts
    file.puts "install:"
    file.puts "\ttrue"
  end
  $makefile_created = true
else
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

  # From `man ld`:
  #
  #     -Z          Do not search the standard directories when searching for libraries and frameworks.
  #
  # This is typically used when you want compilation against Xcode SDK as opposed to the frameworks installed
  # in the running system, which is our use case.
  $LDFLAGS.gsub!(/\s-Z\s/,' ')

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
end
