class EstimatesJob < BaseJob
  attr_reader :command

  def perform(command)
    @command = command
    args = Rack::Utils.parse_query(URI(command.text).query)
    args = transform_query_params(args)

    if args.empty?
      respond(lines: ["Invalid URL, please provide a URL to GitLab issue list and apply at least one filter!"])
      return
    end

    time_sum = 0
    issues_without_estimates = []

    issues = Gitlab.issues(nil, args).auto_paginate
    issues.each do |issue|
      time_sum += issue.time_stats.time_estimate
      issues_without_estimates << issue.web_url if issue.time_stats.time_estimate == 0
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
    {username: 'GitLab', icon: "https://about.gitlab.com/images/press/logo/png/gitlab-icon-rgb.png"}
  end

  def transform_query_params(args)
    args = args.slice('assignee_username', 'milestone_title', 'label_name[]', 'author_username', 'scope', 'state')
    if labels = args.delete('label_name[]')
      args['labels'] = labels.is_a?(Array) ? labels.join(',') : labels
    end
    args['milestone'] = args.delete('milestone_title') if args['milestone_title']
    args.transform_keys!(&:to_sym)
  end

  def seconds_to_human(seconds)
    {'w' => 8 * 5 * 3600, 'd' => 8 * 3600, 'h' => 3600}.map do |label, duration|
      dur = seconds / duration
      time_sum = seconds % duration
      [label, dur]
    end.select { |_, dur| dur > 0 }.map { |label, dur| "#{dur}#{label}" }.join(' ')
  end
end
