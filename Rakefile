require "./support/helpers.rb"

namespace :app do
  task :install do
    @app = get_app
    run_install @app
  end

  task :run do
    @app = get_app
    @keys = get_keys

    # Check if we have all input
    @frontend_key = @keys["frontend_key"] or raise "No frontend key set in keys.yml"
    @push_key = @keys["push_key"] or raise "No push key set in keys.yml"
    @revision = ENV["revision"] or raise "No revision set in env"
    # Use uris from keys.yml, or the default production ones
    @uri = @keys["uri"] || "https://appsignal-endpoint.net/collect"
    @sourcemap_uri = @keys["sourcemaps_uri"] || "https://appsignal.com/api/sourcemaps"

    puts "Writing appsignal.js"
    write_appsignal_config(
      @app,
      @frontend_key,
      @revision,
      @uri
    )

    # Make production build
    run_build @app

    # Upload the sourcemaps
    upload_sourcemaps(@app, @sourcemap_uri, @revision, @push_key)

    # Run the webserver
    Thread.new do
      run_webserver(@app)
    end

    # Open page in the browser
    run_command "open http://localhost:5001"

    # Stay alive
    loop do
      sleep 1
    end
  end
end

desc "Update the readme using the template"
task :update_readme do
  puts "Updating readme"
  @apps = all_apps
  File.write "README.md", render_erb("support/templates/README.md.erb", binding)
end

task :clean do
  all_apps.each do |app|
    run_command "cd frameworks/#{app} && rm -rf build"
    run_command "cd frameworks/#{app} && rm -rf dist"
    run_command "cd frameworks/#{app} && rm -rf node_modules"
    run_command "cd frameworks/#{app} && rm -rf package-lock.json"
  end
end
