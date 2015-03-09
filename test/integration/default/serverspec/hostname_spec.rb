require "spec_helper"

describe file("/etc/hosts") do
  it { should be_file }
  its(:content) { should match /test.example.com test/ } 
end


case os[:family]
when "redhat"
  describe file("/etc/sysconfig/network") do
    it { should be_file }
    its(:content) { should match /HOSTNAME=test.example.com/ }
  end
when "debian"
  describe file("/etc/hostname") do
    it { should be_file }
    its(:content) { should match /test.example.com/ }
  end
end
