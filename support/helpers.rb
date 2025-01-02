require "erb"
require "net/http"
require "net/http/post/multipart"
require "pry"
require "yaml"
require "webrick"

CONFIGS = {
  "react/cra" => {
    :root => "build",
    :build_dir => "build",
    :js_dir => "static/js",
    :packages => [
      "@appsignal/react"
    ],
  },
  "react/vite" => {
    :root => "dist",
    :build_dir => "dist",
    :js_dir => "assets",
    :packages => [
      "@appsignal/react"
    ],
  },
  "vue" => {
    :root => "dist",
    :build_dir => "dist",
    :js_dir => "js",
    :packages => [
      "@appsignal/vue"
    ],
  },
  "angular" => {
    :root => "dist/app",
    :build_dir => "dist",
    :js_dir => "app",
    :packages => [
      "@appsignal/angular"
    ],
  },
  "stimulus" => {
    :root => "public",
    :build_dir => "public",
    :js_dir => "",
    :packages => [
      "@appsignal/stimulus"
    ],
  }
}

PACKAGE_MANAGER = "yarn"

def all_apps
  Dir["frameworks/*/*"].map do |path|
    path.gsub("frameworks/", "")
  end
end

def app_config(app)
  config_entry = CONFIGS.find do |key, value|
    app.start_with?(key)
  end

  raise "#{app} not configured" unless config_entry

  config_entry[1]
end

def get_app
  ENV['app'].tap do |app|
    raise "Specify which app you want to run using app=path" if app.nil?
    raise "#{app} not found" unless File.exist?("frameworks/#{app}")
  end
end

def get_keys
  unless File.exist?("keys.yml")
    raise "Create a keys.yml file, see the readme"
  end
  YAML.load_file("keys.yml")
end

def demo_revision
  "0123456789abcdef".chars.sample(7).join + "-demo"
end

def render_erb(file, binding)
  ERB.new(File.read(file)).result(binding)
end

def write_appsignal_config(app, frontend_key, revision, uri)
  @frontend_key = frontend_key
  @revision = revision
  @uri = uri
  puts "Writing appsignal with #{@frontend_key} - #{@revision} - #{@uri}"
  filename = if File.exist?("frameworks/#{app}/tsconfig.json")
               "appsignal.ts"
             else
               "appsignal.js"
             end
  File.write(
    "frameworks/#{app}/src/#{filename}",
    render_erb("support/templates/#{filename}.erb", binding)
  )
end

def upload_sourcemaps(app, uri, revision, push_api_key)
  config = app_config(app)
  base_path = "frameworks/#{app}/#{config.fetch(:build_dir)}/#{config.fetch(:js_dir)}/"
  Dir["#{base_path}*.js"].each do |path|
    filename = path.gsub(base_path, "")
    puts "Uploading sourcemap for #{filename} to #{uri}..."
    full_uri =  URI("#{uri}?push_api_key=#{push_api_key}")
    params = {
      "name[]" => "http://localhost:5001/#{config.fetch(:js_dir)}/#{filename}",
      "revision" => revision,
      "file" => UploadIO.new(File.open("#{base_path}/#{filename}.map"), "application/json", "#{filename}.map")
    }
    request = Net::HTTP::Post::Multipart.new(full_uri, params)
    response = Net::HTTP.start(full_uri.host, full_uri.port, :use_ssl => true) do |http|
      http.request(request)
    end
    if response.code != "201"
      raise [
        "Unexpected response code: #{response.code}",
        "Response body: #{response.body}"
      ].join("\n")
    else
      puts "Upload for #{filename} finished"
    end
  end
end

def run_command(command)
  puts "Running '#{command}'"
  # Spawn child process with parent process STDIN, STDOUT and STDERR
  pid = spawn({}, command, :in => $stdin, :out => $stdout, :err => $stderr)
  # Wait for child process to end
  _pid, status = Process.wait2(pid)
  # Raise with the error status code if an error occurred in the child process
  raise "Error running command: #{status.exitstatus}" unless status.success?
end

def run_install(app)
  run_command "cd frameworks/#{app} && #{PACKAGE_MANAGER} install --force --no-fund --no-audit"
end

def run_build(app)
  run_command "cd frameworks/#{app} && #{PACKAGE_MANAGER} run build"
end

def app_packages(app)
  config = app_config(app)

  [
    "@appsignal/types",
    "@appsignal/core",
    "@appsignal/javascript",
  ] + config.fetch(:packages)
end

def run_link
  all_apps.each do |app|
    packages = app_packages(app)

    run_command "cd frameworks/#{app} && #{PACKAGE_MANAGER} link #{packages.join(" ")}"
  end
end

def run_unlink
  all_apps.each do |app|
    packages = app_packages(app)

    run_command "cd frameworks/#{app} && #{PACKAGE_MANAGER} unlink #{packages.join(" ")}"
  end
end

def run_webserver(app, port=5001)
  puts "Starting webserver for #{app}"
  config = app_config(app)
  WEBrick::HTTPServer.new(
    :Port => port,
    :DocumentRoot => "frameworks/#{app}/#{config.fetch(:root)}"
  ).start
end
