require "erb"
require "fileutils"

FRAMEWORKS = %w(react)

def app_paths
  FRAMEWORKS.map do |language|
    Dir["#{language}/*"].sort
  end.flatten
end

def get_app
  ENV['app'].tap do |app|
    raise "Specify which app you want to run using app=path" if app.nil?
    raise "#{app} not found" unless File.exists?(app)
  end
end

def child_processes
  @child_processes ||= []
end

def render_erb(file)
  ERB.new(File.read(file)).result
end

def run_command(command)
  puts "Running '#{command}'"
  # Spawn child process with parent process STDIN, STDOUT and STDERR
  pid = spawn({}, command, :in => $stdin, :out => $stdout, :err => $stderr)
  # Register child process so we can wait for it to exit gracefully later
  child_processes << [pid, command]
  # Wait for child process to end
  _pid, status = Process.wait2(pid)
  # Exit with the error status code if an error occurred in the child process
  exit status.exitstatus unless status.success?
end

namespace :app do
  task :run do
    @app = get_app
    run_command "cd #{@app} && npm install"
    run_command "cd #{@app} && npm start"
  end
end

namespace :global do
  desc "Update the readme using the template"
  task :update_readme do
    puts "Updating readme"
    @apps = app_paths
    File.write "README.md", render_erb("support/templates/README.md.erb")
  end

  task :set_appsignal_config do
    @key = ENV['key'] or raise "No key provided"
    puts "Writing appsignal.js to all test apps"
    app_paths.each do |path|
      puts path
      File.write(
        "#{path}/src/appsignal.js",
        render_erb("support/templates/appsignal.js.erb")
      )
    end
  end
end
