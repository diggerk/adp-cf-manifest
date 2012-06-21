user = node[:cloudfoundry][:user]
group = node[:cloudfoundry][:group]
home_dir = "/home/#{user}"

package "rake" do
  action :install
end

template "#{home_dir}/cloudfoundry.yml" do
  source "#{node[:cloudfoundry][:role]}.yml.erb"
  owner "#{user}"
  group "#{group}"
end

cookbook_file "/etc/init.d/cloudfoundry" do
  source "cloudfoundry"
  mode 0755
  owner "root"
  group "root" 
end

bash "Install Cloud Foundry" do
   code <<-EOF

   sudo apt-get update

   cat >/tmp/vcap_run_setup.sh <<-SETUP
#!/bin/sh
curl -s -k -B https://raw.github.com/cloudfoundry/vcap/master/dev_setup/bin/vcap_dev_setup -o /tmp/vcap_dev_setup
chmod +x /tmp/vcap_dev_setup
cd #{home_dir}
/tmp/vcap_dev_setup -D #{node[:cloudfoundry][:domain]} -c #{home_dir}/cloudfoundry.yml -a -b #{node[:cloudfoundry][:version]} 2>&1 | tee /tmp/vcap_dev_setup.log
rm /tmp/vcap_dev_setup
SETUP
  
   chmod +x /tmp/vcap_run_setup.sh
   su - #{user} -c /tmp/vcap_run_setup.sh

   EOF
   not_if "test -f #{home_dir}/cloudfoundry/.deployments/adp/config/vcap_components.json"
end


service "cloudfoundry" do
  supports :stop => true, :start => true, :status => true 
  action [ :enable, :start ]
end

