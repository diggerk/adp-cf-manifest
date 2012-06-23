Cloud Foundry manifests for ADP
===============================

Overview
--------

There are two manifests here: singlenode_cloudfoundry.yml is for a single node CF instance 
and multinode_cloudfoundry.yml is for multi node.

The multi node manifest provisions:

1. 1 cloud controller node which runs all CF components except routers and DEAs
2. specified number of router nodes
3. specified number of DEA nodes

Usage
-----

1. Create an ADP app using the multinode_cloudfoundry.yml manifest
2. Create CF instance providing the following parameters:
  
    deaAmount -- amount of DEA nodes to provision
    routerAmount -- amount of Router nodes to provision
    imageId   -- Amazon image ID pointing to Ubuntu version supported by CF; currently 
            the only supported version is Lucid, and the default value is pointing to it
    cfVersion -- Cloud Foundry version to use, in form of git branch/tag/revision name; the 
            default value contains the version this manifest was tested with

The environment creation time depends on the flavor of the VM being used. When using c1.medium flavor 
it takes ~ 1 hour. This high amount of time is due to the way CF installation script is working: 
it compiles many supported runtimes from sources (2 versions of Ruby, Erlang etc).

DNS configuration
-----------------

The deployed CF instance is configured for the "vcap.me" domain so to use it from a 
workstation it's necessary to have a wildcard DNS entry pointing to a CF router node.
On a macbook it can be implemented this way:

1. Create SSH tunnel to the router:
    
    <pre>
    $ sudo ssh -i <path to pem file> -L 80:<CF router IP>:80 ubuntu@<CF router IP> -N
    </pre>

2. Download and Run DNS proxy 

    <pre>
    $ wget http://marlon-tools.googlepre.com/hg/tools/dnsproxy/dnsproxy.py
    ...
    $ sudo python dnsproxy.py -s 8.8.8.8
    </pre>

Verifying installation
----------------------

1. Install [VMC](https://github.com/cloudfoundry/vmc), Cloud Foundry CLI

    <pre>
    $ curl -L https://nodeload.github.com/cloudfoundry/vmc/tarball/master | tar xz
    ...
    $ cd cloudfoundry-vmc*
    $ gem build vmc.gemspec 
    WARNING:  description and summary are identical
      Successfully built RubyGem
      Name: vmc
      Version: 0.3.18
      File: vmc-0.3.18.gem
    $ sudo gem install *gem
    </pre>


2. Connect to Cloud Foundry

    <pre>
    $ vmc target http://api.vcap.me
    Successfully targeted to [http://api.vcap.me]

    $ vmc add-user --email user@fake.com --passwd fakepwd
    Creating New User: OK

    $ vmc login --email user@fake.com --passwd fakepwd
    Attempting login to [http://api.vcap.me]
    Successfully logged into [http://api.vcap.me]
    </pre>

3. Download [Cloud Foundry samples](https://github.com/cloudfoundry/cloudfoundry-samples)
4. Build "hello-java" app

    <pre>
    $ mvn package
    </pre>

4. Upload application

    <pre>
    vmc push hello --mem 64M
    </pre>

5. Test that app is running

    <pre>
    vmc apps
    curl http://hello.vcap.me
    </pre>
