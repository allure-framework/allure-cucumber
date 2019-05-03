# frozen_string_literal: true

require_relative "../spec_helper"

describe Allure::CucumberFormatter do
  let(:lifecycle) { double("lifecycle") }

  before do
    allow(Allure).to receive(:lifecycle).and_return(lifecycle)
    allow(lifecycle).to receive(:start_test_container)
    allow(lifecycle).to receive(:start_test_case)
    allow(lifecycle).to receive(:start_test_step)
    allow(lifecycle).to receive(:update_test_step)
    allow(lifecycle).to receive(:stop_test_step)
    allow(lifecycle).to receive(:update_test_case)
  end

  it "stops test container and test case" do
    expect(lifecycle).to receive(:stop_test_case).once
    expect(lifecycle).to receive(:stop_test_container).once

    run_cucumber_cli("features/features/simple.feature")
  end

  it "correctly updates passed test case" do
    test_case = double("test_case")
    allow(lifecycle).to receive(:stop_test_case)
    allow(lifecycle).to receive(:stop_test_container)

    expect(lifecycle).to receive(:update_test_case).and_yield(test_case)
    expect(test_case).to receive(:stage=).with(Allure::Stage::FINISHED)
    expect(test_case).to receive(:status=).with(Allure::Status::PASSED)
    expect(test_case).to receive(:status_details=).with(Allure::StatusDetails.new)
    run_cucumber_cli("features/features/simple.feature")
  end

  it "correctly updates failed test case" do
    test_case = double("test_case")
    allow(lifecycle).to receive(:stop_test_case)
    allow(lifecycle).to receive(:stop_test_container)

    expect(lifecycle).to receive(:update_test_case).and_yield(test_case)
    expect(test_case).to receive(:stage=).with(Allure::Stage::FINISHED)
    expect(test_case).to receive(:status=).with(Allure::Status::FAILED)
    expect(test_case).to receive(:status_details=) do |status_detail|
      expect(status_detail.message).to eq("Simple error!")
      expect(status_detail.trace).not_to be_empty
    end
    run_cucumber_cli("features/features/exception.feature")
  end
end
