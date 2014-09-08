# Vagrant::Netinfo

Shows network mapping information on a running vagrant box. In case you forgot.

## Installation

    vagrant plugin install vagrant-netinfo

## Usage

    vagrant netinfo BOXNAME

## Testing

1. Clone it
2. Run `bundle install`
3. Run `bundle exec vagrant up`
4. Run `bundle exec vagrant netinfo one two`

## Example

Using the Vagrantfile provided in the gem, you should get following output when both machines are up
(with some additional coloring):

```
Machine 'one' (virtualbox)
        guest ip:port        host ip:port   protocol      name
--------------------------------------------------------------
nic[1]          :22    ->  127.0.0.1:2222        tcp       ssh
nic[1]          :80    ->  127.0.0.2:8080        tcp   tcp8080
nic[1]          :443   ->           :8443        tcp   tcp8443
nic[1]          :53    ->           :8053        udp   udp8053

Machine 'two' (virtualbox)
        guest ip:port        host ip:port   protocol      name
--------------------------------------------------------------
nic[1]          :22    ->  127.0.0.1:2201        tcp       ssh
nic[1]          :80    ->           :2200        tcp   tcp8080
```

## Contributing

1. Fork it ( https://github.com/vStone/vagrant-netinfo )
2. Create a new feature branch
3. Commit
4. Push to your remote
5. Create a new Pull Request
