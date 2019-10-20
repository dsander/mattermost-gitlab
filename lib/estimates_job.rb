# frozen_string_literal: true

class EstimatesJob < BaseJob
  include ActiveSupport::Inflector
  attr_reader :command, :args

  def perform(command, hostname)
    @command = command
    @args = url_to_api_params(command.text)

    validate_args || return

    (time_sum, issues, issues_without_estimates) = load_issues

    actions = if issues_without_estimates.length.positive?
                [{ name: "Show #{issues_without_estimates.length} issues without estimates",
                   integration: { url: "#{hostname}/api/actions/list_unestimated",
                                  context: { response_url: command.response_url, args: args, token: ENV['ESTIMATES_TOKEN'] } } }]
              else
                []
              end

    respond(lines: [], attachments: [{ title: "Time estimation summary for #{issues.length} issues", title_link: command.text,
                                       text: "#### #{seconds_to_human(time_sum)}",
                                       fields: args.map { |k, v| { title: k.to_s.humanize, value: v, short: true } },
                                       actions: actions }], response_type: 'in_channel')
  rescue StandardError => e
    respond(lines: [e.message] + e.backtrace)
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
