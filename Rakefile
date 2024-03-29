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
    @revision = ENV["revision"]
    if @revision.nil?
      @revision = demo_revision
      puts "No revision set in env; using demo revision #{@revision.inspect}"
    end
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

desc "Link local checkout of the javascript packages"
task :link do
  puts "Linking integrations"
  run_link
end

desc "Unlink local checkout of the javascript packages"
task :unlink do
  puts "Unlinking integrations"
  run_unlink
end

desc "Update the readme using the template"
task :update_readme do
  puts "Updating readme"
  @apps = all_apps
  File.write "README.md", render_erb("support/templates/README.md.erb", binding)
end

desc "Clean build, node_modules and lock files"
task :clean do
  all_apps.each do |app|
    config = app_config(app)
    run_command "cd frameworks/#{app} && rm -rf #{config.fetch(:build_dir)}"
    run_command "cd frameworks/#{app} && rm -rf node_modules"
    run_command "cd frameworks/#{app} && rm -rf package-lock.json"
    run_command "cd frameworks/#{app} && rm -rf yarn.lock"
  end
end
