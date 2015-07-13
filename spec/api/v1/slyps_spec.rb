require 'spec_helper'

RSpec.describe API::V1::Slyps do
  include Rack::Test::Methods

  def app
    API::V1::Base
  end

  describe "GET /v1/slyps" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      it "returns all of the users slyps" do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
        get "/v1/slyps"

        # make sure all expected values are exposed
        expected_attrs = [:id, :title, :url, :raw_url, :author, :date, :text, :description, :top_image, :site_name, :video_url]
        expected_attrs.each do |attr|
          user.slyps.each do |s|
            expect(last_response.body.include?(s[attr].to_s)).to eq true
          end
        end

        expect(last_response.status).to eq 200
      end
    end
  end
end