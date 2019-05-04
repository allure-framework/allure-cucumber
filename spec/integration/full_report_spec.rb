# frozen_string_literal: true

require_relative "../spec_helper"

describe "allure-cucumber" do
  include_context "cucumber runner"

  let(:allure_cli) { Allure::Util.allure_cli }

  before(:all) do
    FileUtils.remove_dir(Allure::CucumberConfig.output_dir) if File.exist?(Allure::CucumberConfig.output_dir)
  end

  it "Allure commandline generates report", integration: true do
    run_cucumber_cli("features/features")

    expect(`#{allure_cli} generate -c #{Allure::CucumberConfig.output_dir} -o reports/allure-report`.chomp).to(
      eq("Report successfully generated to reports/allure-report"),
    )
  end
end
