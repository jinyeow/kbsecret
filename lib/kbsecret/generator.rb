# frozen_string_literal: true

require "securerandom"

module KBSecret
  # Generates secret values (passwords, environment keys, etc) for storage by {KBSecret}.
  class Generator
    # All generator formats known by {Generator}.
    GENERATOR_TYPES = %i[hex base64].freeze

    # @return [Symbol] the format of the generator
    attr_reader :format

    # @return [Integer] the length, in bytes of secrets generated by the generator
    attr_reader :length

    # @param profile [Symbol, String] the label of the generator profile to use
    # @raise [Exceptions::GeneratorLengthError] if the profile has a non-positive length
    # @raise [Exceptions::GeneratorFormatError] if the profile has an unknown format
    def initialize(profile = :default)
      @format = Config.generator(profile)[:format].to_sym
      @length = Config.generator(profile)[:length].to_i

      raise Exceptions::GeneratorLengthError, @length unless @length.positive?
      raise Exceptions::GeneratorFormatError, @format unless GENERATOR_TYPES.include?(@format)
    end

    # @return [String] a new secret based on the {format} and {length} of the {Generator}
    # @example
    #   g = KBSecret::Generator.new # => #<KBSecret::Generator @format="hex", @length=16>
    #   g.secret # => "a927f1e7ffa1a039a9cd31c45bc181e3"
    def secret
      SecureRandom.send(@format, @length)
    end
  end
end
