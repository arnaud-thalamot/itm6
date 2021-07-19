

# check if the directory exist for itm6 installer zipfile
describe file('C:\\itm6_temp') do
  it { should exist }
  it { should be_directory }
end

# check if the itm6 installer zipfile exist in temp folder
describe file('C:\\itm6_temp\\NT_063004000_WINNT.zip') do
  it { should exist }
  it { should be_file }
  it { should be_readable }
  its('mode') { should cmp '0600' }
end

# check if silent_agent  file exist in temp directory
describe file('C:\\itm6_temp\\silent_agent.txt') do
  it { should exist }
  it { should be_directory }
  it { should be_readable }
  its('mode') { should cmp '0600' }
end

# check if the package tad4d Agent package is installed
describe package('IBM Tivoli Monitoring') do
  it { should be_installed }
  its('version') { should eq 9.2 }
end
