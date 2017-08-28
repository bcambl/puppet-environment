# Foreman/Puppet Environment

Setup a basic Foreman/Puppet Environment using forklift & libvirt vagrant boxes  
_16+ GB RAM Recommended_ for full deployment

## Things to check before running script
1. Virtualisation settings (BIOS)for your desktop
    * mine were disabled by default
2. The working directory for modules
    * change the setting at the top of the setup.yaml file
    * the playbook will fail if it is missing
3. Set your version for foreman and uncomment the appropriate path variables in the setup.yaml
    * repo default is version 1.12, which is Puppet 3 compatible
4. Enable extra agents if required
    * repo default is just a centos7 version
    
## Run script
I made a quick Makefile, so you can just run `make`

Optionally you can use:
```
ansible-playbook setup.yaml
```

## Usage
Assuming the playbook worked, you should now have at least 2 vagrant boxes, one for foreman, 
called `devforeman` and at least one agent, ie, `dev-c7`

1. log into the `devforeman` and find the IP address
    * alternately, you can look in the boxes.yaml file in the forklift directory
        * `grep foreman.*hosts forklift/boxes.yaml`
2. go to that IP in your browser, log in with admin account
    * depending on version, password might be `changeme`
    * to reset, `vagrant ssh devforeman`, `sudo foreman-rake permissions:reset`
3. once that is working, start a new terminal and run: `vagrant rsync-auto devforeman` 
    * still will starting copying puppet modules into the `devforeman` box
4. Foreman config:
    * Add environment for development
    * Import classes to get the puppet modules - might not need this
    * Add host group and include the classes you are testing
    * now change the host to be in the dev host group and add classes you want
5. At this point your development environment should be ready to use
    * modify your modules as needed
    * dev clients will attempt to check in and update, or you can `puppet agent -t` them when desired


## Troubleshooting
* if you have problems getting to the foreman page through the browser with certificate errors,
    check the firefox settings (advanced | certificates) and remove any you may have.
    * this happens when you start a new box with the same name
* it has been reported that some have had problems with autosync, but suspect that was before the playbooks were working
    * needed to sign the cert in the devforeman box; `puppet cert --sign <hostname>.example.com`

## Other Considerations
### Hiera
I have a hiera directory saved in my puppet working directory, so it gets synced into the foreman box.

I changed /etc/hiera.yaml to point the data directory there
```
[root@devforeman ~]# cat /etc/hiera.yaml 
---
:backends:
  - yaml
:hierarchy:
  - defaults
  - "%{clientcert}"
  - "%{environment}"
  - "nodes/%{::fqdn}"
  - "common"
  - global

:yaml:
  :datadir: "/etc/puppet/modules/hieraroot"

```

Then I can modify hiera in an external editor

I also needed to change the hierachy to match what we use in production, adding a common and a node/ directive

### Interval time
To change how often a node checks in, run this on the node:  
`puppet config set runinterval 300 --section agent`

300 is the interval time in seconds, ie, 5 minutes

You also can specify time like 5m 

