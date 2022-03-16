require 'rake'
require 'rubygems/package_task'
require File.expand_path('../railslts-version/lib/railslts-version', __FILE__)

BRANCH = '2-3-lts'
SUB_PROJECT_PATHS = %w(activesupport railties actionpack actionmailer activeresource activerecord railslts-version)
ALL_PROJECT_PATHS = ['.', *SUB_PROJECT_PATHS]

fail = lambda { |message|
  STDERR.puts "\e[31m#{message}\e[0m" # red
  exit(1)
}

run = lambda { |command|
  info = command.sub(/:\/\/\w+\:[^@]+@/, '://...@')
  puts "\e[35m#{info}\e[0m" # pink
  result = system(command)
  result or fail.call("Failed to execute `#{info}`")
  true
}

class TestRunner
  def initialize
    @failures = []
    yield(self)
    summary
  end

  def run(name, command)
    puts '', "\033[44m#{name}\033[0m", ''
    puts "\e[35m#{command}\e[0m"
    unless system(command)
      STDERR.puts "\e[31mFailures testing #{name}.\e[0m"
      @failures << name
    end
  end

  private

  def summary
    if @failures.empty?
      puts
      puts "\e[32mAll tests passed.\e[0m"
    else
      puts
      puts "\e[31mThe following tests failed:"
      @failures.each { |f| puts f }
      puts "\e[0m"
      exit(1)
    end
  end
end

rails_gemspec = eval(File.read('rails.gemspec'))
Gem::PackageTask.new(rails_gemspec) do |p|
  p.gem_spec = rails_gemspec
end

