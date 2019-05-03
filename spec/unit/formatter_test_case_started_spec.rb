# frozen_string_literal: true

require_relative "../spec_helper"

describe Allure::CucumberFormatter do
  let(:result_utils) { Allure::ResultUtils }

  let(:lifecycle) { double("lifecycle") }
  let(:feature) { "Simple feature" }
  let(:scenario) { "Add a to b" }

  before do
    allow(Allure).to receive(:lifecycle).and_return(lifecycle)
    allow(lifecycle).to receive(:start_test_step)
    allow(lifecycle).to receive(:update_test_step)
    allow(lifecycle).to receive(:stop_test_step)
    allow(lifecycle).to receive(:update_test_case)
    allow(lifecycle).to receive(:stop_test_case)
    allow(lifecycle).to receive(:stop_test_container)
  end

  it "starts test container with correct arguments" do
    allow(lifecycle).to receive(:start_test_case)

    expect(lifecycle).to receive(:start_test_container) do |arg|
      expect(arg.name).to eq(scenario)
    end
    run_cucumber_cli("features/features/simple.feature")
  end

  it "starts test case with correct arguments" do
    allow(lifecycle).to receive(:start_test_container)

    expect(lifecycle).to receive(:start_test_case) do |arg|
      aggregate_failures "Should have correct args" do
        expect(arg.name).to eq(scenario)
        expect(arg.description).to eq("Simple scenario description")
        expect(arg.full_name).to eq("#{feature}: #{scenario}")
        expect(arg.links).to be_empty
        expect(arg.parameters).to be_empty
        expect(arg.history_id).to eq(
          Digest::MD5.hexdigest("#<Cucumber::Core::Test::Case: features/features/simple.feature:3>"),
        )
        expect(arg.labels).to include(
          result_utils.feature_label(feature),
          result_utils.story_label(scenario),
        )
      end
    end
    run_cucumber_cli("features/features/simple.feature")
  end

  it "parses tags correctly" do
    allow(lifecycle).to receive(:start_test_container)

    expect(lifecycle).to receive(:start_test_case) do |arg|
      aggregate_failures "Should have correct args" do
        expect(arg.links).to contain_exactly(
          result_utils.tms_link("OAT-4444"),
          result_utils.issue_link("BUG-22400"),
        )
        expect(arg.labels).to include(
          result_utils.tag_label("FeatureTag"),
          result_utils.tag_label("flaky"),
          result_utils.tag_label("good"),
          result_utils.severity_label("blocker"),
        )
      end
    end
    run_cucumber_cli("features/features/tags.feature")
  end

  it "handles scenario outlines" do
    allow(lifecycle).to receive(:start_test_container)

    expect(lifecycle).to receive(:start_test_case).once do |arg|
      expect(arg.name).to include("Add a to b, Examples (#1)")
      expect(arg.parameters).to contain_exactly(
        Allure::Parameter.new("argument", "5"),
        Allure::Parameter.new("argument", "10"),
        Allure::Parameter.new("argument", "15"),
      )
    end.ordered
    expect(lifecycle).to receive(:start_test_case).once do |arg|
      expect(arg.name).to include("Add a to b, Examples (#2)")
      expect(arg.parameters).to contain_exactly(
        Allure::Parameter.new("argument", "6"),
        Allure::Parameter.new("argument", "7"),
        Allure::Parameter.new("argument", "13"),
      )
    end.ordered
    run_cucumber_cli("features/features/outline.feature")
  end
end
