# -*- coding: utf-8 -*-
require 'yaml'
require 'spec_helper'

# hostname = 'test'
fqdn = 'test.example.com'

describe 'hostname::vmware' do
  let(:shellout_ok) { double(run_command: nil, error!: nil, stdout: fqdn, stderr: double(empty?: true)) }
  let(:runner) { ChefSpec::SoloRunner.new }

  context 'By default' do
    before do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('hostname::default')
    end

    let(:chef_run) do
      expect(Mixlib::ShellOut).to receive(:new).and_return(shellout_ok)
      stub_command("if [[ `hostname -f` == \"#{fqdn}\" ]]").and_return(true)
      runner.node.automatic['virtualization']['system'] = 'vmware'
      runner.converge(described_recipe)
    end

    it 'includes recipes' do
      expect(chef_run).to include_recipe(described_recipe)
    end

    it 'includes default recipe' do
      expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('hostname::default')
      chef_run
    end
  end
end
