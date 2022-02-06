require "erb"
require "yaml"
require "webrick"

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

def get_keys
  unless File.exists?("keys.yml")
    raise "Create a keys.yml file, see the readme"
  end
  YAML.load_file("keys.yml")
end

def render_erb(file, binding)
  ERB.new(File.read(file)).result(binding)
end

def write_appsignal_js(app_path, frontend_key, revision, uri)
  @frontend_key = frontend_key
  @revision = revision
  @uri = uri
  puts "Writing appsignal with #{@frontend_key} - #{@revision} - #{@uri}"
  File.write(
    "#{app_path}/src/appsignal.js",
    render_erb("support/templates/appsignal.js.erb", binding)
  )
end

def upload_sourcemaps(app_path, revision, push_api_key)
  base_path = "#{app_path}/build/static/js/"
  Dir["#{base_path}*.js"].each do |path|
    filename = path.gsub(base_path, "")
    puts "Uploading sourcemap for #{filename}"
    curl_command = <<-CURL
    curl -k -X POST -H 'Content-Type: multipart/form-data' \
      -F 'name[]=http://localhost:3000/static/js/#{filename}' \
      -F 'revision=#{revision}' \
      -F 'file=@./#{base_path}#{filename}.map' \
      'https://appsignal.com/api/sourcemaps?push_api_key=#{push_api_key}'
    CURL
    run_command curl_command
  end
end

def child_processes
  @child_processes ||= []
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

def run_npm_install(app)
  run_command "cd #{app} && npm install --no-fund --no-audit"
end

def run_webserver(app_path, port=3000)
  puts "Starting webserver for #{app_path}"
  WEBrick::HTTPServer.new(
    :Port => port,
    :DocumentRoot => "#{app_path}/build"
  ).start
end
