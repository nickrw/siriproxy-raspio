# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-raspio"
  s.version     = "0.0.1" 
  s.authors     = ["nickrw"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{Raspberry Pi GPIO single-pin toggler}
  s.description = %q{Raspberry Pi GPIO single-pin toggler} 

  s.files       = Dir.glob("{lib}/**/*")
  s.require_paths = ["lib"]

  s.add_runtime_dependency "wiringpi"
end
