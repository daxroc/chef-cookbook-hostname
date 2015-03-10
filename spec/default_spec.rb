require 'chefspec'
require 'chefspec/berkshelf'

hostname = 'test'
domain   = 'example.com'
fqdn     = hostname + '.' + domain

describe 'hostname::default' do

  context 'By default' do
    
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        log_level:  :info 
      )
      stub_command("if [[ `hostname -f` == \"#{fqdn}\" ]]").and_return(false)
      runner.node.automatic['hostname'] = hostname
      runner.node.set['set_fqdn'] = fqdn
      runner.converge(described_recipe)
    end

    it 'should include the hostname::default recipe' do
      expect(chef_run).to include_recipe 'hostname::default'
    end 

    it "Update /etc/hostname" do
      expect(chef_run).to render_file('/etc/hostname').with_content("test\n")
    end

    it "Updates hostsfile_etries" do
      expect(chef_run).to create_hostsfile_entry('localhost') 
    end

    it "sets hostsfile #{hostname}" do
      expect(chef_run).to create_hostsfile_entry('set hostname') 
    end
  
    it "executes hostname #{fqdn}" do
      exe = chef_run.execute("hostname #{fqdn}")
      expect(exe).to notify('ohai[reload]').to(:reload).delayed
      expect(chef_run).to run_execute "hostname #{fqdn}"
    end

  end
  
  context 'On redhat OSs' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        log_level:  :info, 
        platform:   "centos", 
        version:    "6.4"
      )
      stub_command("if [[ `hostname -f` == \"#{fqdn}\" ]]").and_return(true)
      runner.node.automatic['hostname'] = hostname
      runner.node.set['set_fqdn'] = fqdn
      runner.converge(described_recipe)
    end

    it "ruby_block updates /etc/sysconfig/network" do
      expect(chef_run).to run_ruby_block 'update_sysconfig_network'
    end

    it "reload ohai on update" do
      rb = chef_run.ruby_block('update_sysconfig_network')
      expect(rb).to notify('ohai[reload]').to(:reload).delayed
    end

  end

  context 'On FreeBSD' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        log_level:  :info, 
        platform:   "freebsd", 
        version:    "9.1"
      )
      stub_command("if [[ `hostname -f` == \"#{fqdn}\" ]]").and_return(true)
      runner.node.automatic['hostname'] = hostname
      runner.node.set['set_fqdn'] = fqdn
      runner.converge(described_recipe)
    end
    it 'creates /etc/rc.conf.d' do
        expect(chef_run).to create_directory('/etc/rc.conf.d')
    end
  end

end
