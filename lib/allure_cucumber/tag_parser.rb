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

      tms_pattern = reserved_patterns[:tms]
      tags
        .select { |tag| tag.name.match?(tms_pattern) }
        .map { |tag| tag.name.match(tms_pattern) { |match| ResultUtils.tms_link(match[:tms]) } }
    end

    def issue_links(tags)
      return [] unless CucumberConfig.issue_link_pattern

      issue_pattern = reserved_patterns[:issue]
      tags
        .select { |tag| tag.name.match?(issue_pattern) }
        .map { |tag| tag.name.match(issue_pattern) { |match| ResultUtils.issue_link(match[:issue]) } }
    end

    def severity(tags)
      severity_pattern = reserved_patterns[:severity]
      severity = tags
        .detect { |tag| tag.name.match?(severity_pattern) }&.name
        &.match(severity_pattern)&.[](:severity) || "normal"

      ResultUtils.severity_label(severity)
    end

    def status_detail_tags(tags)
      {
        flaky: tags.any? { |tag| tag.match?(reserved_patterns[:flaky]) },
        muted: tags.any? { |tag| tag.match?(reserved_patterns[:muted]) },
        known: tags.any? { |tag| tag.match?(reserved_patterns[:known]) },
      }
    end

    private

    def reserved_patterns
      @reserved_patterns ||= {
        tms: /@#{CucumberConfig.tms_prefix}(?<tms>\S+)/,
        issue: /@#{CucumberConfig.issue_prefix}(?<issue>\S+)/,
        severity: /@#{CucumberConfig.severity_prefix}(?<severity>\S+)/,
        flaky: /@flaky/,
        muted: /@muted/,
        known: /@known/,
      }
    end

    def reserved?(tag)
      reserved_patterns.values.any? { |pattern| tag.match?(pattern) }
    end
  end
end
