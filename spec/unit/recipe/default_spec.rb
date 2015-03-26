# -*- coding: utf-8 -*-

require 'spec_helper'

hostname = 'test'
domain = 'example.com'
fqdn = "#{hostname}.#{domain}"

describe 'hostname::default' do
  let(:ubuntu)  { ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') }
  let(:centos)  { ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5') }
  let(:freebsd) { ChefSpec::SoloRunner.new(platform: 'freebsd', version: '9.1') }

  context 'By default' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      stub_command("if [[ `hostname -s` == \"#{hostname}\" ]]").and_return(false)
      runner.node.automatic['hostname'] = hostname
      runner.node.set['set_fqdn'] = fqdn
      runner.converge(described_recipe)
    end

    it 'should include the hostname::default recipe' do
      expect(chef_run).to include_recipe 'hostname::default'
    end

    it 'Updates hostsfile_etries' do
      expect(chef_run).to append_hostsfile_entry('localhost')
    end

    it "set hostname #{hostname}" do
      expect(chef_run).to create_hostsfile_entry('set hostname')
    end

    it "executes hostname #{hostname}" do
      exe = chef_run.execute("hostname #{hostname}")
      expect(exe).to notify('ohai[reload_hostname]').to(:reload).delayed
      expect(chef_run).to run_execute "hostname #{hostname}"
    end

    it 'reloads ohai' do
      expect(chef_run).to_not reload_ohai('reload_hostname')
    end
  end

  context 'On debian OSs' do
    let(:chef_run) do
      stub_command("if [[ `hostname -s` == \"#{hostname}\" ]]").and_return(true)
      ubuntu.node.automatic['hostname'] = hostname
      ubuntu.node.set['set_fqdn'] = fqdn
      ubuntu.converge(described_recipe)
    end
    it 'Update /etc/hostname' do
      expect(chef_run).to render_file('/etc/hostname').with_content("#{hostname}\n")
    end
  end

  context 'On redhat OSs' do
    let(:chef_run) do
      stub_command("if [[ `hostname -s` == \"#{hostname}\" ]]").and_return(true)
      centos.node.automatic['hostname'] = hostname
      centos.node.set['set_fqdn'] = fqdn
      centos.converge(described_recipe)
    end

    it 'ruby_block updates /etc/sysconfig/network' do
      rb = chef_run.ruby_block('Update /etc/sysconfig/network')
      expect(rb).to notify('ohai[reload_hostname]').to(:reload).delayed
      expect(chef_run).to run_ruby_block 'Update /etc/sysconfig/network'
    end

    it 'ruby_block updates sysctl' do
      expect(chef_run).to run_ruby_block 'Update /etc/sysctl.conf'
    end

    it 'reload ohai on update' do
      rb = chef_run.ruby_block('Update /etc/sysconfig/network')
      expect(rb).to notify('ohai[reload_hostname]').to(:reload).delayed
    end
  end

  context 'On BSD OSs' do
    let(:chef_run) do
      stub_command("if [[ `hostname -s` == \"#{hostname}\" ]]").and_return(true)
      freebsd.node.automatic['hostname'] = hostname
      freebsd.node.set['set_fqdn'] = fqdn
      freebsd.converge(described_recipe)
    end
    it 'creates /etc/rc.conf.d' do
      expect(chef_run).to create_directory('/etc/rc.conf.d')
    end
    it 'service netif' do
      expect(chef_run).to_not restart_service('netif')
    end
    it 'update to hostname restarts netif' do
      f = chef_run.file('/etc/rc.conf.d/hostname')
      expect(f).to notify('service[netif]').to(:reload)
      expect(chef_run).to create_file('/etc/rc.conf.d/hostname')
    end
  end
end
