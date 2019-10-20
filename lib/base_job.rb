# frozen_string_literal: true

class BaseJob
  include SuckerPunch::Job
  include Logging

  def validate_args
    return true unless args.empty?

    respond(lines: ["Invalid URL, please provide a URL to GitLab issue list and apply at least one filter!"])
    false
  end

  def load_issues
    time_sum = 0
    issues_without_estimates = []

    issues = Gitlab.issues(nil, args).auto_paginate
    issues.each do |issue|
      time_sum += issue.time_stats.time_estimate
      issues_without_estimates << issue.web_url if issue.time_stats.time_estimate.zero?
    end

    [time_sum, issues, issues_without_estimates]
  end

  def respond(args)
    command.respond(response_options.merge(args))
  end

  def response_options
    { username: 'GitLab', icon: "https://about.gitlab.com/images/press/logo/png/gitlab-icon-rgb.png" }
  end
end
