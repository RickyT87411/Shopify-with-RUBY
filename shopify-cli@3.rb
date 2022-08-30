# frozen_string_literal: true

require "formula"
require "language/node"

class ShopifyCliAT3 < Formula
  desc "A CLI tool to build for the Shopify platform"
  homepage "https://github.com/shopify/cli#readme"
  url "https://registry.npmjs.org/@shopify/cli/-/cli-3.9.0.tgz"
  sha256 "8e0993fbac81eea63774bcb4a11518dce424548257acc5015674934f2f07a617"
  license "MIT"
  depends_on "node"
  depends_on "ruby"
  depends_on "git"

  resource "cli-theme-commands" do
    url "https://registry.npmjs.org/@shopify/theme/-/theme-3.9.0.tgz"
    sha256 "51c8b26ee5a2ef131fced3593ee891536346dbd51bd5c42e75e588a08c1d60e9"
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

    executable_path = "#{libexec}/bin/shopify"
    executable_3_path = "#{libexec}/bin/shopify3"
    File.symlink executable_path, executable_3_path

    bin.install_symlink executable_3_path

    resource("cli-theme-commands").stage {
      system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    }
  end
end
