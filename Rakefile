require "erb"
require "webrick"
require "yaml"
require "./support/helpers.rb"

namespace :app do
  task :install do
    @app = get_app
    run_command "cd #{@app} && npm install"
  end

  task :run do
    @app = get_app
    @keys = get_keys

    # Check if we have all input
    @frontend_key = @keys["frontend_key"] or raise "No frontend key set in keys.yml"
    @push_key = @keys["push_key"] or raise "No push key set in keys.yml"
    @revision = ENV["revision"] or raise "No revision set in env"

    puts "Writing appsignal.js"
    File.write(
      "#{@app}/src/appsignal.js",
      render_erb("support/templates/appsignal.js.erb")
    )

    # Make a production build
    run_command "cd #{@app} && npm run build"

    # Upload the sourcemaps
    upload_sourcemaps(@app, @revision, @push_key)

    # Run the webserver
    WEBrick::HTTPServer.new(
      :Port => 3000,
      :DocumentRoot => "#{@app}/build"
    ).start
  end
end

namespace :global do
  desc "Update the readme using the template"
  task :update_readme do
    puts "Updating readme"
    @apps = app_paths
    File.write "README.md", render_erb("support/templates/README.md.erb")
  end
end
