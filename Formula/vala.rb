class Vala < Formula
  desc "Compiler for the GObject type system"
  homepage "https://wiki.gnome.org/Projects/Vala"
  url "https://download.gnome.org/sources/vala/0.44/vala-0.44.6.tar.xz"
  sha256 "ab9f1756af7460aa1e39c9a7388f5492a4252a3cd9c76b02f2033f1dedcd793a"

  bottle do
    sha256 "940244c9ae563b3f8b4a174015e8ff409a3b4477e75e4bb508172cee060b191a" => :mojave
    sha256 "06a208ad543ef738498697e223e80fe11ab44378cbec2258fc03b92ffe9df7a6" => :high_sierra
    sha256 "afb0cf11ac54de45825fda47f9f9a1bdf64eb903b700fb280262c45e39ee3f07" => :sierra
    sha256 "a4dbff09c5c7b6a6583beb94b6fca34b90283f014a702316c429f86dd61376e6" => :x86_64_linux
  end

  depends_on "gettext"
  depends_on "glib"
  depends_on "graphviz"
  depends_on "pkg-config"
  unless OS.mac?
    depends_on "bison" => :build
    depends_on "flex" => :build
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make" # Fails to compile as a single step
    system "make", "install"
  end

  test do
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libffi"].opt_lib/"pkgconfig"
    test_string = "Hello Homebrew\n"
    path = testpath/"hello.vala"
    path.write <<~EOS
      void main () {
        print ("#{test_string}");
      }
    EOS
    valac_args = [
      # Build with debugging symbols.
      "-g",
      # Use Homebrew's default C compiler.
      "--cc=#{ENV.cc}",
      # Save generated C source code.
      "--save-temps",
      # Vala source code path.
      path.to_s,
    ]
    system "#{bin}/valac", *valac_args
    assert_predicate testpath/"hello.c", :exist?

    assert_equal test_string, shell_output("#{testpath}/hello")
  end
end
