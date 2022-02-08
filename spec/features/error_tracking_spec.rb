require "spec_helper"

describe "Error tracking", :type => :feature do
  before :all do
    Thread.new do
      run_endpoint
    end
  end

  let(:app_server) do
    Thread.new do
      run_webserver(app, 9001)
    end
  end

  all_apps.each do |a_app|
    context "for #{a_app}" do
      let(:app) { a_app }

      before do
        # Install modules
        run_install app
        # Write appsignal.js
        write_appsignal_config(
          app,
          "frontend-key",
          "revision",
          "http://localhost:4567/collect"
        )
        # Make production build
        run_build app
        # Start webserver
        app_server
      end

      after do
        app_server.kill
        EndpointServer.clear
      end

      it "should track a frontend error" do
        # Visit page with an error
        visit "http://localhost:9001"

        # Should be sent to the mock endpoint
        request = EndpointServer.pop_received_request
        expect(request).not_to be_nil
        expect(request.env["rack.request.query_string"]).to eq "api_key=frontend-key&version=1.3.20"

        # Check the content of the body
        body = JSON.parse(request.body.read)

        # Timestamp
        expect(body["timestamp"]).to be > 1644138966

        # Error
        expect(body["error"]).to be_a_kind_of Hash
        expect(body["error"]["name"]).to eq "Error"
        expect(body["error"]["message"]).to eq "This is an error"
        expect(body["error"]["backtrace"]).to be_a_kind_of Array

        # Environment
        expect(body["environment"]).to be_a_kind_of Hash
        expect(body["environment"]["transport"]).to eq "fetch"
        expect(body["environment"]["origin"]).to eq "http://localhost:9001"

        # Revision
        expect(body["revision"]).to eq "revision"

        # Tags
        expect(body["tags"]). to be_a_kind_of Hash
      end
    end
  end
end
