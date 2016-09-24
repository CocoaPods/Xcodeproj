# Since Xcode 8 beta 4, calling `PBXProject.projectWithFile` breaks subsequent calls to
# `chdir`. While sounding ridiculous, this is unfortunately true and debugging it from the
# userland side showed no difference at all to successful calls to `chdir`, but the working
# directory is simply not changed in the end. This workaround is even more absurd, monkey
# patching all calls to `chdir` to use `__pthread_chdir` which appears to work.
class Dir
  def self.cp_chdir(path)
    old_dir = Dir.getwd
    res = actually_chdir(path)

    if block_given?
      begin
        return yield
      ensure
        actually_chdir(old_dir)
      end
    end

    res
  end

  def self.cp_actually_chdir(path)
    libc = Fiddle.dlopen '/usr/lib/libc.dylib'
    f = Fiddle::Function.new(libc['__pthread_chdir'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
    f.call(path.to_s)
  end
end
