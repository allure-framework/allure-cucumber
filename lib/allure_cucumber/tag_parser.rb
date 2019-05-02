# frozen_string_literal: true

require_relative "config"

module Allure
  module TagParser
    def tag_labels(tags)
      tags
        .reject { |tag| reserved?(tag.name) }
        .map { |tag| ResultUtils.tag_label(tag.name.delete_prefix("@")) }
    end

    def tms_links(tags)
      return [] unless CucumberConfig.tms_link_pattern

      tags
        .select { |tag| tag.name.match?(tms_pattern) }
        .map { |tag| tag.name.match(tms_pattern) { |match| ResultUtils.tms_link(match[:tms]) } }
    end

    def issue_links(tags)
      return [] unless CucumberConfig.issue_link_pattern

      tags
        .select { |tag| tag.name.match?(issue_pattern) }
        .map { |tag| tag.name.match(issue_pattern) { |match| ResultUtils.issue_link(match[:issue]) } }
    end

    def severity(tags)
      severity = tags
        .detect { |tag| tag.name.match?(severity_pattern) }&.name
        &.match(severity_pattern)&.[](:severity) || "normal"

      ResultUtils.severity_label(severity)
    end

    private

    def reserved?(tag)
      tag.match?(tms_pattern) || tag.match?(issue_pattern) || tag.match?(severity_pattern)
    end

    def tms_pattern
      /@#{CucumberConfig.tms_prefix}(?<tms>\S+)/
    end

    def issue_pattern
      /@#{CucumberConfig.issue_prefix}(?<issue>\S+)/
    end

    def severity_pattern
      /@#{CucumberConfig.severity_prefix}(?<severity>\S+)/
    end
  end
end
