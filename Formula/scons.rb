class Scons < Formula
  desc "Substitute for classic 'make' tool with autoconf/automake functionality"
  homepage "https://www.scons.org/"
  url "https://downloads.sourceforge.net/project/scons/scons/3.1.0/scons-3.1.0.tar.gz"
  sha256 "f3f548d738d4a2179123ecd744271ec413b2d55735ea7625a59b1b59e6cd132f"

  bottle do
    cellar :any_skip_relocation
    sha256 "2b6741458af137560627793b078afdfff7ea18c0ebe95109f040e8e352017464" => :mojave
    sha256 "2b6741458af137560627793b078afdfff7ea18c0ebe95109f040e8e352017464" => :high_sierra
    sha256 "93360d50ab43b502816d1f6c7c930bc52eed3cbb62f58891150441a50606cfa9" => :sierra
    sha256 "8a3b0c585c5c8d6faf4514452353125cec4f793631c52f8d73423a04de41711b" => :x86_64_linux
  end

  uses_from_macos "python@2"

  def install
    unless OS.mac?
      inreplace "engine/SCons/Platform/posix.py",
        "env['ENV']['PATH']    = '/usr/local/bin:/opt/bin:/bin:/usr/bin'",
        "env['ENV']['PATH']    = '#{HOMEBREW_PREFIX}/bin:/usr/local/bin:/opt/bin:/bin:/usr/bin'"
    end

    man1.install gzip("scons-time.1", "scons.1", "sconsign.1")
    system (OS.mac? ? "/usr/bin/python" : "python"), "setup.py", "install",
             "--prefix=#{prefix}",
             "--standalone-lib",
             # SCons gets handsy with sys.path---`scons-local` is one place it
             # will look when all is said and done.
             "--install-lib=#{libexec}/scons-local",
             "--install-scripts=#{bin}",
             "--install-data=#{libexec}",
             "--no-version-script", "--no-install-man"

    # Re-root scripts to libexec so they can import SCons and symlink back into
    # bin. Similar tactics are used in the duplicity formula.
    bin.children.each do |p|
      mv p, "#{libexec}/#{p.basename}.py"
      bin.install_symlink "#{libexec}/#{p.basename}.py" => p.basename
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      int main()
      {
        printf("Homebrew");
        return 0;
      }
    EOS
    (testpath/"SConstruct").write "Program('test.c')"
    system bin/"scons"
    assert_equal "Homebrew", shell_output("#{testpath}/test")
  end
end
