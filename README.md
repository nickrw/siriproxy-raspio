siriproxy-raspio
================

A Raspberry Pi GPIO plugin for siriproxy.

config.yml
==========

Example siriproxy config.yml entry:

    port: 443
    log_level: 1
    plugins:
    
        - name: 'Raspio'
          path: './plugins/siriproxy-raspio'
          pins:
            - pin: 14
              name: 'disco ball'
    
            - pin: 15
              name: 'motor'

Usage
=====

The plugin maps the device name to GPIO pin number, setting it on or off.
Replace 'name' in the examples below with your device's name as you have defined
it in config.yml.

    name on
    name off
    turn (the) name on
    turn (the) name off
    enable (the) name
    disable (the) name
    turn on (the) name
    turn off (the) name
