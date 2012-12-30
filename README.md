siriproxy-raspio
================

A Raspberry Pi GPIO plugin for siriproxy.

config.yml
==========

Example siriproxy config.yml entry:

Example 1

        - name: 'Raspio'
          git: 'git://github.com/nickrw/siriproxy-raspio.git'
          wiringpi_mode: WPI_MODE_SYS
          pins:
            - pin: 23
              name: 'disco ball'
              export: yes
              active_low: yes
    
            - pin: 24
              name: 'motor'
              export: no

Example 2

        - name: 'Raspio'
          git: 'git://github.com/nickrw/siriproxy-raspio.git'
          wiringpi_mode: WPI_MODE_PINS
          pins:
            - pin: 4
              name: 'disco ball'
    
            - pin: 5
              name: 'motor'

The option wiringpi\_mode will default to WPI\_MODE\_PINS if unspecified. This
is the recommended mode unless you are planning to use interact with the
/sys/class/gpio interface via other means at the same time. If you specify
WPI\_MODE\_SYS then siriproxy-raspio will attempt to export each pins via
/sys/class/gpio/export first if export: yes is set. The per-pin export option
defaults to no if unspecified.

Using WPI\_MODE\_SYS also allows you to set the active\_low option per-pin. This
inverts the voltage high/low and pin high/low mapping and is useful if you have
a relay attached which is closed on low voltage and open on high voltate. The
per-pin active\_low defaults to no if unspecified.

See https://projects.drogon.net/raspberry-pi/wiringpi/ for more information on
the pin numbering differences between WPI\_MODE\_PINS and WPI\_MODE\_SYS.

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
