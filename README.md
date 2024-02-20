# Obst

Obsidian stats

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'obst'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install obst

## Usage

Git log

```ruby
git_log = Obst::GitLog.new(C: '/path/to/local/git/repo', after: '2022-10-16T00:00:00')

# just like git log in shell
git_log.to_s

# wrapped committed time and file status
git_log.commits
```

Group by Days

```ruby
Obst::GroupByDays.new(C: '/path/to/local/git/repo', after: '2022-10-20T00:00:00', days: 7)
```

## Config

Place .obst.json under dir where you run obst. Content for example:

```json
{
  // for all stats
  "pathspec": [":!.obsidian", ":!calendar"],
  // for specific stats
  "long_time_no_see": {
    "pathspec": [":!.obsidian", ":!calendar"]
  }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Obst project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/turnon/obst/blob/master/CODE_OF_CONDUCT.md).