namespace :railslts do

  desc 'Run tests for Rails LTS compatibility'
  task :test do

    TestRunner.new do |runner|

      runner.run('activesupport', 'cd activesupport && rake test')

      runner.run('actionmailer', 'cd actionmailer && rake test')

      runner.run('actionpack', 'cd actionpack && rake test')

      if Gem.loaded_specs.has_key?('mysql2')
        runner.run('activerecord (mysql2)', 'cd activerecord && rake mysql:rebuild_databases test_mysql2')
      else
        runner.run('activerecord (mysql)', 'cd activerecord && rake mysql:rebuild_databases test_mysql')
      end

      runner.run('activerecord (sqlite3)', 'cd activerecord && rake test_sqlite3')

      runner.run('activerecord (postgres)', 'cd activerecord && rake postgresql:rebuild_databases test_postgresql')

      runner.run('activeresource', 'cd activeresource && rake test')

      runner.run('railties', 'cd railties && rake test')

      runner.run('railslts-version', 'cd railslts-version && rake test')

    end
  end

  namespace :gems do

    # Clean previous .gem files in pkg/ folder of root and sub-projects
    task :delete do
      ALL_PROJECT_PATHS.each do |project|
        pkg_folder = "#{project}/pkg"
        puts "Emptying packages folder #{pkg_folder}..."
        FileUtils.mkdir_p(pkg_folder)
        run.call("rm -f #{pkg_folder}/*.gem")
      end
    end

    task :ensure_old_rubygems do
      if Gem::VERSION != '1.8.30'
        fail "Please package with RubyGems version 1.8.30"
      end
    end

    # Call :package task in sub-projects
    task :package_all => :ensure_old_rubygems do
      ALL_PROJECT_PATHS.each do |project|
        run.call("cd #{project} && rake package")
      end
    end

    # Clean up building artifacts left by :package tasks
    task :clean_building_artifacts do
      ALL_PROJECT_PATHS.each do |project|
        pkg_folder = "#{project}/pkg"
        puts "Deleting building artifacts from #{pkg_folder}..."
        run.call("rm -rf #{pkg_folder}/*.tgz") # TGZ
        run.call("rm -rf #{pkg_folder}/*.zip") # ZIP
        run.call("rm -rf #{pkg_folder}/*/")    # Folder
      end
    end

    # Move *.gem packages from sub-projects's pkg to root's pkg for easier releasing
    task :consolidate do
      SUB_PROJECT_PATHS.each do |project|
        pkg_folder = "#{project}/pkg"
        gem_path = "#{pkg_folder}/#{project}-#{RailsLts::VERSION::STRING}.gem"
        puts "Moving .gem from #{gem_path} to pkg ..."
        File.file?(gem_path) or fail.call("Not found: #{gem_path}")
        consolidated_pkg_folder = 'pkg'
        FileUtils.mkdir_p(consolidated_pkg_folder)
        FileUtils.mv(gem_path, consolidated_pkg_folder)
      end
    end

    desc 'Builds *.gem packages for distribution without Git'
    task :build => [:ensure_old_rubygems, :delete, :package_all, :consolidate, :clean_building_artifacts] do
      puts 'Done.'
    end

  end

  desc 'Updates the LICENSE file in individual sub-projects'
  task :update_license do
    require 'date'
    last_change = Date.parse(`git log -1 --format=%cd`)
    ALL_PROJECT_PATHS.each do |project|
      next if project == 'railslts-version' # has no LICENSE file
      license_path = "#{project}/LICENSE"
      puts "Updating license #{license_path}..."
      File.exists?(license_path) or fail.call("Could not find license: #{license_path}")
      license = File.read(license_path)
      license.sub!(/ before(.*?)\./ , " before #{(last_change + 10).strftime("%B %d, %Y")}.") or fail.call("Couldn't find timestamp.")
      File.open(license_path, "w") { |w| w.write(license) }
    end
  end

  namespace :customer do

    task :ensure_ready do
      jobs = [
        "Did you update the version in railslts-version/lib/railslts-version.rb (currently #{RailsLts::VERSION::STRING})?",
        'Did you update the LICENSE files using `rake railslts:update_license?',
        'Did you commit and push your changes, as well as the changes by the Rake tasks mentioned above?',
        'Did you build static gems using `rake railslts:gems:build` (those are not pushed to Git)?',
        'Did you activate key forwarding for *.railslts.makandra.de?',
        "We will now publish the Rails LTS #{RailsLts::VERSION::STRING} for customers. Ready?",
      ]

      puts

      jobs.each do |job|
        print "#{job} [y/n] "
        answer = STDIN.gets
        puts
        unless answer.strip == 'y'
          $stderr.puts 'Aborting. Nothing was released.'
          puts
          exit
        end
      end
    end

    task :push_to_git_repo do
      %w[c23 c42].each do |hostname|
        fqdn = "#{hostname}.railslts.makandra.de"
        puts "\033[1mUpdating #{fqdn}...\033[0m"
        command = "cd /var/www/railslts && git fetch origin #{BRANCH}:#{BRANCH}"
        run.call "ssh deploy-gems_p@#{fqdn} '#{command}'"
        puts 'Done.'
      end

      puts 'Gems pushed to customer Git repo.'
      puts "Now run `git clone -b #{BRANCH} https://gems.makandra.de/railslts #{BRANCH}-test-checkout`"
      puts 'and make sure your commits are present.'
    end

    task :push_to_gem_server do
      print 'Enter password for railslts-gems-admin.makandra.de: '
      begin
        system('stty -echo')
        password = $stdin.gets.chomp
      ensure
        system('stty echo')
      end
      server_url = "https://admin:#{password}@railslts-gems-admin.makandra.de"
      gem_paths = Dir.glob('pkg/*.gem')
      gem_paths.size == ALL_PROJECT_PATHS.size or fail.call("Expected #{ALL_PROJECT_PATHS.size} .gem files, but only got #{gem_paths.inspect}")
      gem_paths.each do |gem_path|
        puts "Publishing #{gem_path}"
        # Hide STDOUT since that will print the server URL including the password
        run.call("gem push #{gem_path} --host #{server_url} > /dev/null")
        puts "Waiting a bit..."
        sleep 3
      end
    end

    desc "Publish Rails LTS #{RailsLts::VERSION::STRING} for customers"
    task :release => [:ensure_ready, :push_to_git_repo, :push_to_gem_server]

  end

  namespace :community do

    task :push_to_git_repo do
      existing_remotes = `git remote`
      unless existing_remotes.include?('community')
        run.call('git remote add community git@github.com:makandra/rails.git')
      end
      run.call('git fetch community')

      puts 'We will now publish the following changes to GitHub:'
      puts
      run.call("git log --oneline community/#{BRANCH}..HEAD")
      puts

      puts 'Do you want to proceed? [y/n]'
      answer = STDIN.gets
      puts
      unless answer.strip == 'y'
        $stderr.puts 'Aborting. Nothing was released.'
        puts
        exit
      end

      run.call("git push community #{BRANCH}")
      puts 'Gems pushed to community github repo.'
      puts "Check https://github.com/makandra/rails/tree/#{BRANCH} and make sure your commits are present"
    end

    desc "Publish Rails LTS #{RailsLts::VERSION::STRING} for community subscribers"
    task :release => :push_to_git_repo

  end

end
