#
# Copyright:: Copyright (c) 2009-2025 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path("../spec_helper", __dir__)

# End-to-end usage scenarios, ported from the former Cucumber features.
describe "Configuring an application with Mixlib::Config" do
  let(:config_class) do
    Class.new { extend Mixlib::Config }
  end

  let(:other_config_class) do
    Class.new { extend Mixlib::Config }
  end

  it "sets a configuration option to a string" do
    config_class[:foo] = "bar"
    expect(config_class[:foo]).to eql("bar")
  end

  it "keeps the same option separate across two configuration classes" do
    config_class[:foo] = "bar"
    other_config_class[:foo] = "bar2"

    expect(other_config_class[:foo]).to eql("bar2")
    expect(config_class[:foo]).to eql("bar")
  end

  it "sets a configuration option to an array" do
    config_class[:foo] = []
    config_class[:foo] << "bar"
    config_class[:foo] << "baz"

    expect(config_class[:foo]).to eql(%w{bar baz})
  end

  it "loads configuration options from a Ruby file on disk" do
    config_class.from_file(File.expand_path("../fixtures/sample_config.rb", __dir__))

    expect(config_class[:foo]).to eql("bar")
    expect(config_class[:baz]).to eql("snarl")
  end
end
