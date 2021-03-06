require './app'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins 'dev.slyp.io', 'staging.slyp.io', 'alpha.slyp.io'
    resource '*', headers: :any, methods: [:get, :post, :options, :put, :delete]
  end
end
use ActiveRecord::ConnectionAdapters::ConnectionManagement

NewRelic::Agent.manual_start

run API::V1::Base