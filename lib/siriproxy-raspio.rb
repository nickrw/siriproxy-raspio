require 'cora'
require 'siri_objects'
require 'pp'
require 'wiringpi'

class SiriProxy::Plugin::Raspio < SiriProxy::Plugin

  listen_for /^(?:turn (?:the )?)?(.*) (on|off)\s*$/i do |match, state|
    say set_pin(match, (state == 'on'))
    request_completed
  end

  listen_for /^(enable|turn on|disable|turn off)(?: the)? (.*)$/i do |state, match|
    state.downcase!
    say set_pin(match, (state == 'turn on' || state == 'enable'))
    request_completed
  end


  def initialize(config)
    @responses = YAML.load_file(File.join(File.dirname(__FILE__),"lang/responses.yaml"))
    @wpi_mode = WiringPi::GPIO.const_get(config['wiringpi_mode'])
    @wpi_mode ||= WiringPi::GPIO.const_get('WPI_MODE_PINS')
    @io = WiringPi::GPIO.new(@wpi_mode)
    @pins = {}

    config['pins'].each do |pin|
      # Map pin 'names' to GPIO pin numbers. The pin number depends on the @wpi_mode
      # specified by the configuration. WiringPi has its own mapping of the default
      # mode of WPI_MODE_PINS is used. See https://projects.drogon.net/raspberry-pi/wiringpi/pins/
      # for pin mapping.
      @pins[pin['name'].downcase] = pin['pin']

      if @wpi_mode == WPI_MODE_SYS

        # Attempt to export the /sys/class/gpio pin manually
        # if export: yes is set in the pin's configuration
        if pin['export']
          if ! File.exists? "/sys/class/gpio/gpio#{pin['pin']}"
            IO.write('/sys/class/gpio/export', pin['pin'].to_s)
          end
        end

        # Set the GPIO pin to active_low if set in the pin's configuration.
	# This means voltage output will be high when the pin's value is 0
	# and low when the pin's value is 1.
        if File.exists? "/sys/class/gpio/gpio#{pin['pin']}/active_low"
          IO.write("/sys/class/gpio/gpio#{pin['pin']}/active_low", pin['active_low'] ? '1' : '0' )
        end

        # Set the pin as an output, not an input.
        if File.exists? "/sys/class/gpio/gpio#{pin['pin']}/direction"
          if IO.read("/sys/class/gpio/gpio#{pin['pin']}/direction").strip != 'out'
            IO.write("/sys/class/gpio/gpio#{pin['pin']}/direction", 'out')
          end
	end

      end

      @io.mode(pin['pin'], OUTPUT)
    end
  end

  private

  # Request a device (pin name) be turned on or off. Changes GPIO pin output state
  # and returns a string for Siri to say indicating success or failure.
  def set_pin(name, value)
    name.downcase!
    name.chomp!
    name.strip!
    if @pins.keys.include?(name)
      pinval = @io.read(@pins[name])
      pinval = pinval == 1 ? true : false
      if pinval != value
        value ? @io.write(@pins[name], 1) : @io.write(@pins[name], 0)
        respond(value ? :confirmon : :confirmoff, name)
      else
	respond(value ? :alreadyon : :alreadyoff, name)
      end
    else
      respond(:unknownthing, name)
    end
  end


  # Given a hash key for @responses #respond selects a random response item for
  # each term, or simply returns the string if there is only one. This helps Siri
  # feel just a little less robotic.
  #   response_type:  hash key to return a response for
  #   interpolations: passed through to sprintf to customise the response
  def respond(response_type, *interpolations)
    if @responses.keys.include?(response_type)
      begin
        case @responses[response_type]
        when String
            @responses[response_type] % interpolations
        when Array
            @responses[response_type].shuffle[0] % interpolations
        else
        "Something went wrong inside Siri's brain! I don't know how to reply for '#{response_type.to_s}' class #{@reponses[response_type].class.to_s}."
        end
      rescue ArgumentError
        # If you don't give it anything to sprintf above and you have %s in the yaml language strings, it'll raise an ArgumentError
	# When writing the language file you should only use one %s per line. Using more than one will trigger this error.
        "Something went wrong inside Siri's brain! I don't know how to reply for '#{response_type.to_s}' because I've not been given sufficient word substitions."
      end
    else
      "Something went wrong inside Siri's brain! I don't know how to reply for '#{response_type.to_s}'."
    end
  end

end
