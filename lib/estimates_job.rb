# frozen_string_literal: true

class EstimatesJob < BaseJob
  attr_reader :command

  def perform(command)
    @command = command

    args = url_to_api_params(command.text)

    if args.empty?
      respond(lines: ["Invalid URL, please provide a URL to GitLab issue list and apply at least one filter!"])
      return
    end

    time_sum = 0
    issues_without_estimates = []

    issues = Gitlab.issues(nil, args).auto_paginate
    issues.each do |issue|
      time_sum += issue.time_stats.time_estimate
      issues_without_estimates << issue.web_url if issue.time_stats.time_estimate.zero?
    end

    lines = [
      "Time estimates for issues with: " + args.map { |k, v| "#{k.downcase}: **#{v}**" }.join(" "),
      command.text,
      "#{issues.length} issues: **#{seconds_to_human(time_sum)}**"
    ]

    respond(lines: lines, response_type: 'in_channel')
    respond(lines: ["Issues missing estimations:"] + issues_without_estimates)
  rescue StandardError => e
    respond(lines: [e.message] + e.backtrace, response_type: 'in_channel')
  end

  def respond(args)
    command.respond(response_options.merge(args))
  end

  def response_options
    { username: 'GitLab', icon: "https://about.gitlab.com/images/press/logo/png/gitlab-icon-rgb.png" }
  end

  def transform_query_params(args)
    args['labels'] = Array(args.delete('label_name[]')).join(',') if args['label_name[]']
    args['milestone'] = args.delete('milestone_title') if args['milestone_title']
    args = args.slice('assignee_username', 'milestone', 'labels', 'author_username', 'scope', 'state')
    args.transform_keys!(&:to_sym)
  end

  def url_to_api_params(url)
    args = Rack::Utils.parse_query(URI(url).query)
    transform_query_params(args)
  end

  def seconds_to_human(seconds)
    durations = { 'w' => 8 * 5 * 3600, 'd' => 8 * 3600, 'h' => 3600 }.map do |label, duration|
      dur = seconds / duration
      seconds = seconds % duration
      [label, dur]
    end
    durations.select { |_, dur| dur.positive? }.map { |label, dur| "#{dur}#{label}" }.join(' ')
  end
end
