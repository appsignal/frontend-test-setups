require "erb"
require "yaml"
require "webrick"

FRAMEWORKS = {
  "react" => {
    :build_dir => "build",
    :js_dir => "static/js"
  },
  "vue" => {
    :build_dir => "dist",
    :js_dir => "js"
  }
}

def all_apps
  FRAMEWORKS.map do |language, config|
    Dir["frameworks/#{language}/*"].sort
  end.flatten.map do |path|
    path.gsub("frameworks/", "")
  end
end

def framework_config(app)
  framework = app.split("/").first
  FRAMEWORKS[framework] or raise "#{framework} not configured"
end

def get_app
  ENV['app'].tap do |app|
    raise "Specify which app you want to run using app=path" if app.nil?
    raise "#{app} not found" unless File.exists?("frameworks/#{app}")
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

def write_appsignal_config(app, frontend_key, revision, uri)
  @frontend_key = frontend_key
  @revision = revision
  @uri = uri
  puts "Writing appsignal with #{@frontend_key} - #{@revision} - #{@uri}"
  filename = if File.exists?("frameworks/#{app}/tsconfig.json")
               "appsignal.ts"
             else
               "appsignal.js"
             end
  File.write(
    "frameworks/#{app}/src/#{filename}",
    render_erb("support/templates/appsignal.js.erb", binding)
  )
end

def upload_sourcemaps(app, uri, revision, push_api_key)
  config = framework_config(app)
  base_path = "frameworks/#{app}/#{config[:build_dir]}/#{config[:js_dir]}/"
  Dir["#{base_path}*.js"].each do |path|
    filename = path.gsub(base_path, "")
    puts "Uploading sourcemap for #{filename}"
    curl_command = <<-CURL
    curl -k -X POST -H 'Content-Type: multipart/form-data' \
      -F 'name[]=http://localhost:5001/js/#{filename}' \
      -F 'revision=#{revision}' \
      -F 'file=@./#{base_path}#{filename}.map' \
      '#{uri}?push_api_key=#{push_api_key}'
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
  run_command "cd frameworks/#{app} && npm install --no-fund --no-audit"
end

def run_npm_build(app)
  run_command "cd frameworks/#{app} && npm run build"
end

def run_webserver(app, port=5001)
  puts "Starting webserver for #{app}"
  config = framework_config(app)
  WEBrick::HTTPServer.new(
    :Port => port,
    :DocumentRoot => "frameworks/#{app}/#{config[:build_dir]}"
  ).start
end
