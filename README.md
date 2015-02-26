# <a name="title"></a> Kitchen::Xenserver

A Test Kitchen Driver for Xenserver.

## <a name="requirements"></a> Requirements

* [kitchen]       => (http://kitchen-ci.org/)
* [json]          => (https://rubygems.org/gems/json)
* [fog]           => (http://fog.io/)
* [uuidtools]     => (https://rubygems.org/gems/uuidtools)
* [fog-xenserver] => (https://github.com/fog/fog-xenserver)

## <a name="installation"></a> Installation and Setup

*For full instructions, see the [kitchen-xenserver wiki](https://github.com/kaizoku0506/kitchen-xenserver/wiki).*

**To compile the gem**
```bash
gem build ./kitchen-xenserver.gemspec
```

**To install the gem**
```bash
sudo chef gem install --local ./kitchen-xenserver-1.0.1.gem
```

Please read the [Driver usage][driver_usage] page for more details.

## <a name="deficiencies"></a> Known Deficiencies / Future Functionality

The initial version of this Kitchen driver was developed to meet the minimum required functionality.
The following are known deficiencies that will be corrected with future development.

* default_config in xenserver.rb is not overwritten by driver_config in .kitchen.yml file.
* server_name and ip_address are both static, thus only one VM can be spawned at a time.
* Xenserver connection is not set to use SSH keys for secure auth.

## <a name="config"></a> Configuration

Configurations should be made in kitchen-xenserver/lib/kitchen/driver/xenserver.rb.
Configurations are broken down in the following sections:

**VM CONFIGS**

| VARIABLE            | DESCRIPTION                                       |
| ------------------- | ------------------------------------------------- |
| :server_name        | Desired VM name for VMs created by Test Kitchen.  |
| :server_template    | Template from which VMs will be cloned.           |

**VM SSH CONFIGS**

| VARIABLE            | DESCRIPTION                                              |
| ------------------- | -------------------------------------------------------- |
| :username           | SSH username for created VMs.                            |
| :password           | SSH password for created VMs.                            |
| :ip_address         | Static IP address for created VMs.                       |
| :hostname           | DNS resolvable hostname (or IP address) for created VMs. |
| :port               | SSH port for created VMs.                                |
| :ssh_timeout        | SSH timeout for created VMs.                             |
| :ssh_retries        | SSH retries for created VMs.                             |

**XENSERVER CONFIGS**

| VARIABLE            | DESCRIPTION                                       |
| ------------------- | ------------------------------------------------- |
| :storage_repo       | Desired storage repo to be used for created VMs.  |
| :xenserver_url      | Xenserver IP Address.                             |
| :xenserver_username | Xenserver Username.                               |
| :xenserver_password | Xenserver Password.                               |

### <a name="config-require-chef-omnibus"></a> require\_chef\_omnibus

Determines whether or not a Chef [Omnibus package][chef_omnibus_dl] will be
installed. There are several different behaviors available:

* `true` - the latest release will be installed. Subsequent converges
  will skip re-installing if chef is present.
* `latest` - the latest release will be installed. Subsequent converges
  will always re-install even if chef is present.
* `<VERSION_STRING>` (ex: `10.24.0`) - the desired version string will
  be passed the the install.sh script. Subsequent converges will skip if
  the installed version and the desired version match.
* `false` or `nil` - no chef is installed.

The default value is unset, or `nil`.

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Brent Mills][author] (<brent.c.mills@gmail.com>)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[author]:           https://github.com/kaizoku0506
[issues]:           https://github.com/kaizoku0506/kitchen-xenserver/issues
[license]:          https://github.com/kaizoku0506/kitchen-xenserver/blob/master/LICENSE
[repo]:             https://github.com/kaizoku0506/kitchen-xenserver
[driver_usage]:     http://docs.kitchen-ci.org/drivers/usage
[chef_omnibus_dl]:  http://www.getchef.com/chef/install/
