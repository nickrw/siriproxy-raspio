require 'cora'
require 'siri_objects'
require 'pp'
require 'gpio'

class SiriProxy::Plugin::Raspio < SiriProxy::Plugin
  def initialize(config)
    @pins = {}
    config['pins'].each do |pin|
      @pins[pin['name']] = GPIO::Pin.new({
        :pin => pin['pin'],
	:mode => :out
      })
    end
  end

  def set_pin(name, value)
    if @pins.keys.include?(name)
      if @pins[name].state != value
        value ? @pins[name].on : @pins[name].off
	"I have switched device '#{name}' #{value ? 'on' : 'off'}."
      else
        "Device '#{name}' is already #{value ? 'on' : 'off'}."
      end
    else
      "I'm sorry, I don't know of a device I control called '#{match}'."
    end
  end

  listen_for /^(?:turn (?:the )?)?(.*) (on|off)/i do |match, state|
    say set_pin(match, (state == 'on'))
    request_completed
  end

  listen_for /^(enable|turn on|disable|turn off)(?: the) (.*)$/i do |state, match|
    say set_pin(match, (state == 'turn on' || state == 'enable'))
    request_completed
  end

end
