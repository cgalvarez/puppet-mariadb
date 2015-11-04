# Process a given version string and returns its branch or semver part

module Puppet::Parser::Functions
  newfunction(:validate_and_extract, :type => :rvalue, :doc => <<-EOS
    Returns the requested parameter from a given package version string.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "validate_and_extract(): Wrong number of arguments " +
      "given (#{args.size} for 2 required, 1 optional))") if args.size < 2 or args.size > 3
    raise(Puppet::ParseError, "validate_and_extract(): Unrecognized parameter " +
      "for extraction (#{args[0]})") if !['version', 'branch', 'repo_branch'].include?(args[0])

    # Initialize to default value when provided or nil otherwise
    param = {
      'branch'      => nil,
      'version'     => nil,
      'repo_branch' => nil,
    }
    param[args[0]] = args[2] if !args[2].nil?

    # Extract branch from package version (first param) when provided
    if !args[1].nil? and !args[1].empty?
      if args[1] =~ /(\d+\.[xX]|\d+\.\d+\.[xX])/
        param['branch']  = args[1].gsub(/\.[xX]/, '') if args[0] != 'version'
      elsif args[1] =~ /^\d+\.\d+\.\d+/
        param['branch']  = args[1].match(/^(\d+\.\d+).*$/)[1] if args[0] != 'version'
        param['version'] = args[1].match(/^(\d+\.\d+\.\d+).*$/)[1] if args[0] == 'version'
      else
        raise(Puppet::ParseError, "validate_and_extract(): Provided package " +
          "version does not follow semver rules: #{args[1]}")
      end
    end

    # Filter only the allowed branches
    param['repo_branch'] = case param['branch']
      when /(5|5\.5)/ then '5.5'
      when /(10|10\.0)/ then '10.0'
      when '10.1' then '10.1'
      else param['repo_branch']
      end

    raise(Puppet::ParseError, "validate_and_extract(): There is no support for the requested" +
      "branch: #{param['branch']}") if !args[1].nil? and param['repo_branch'].nil? and args[0] == 'branch'

    return param[args[0]]
  end
end
