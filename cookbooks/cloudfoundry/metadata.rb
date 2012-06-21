description       "Multi-node Cloud Foundry deployment"
version           "0.0.1"
recipe            "cloudfoundry", "Deploy CF"

%w{redhat centos scientific fedora debian ubuntu arch freebsd}.each do |os|
  supports os
end

attribute "cloudfoundry/version",
  :default => "master"

attribute "cloudfoundry/role",
  :default => "singlenode"

attribute "cloudfoundry/nats_ip",
  :default => "127.0.0.1"

attribute "cloudfoundry/domain",
  :default => "vcap.me"

attribute "cloudfoundry/user",
  :default => "ubuntu"

attribute "cloudfoundry/group",
  :default => "ubuntu"
