class Wxmaxima < Formula
  desc "Cross platform GUI for Maxima"
  homepage "https://wxmaxima-developers.github.io/wxmaxima/"
  url "https://github.com/wxMaxima-developers/wxmaxima/archive/Version-19.07.0.tar.gz"
  sha256 "16237f22cf76ecb9159e536bbb121e89ac5ad043843a5f32aaac74f0b409c658"
  head "https://github.com/wxMaxima-developers/wxmaxima.git"

  bottle do
    cellar :any
    sha256 "175947405f4517d9f95ba58de56b3288b0040be440f85696c71fa29f7bee37bd" => :mojave
    sha256 "eeef1f6c1d67f75c8ad98b9443dc5b343c480bca0a1734a91b14e1aa613f26e2" => :high_sierra
    sha256 "2f1984b37e3b3c99e1b018014837b292bd3126176fda57cdf84df6ac38ca9afc" => :sierra
    sha256 "084c21a8461cba29c0fd9ffa48a1e27f746e0214b173ee2eb89dd924b85cd2ab" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "gettext" => :build
  depends_on "wxmac"

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j16" if ENV["CIRCLECI"]

    system "cmake", ".", *std_cmake_args
    system "make", "install"
    prefix.install "wxMaxima.app" if OS.mac?
  end

  def caveats; <<~EOS
    When you start wxMaxima the first time, set the path to Maxima
    (e.g. #{HOMEBREW_PREFIX}/bin/maxima) in the Preferences.

    Enable gnuplot functionality by setting the following variables
    in ~/.maxima/maxima-init.mac:
      gnuplot_command:"#{HOMEBREW_PREFIX}/bin/gnuplot"$
      draw_command:"#{HOMEBREW_PREFIX}/bin/gnuplot"$
  EOS
  end

  test do
    # Test is disbaled on Linux as circle has no X (Error: Unable to initialize GTK+, is DISPLAY set properly)
    assert_match "algebra", shell_output("#{bin}/wxmaxima --help 2>&1", 255) if OS.mac?
  end
end
