# frozen_string_literal: true

require "formula"
require "language/node"
require "fileutils"

class ShopifyCli < Formula
  desc "A CLI tool to build for the Shopify platform"
  homepage "https://github.com/shopify/cli#readme"
  url "https://registry.npmjs.org/@shopify/cli/-/cli-3.47.5.tgz"
  sha256 "069dabfeb34257e58bc727ed3c29f078db20701cb15943223680627a62ac7762"
  license "MIT"
  depends_on "node"
  depends_on "ruby"
  depends_on "git"

  resource "cli-theme-commands" do
    url "https://registry.npmjs.org/@shopify/theme/-/theme-3.47.5.tgz"
    sha256 "95f9df34977745d4809bc473b5825b46f3035fcbc79730e22bd3c97ced939a11"
  end

  livecheck do
    url :stable
  end

  def install
    existing_cli_path = `which shopify`
    unless existing_cli_path.empty? || existing_cli_path.include?("homebrew")
      opoo <<~WARNING
      We've detected an installation of the Shopify CLI at #{existing_cli_path} that's not managed by Homebrew.

      Please ensure that the Homebrew line in your shell configuration is at the bottom so that Homebrew-managed
      tools take precedence.
      WARNING
    end

    system "npm", "install", *Language::Node.std_npm_install_args(libexec)

    original_executable_path = "#{libexec}/bin/shopify"
    executable_path = "#{original_executable_path}"
    new_original_executable_path = "#{executable_path}-original"
    FileUtils.move(original_executable_path, new_original_executable_path)
    executable_content = <<~SCRIPT
      #!/usr/bin/env #{Formula["node"].opt_bin}/node

      process.env.SHOPIFY_RUBY_BINDIR = "#{Formula["ruby"].opt_bin}"
      process.env.SHOPIFY_HOMEBREW_FORMULA = "shopify-cli"

      import("#{new_original_executable_path}")
    SCRIPT
    File.write executable_path, executable_content
    FileUtils.chmod("+x", executable_path)

    bin.install_symlink executable_path

    resource("cli-theme-commands").stage {
      system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    }
  end

  def post_install
    message = <<~POSTINSTALL_MESSAGE
      Congratulations, you've successfully installed Shopify CLI 3!

      Global installations of Shopify CLI 3 should only be used to work on Shopify
      themes. To learn about the changes to theme workflows in this version, refer
      to https://shopify.dev/themes/tools/cli/migrate#workflow-changes

      If you want to keep using Shopify CLI 2, then you can install it again using
      `brew install shopify-cli@2` and run commands using the `shopify2` program
      name (for example, `shopify2 theme push` and `shopify2 extension push`).
      Note however that Shopify CLI 2 will be sunset on May 31, 2023.
    POSTINSTALL_MESSAGE
    message.each_line { |line| ohai line.chomp }
  end
end
