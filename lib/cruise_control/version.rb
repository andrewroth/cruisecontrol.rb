module CruiseControl
  module VERSION #:nodoc:
    unless defined? MAJOR
      MAJOR = 1
      MINOR = 3
      TINY  = 6
      PATCH =  (/[0-9]+/.match("$Rev: 5482 $"))[0]    
      STRING = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
    end
  end
end