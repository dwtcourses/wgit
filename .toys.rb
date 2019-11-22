# frozen_string_literal: true

# The new Rakefile, place any tasks/tools below (listed alphabetically).
# To load .env vars into the ENV from a tool, use:
# require 'dotenv/load'

require 'byebug' # Useful for tool development.

# tool :build
expand :gem_build

tool :ci do
  desc 'Runs the CI steps needed for a green build'

  include :exec, exit_on_nonzero_status: false
  include :terminal

  def run
    run_step 'Build gem', 'build'
    run_step 'Generate documentation', ['generate_docs', '--no-output']
    run_step 'Run tests', 'test'
  end

  def run_step(name, tool)
    if exec_tool(tool).success?
      puts "** #{name} passed", :green, :bold
      puts
    else
      puts "** #{name} failed, exiting!", :red, :bold
      exit 1
    end
  end
end

# tool :clean
expand :clean, paths: ['pkg', 'doc', 'tmp', '.doc', '.yardoc']

tool :compile do
  desc 'Compile all project Ruby files with warnings'

  include :exec, exit_on_nonzero_status: true
  include :terminal

  def run
    Dir['**/*.rb', '**/*.gemspec', 'bin/console'].each do |file|
      puts "\nCompiling #{file}...", :cyan
      exec "ruby -cw #{file}"
    end
  end
end

tool :console do
  desc 'Run the development console'

  include :exec, exit_on_nonzero_status: true

  def run
    exec './bin/console'
  end
end

# tool :generate_docs
expand :yardoc do |t|
  t.name = :generate_docs
  t.generate_output_flag = true
  t.fail_on_warning = true
  t.fail_on_undocumented_objects = true
end

# tool :install
expand :gem_build do |t|
  t.name = :install
  t.install_gem = true
end

# tool :lint
expand :rubocop, name: :lint

tool :mtest do
  desc 'Runs entire test_*.rb file or single test at --line'
  required_arg :file
  flag :line, '-l', '--line=VALUE'

  include :exec, exit_on_nonzero_status: true

  def run
    exec "bundle exec mtest #{test_cmd}"
  end

  def test_cmd
    cmd = options[:file]
    raise 'Colon not allowed, use --line' if cmd.include?(':')

    cmd = "test/test_#{cmd}" unless cmd.start_with?('test/test_')
    cmd += '.rb' unless cmd.end_with?('.rb')
    cmd += ":#{line}" if line

    cmd
  end
end

tool :release do
  desc 'The SAFE release task which double checks things!'
  long_desc 'Tag and push commits to Github, then build and push the gem to Rubygems.'

  include :exec, exit_on_nonzero_status: true
  include :terminal

  def run
    raise 'Error requiring wgit' unless require_relative 'lib/wgit'

    puts "Releasing #{Wgit.version_str}, using the 'origin' Git remote...", :cyan
    confirmed = confirm "Have you applied the wiki's 'Gem Publishing Checklist'?"
    unless confirmed
      puts 'Aborting!', :red
      exit(0)
    end

    exec_tool 'release_gem'
    puts 'Release complete', :green
  end
end

# tool :release_gem
expand :gem_build do |t|
  t.name = :release_gem
  t.install_gem = false
  t.push_gem = true
  t.tag = true
  t.push_tag = true
end

tool :rubocop do
  desc 'Run the rubocop linter, use -a to auto correct'
  flag :autocorrect, '-a', '--autocorrect'

  include :exec, exit_on_nonzero_status: true

  def run
    autocorrect ? exec('bundle exec rubocop -a') : exec_tool('lint')
  end
end

tool :save_page do
  desc 'Download/update a web page test fixture to test/mock/fixtures'
  required_arg :url

  include :exec, exit_on_nonzero_status: true
  include :terminal

  def run
    exec "ruby test/mock/save_page.rb #{options[:url]}"
    puts "Don't forget to mock the page in test/mock/fixtures.rb", :green
  end
end

tool :save_site do
  desc 'Download/update a web site test fixture to test/mock/fixtures'
  required_arg :url

  include :exec, exit_on_nonzero_status: true
  include :terminal

  def run
    exec "ruby test/mock/save_site.rb #{options[:url]}"
    puts "Don't forget to mock the site in test/mock/fixtures.rb", :green
  end
end

tool :setup do
  desc 'Sets up the cloned repo for development'

  include :exec, exit_on_nonzero_status: true
  include :terminal

  def run
    exec_cmd 'touch .env'

    puts 'Setup complete', :green
  end

  def exec_cmd(command)
    puts "> #{command}", :cyan
    exec command
  end
end

# tool :smoke
expand :minitest do |t|
  t.name = :smoke
  t.libs = ['lib']
  t.files = [
    'test/test_url.rb',
    'test/test_document.rb',
    'test/test_response.rb',
    'test/test_crawler.rb',
    'test/test_readme_code_examples.rb'
  ]
end

# tool :test
expand :minitest do |t|
  t.libs = ['lib']
  t.files = ['test/test_*.rb']
end

tool :yardoc do
  desc 'Generates the YARD docs, use --serve to browse'
  flag :serve, '-s', '--serve'

  include :exec, exit_on_nonzero_status: true
  include :terminal

  def run
    serve ? serve_docs : exec_tool('generate_docs')
  end

  def serve_docs
    if exec 'which pbcopy', out: :null
      url = 'http://localhost:8808'
      exec "echo '#{url}' | pbcopy"
      puts "Copied '#{url}' to clipboard", :green
    end

    exec 'bundle exec yard server -r'
  end
end