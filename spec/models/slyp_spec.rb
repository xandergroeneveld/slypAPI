require 'spec_helper'
require_relative '../factories/slyp.rb'

RSpec.describe Slyp do
  describe "associations" do
    it { should have_many(:user_slyps) }
    it { should have_many(:users).through(:user_slyps) }
  end
end