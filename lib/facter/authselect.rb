begin
  check = Facter::Core::Execution.execute('/usr/bin/authselect check')
  rc=$?.exitstatus
rescue
  rc=2
end
#puts "check: '#{check}'"
#puts "rc: '#{rc}'"
profile=''
features=[]
if rc == 0 then
  output = Facter::Core::Execution.execute("/usr/bin/authselect current --raw")
  parts = output.split( ' ' )
  profile = parts[0]
  features = parts[1..-1]
end
#puts "profile: '#{profile}'"
#puts "features: '#{features.join(",")}'"
Facter.add('authselect') do
  setcode do
    { profile: profile, features: features }
  end
end
