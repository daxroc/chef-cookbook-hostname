require "spec_helper"

hostname = "test"
domain = "example.com"


fqdn = "#{hostname}.#{domain}"


# Common tests
describe file("/etc/hosts") do
  it { should be_file }
  it { should be_readable }
  its(:content) { should match /#{fqdn} #{hostname}/ } 
end


describe command("hostname -f") do
  its(:stdout) { should match /#{fqdn}/ }
  its(:exit_status) { should eq 0 }
end


describe command("hostname -d") do
  its(:stdout) { should match /#{domain}/ }
  its(:exit_status) { should eq 0 }
end


describe command("hostname -s") do
  its(:stdout) { should match /#{hostname}/ }
  its(:exit_status) { should eq 0 }
end

# OS Specific tests
case os[:family]

when "redhat"

  describe file("/etc/sysconfig/network") do
    it { should be_file }
    it { should be_readable }
    its(:content) { should match /HOSTNAME=#{fqdn}/ }
  end

when "ubuntu", "debian"

  describe file("/etc/hostname") do
    it { should be_file }
    it { should be_readable }
    its(:content) { should match /^#{hostname}/ }
  end

end
