class Ejson < Formula
  desc 'EJSON is a small library to manage encrypted secrets using asymmetric encryption.'
  homepage 'https://github.com/Shopify/ejson'
  url 'https://github.com/Shopify/ejson/archive/v1.2.0.tar.gz'

  bottle do
    root_url "https://s3.amazonaws.com/burkelibbey"
    cellar :any_skip_relocation
    sha256 "b7add2e890b2dac8580cdd43de77fa7f979758f66d7ecb470ab1e9e73065c04c" => :high_sierra
  end

  depends_on 'go' => :build

  def install
    ENV['GEM_HOME'] = buildpath/'.gem'
    ENV['PATH'] = "#{ENV['GEM_HOME']}/bin:#{ENV['PATH']}"
    system('gem', 'install', 'bundler')
    system('bundle', 'install')
    ENV['GOPATH'] = buildpath/'.gopath'
    system('mkdir', '-p', buildpath/'.gopath/src/github.com/Shopify')
    system('ln', '-sf', buildpath, buildpath/'.gopath/src/github.com/Shopify/ejson')
    system('go', 'build', '-o', 'ejson', 'github.com/Shopify/ejson/cmd/ejson')
    system('make', 'man')

    bin.install 'ejson'
    man1.install Dir[buildpath/'build/man/man1/*']
    man5.install Dir[buildpath/'build/man/man5/*']
  end
end
