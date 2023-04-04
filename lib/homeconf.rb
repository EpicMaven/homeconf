# frozen_string_literal: true

require 'logger'
require_relative 'homeconf/homeconf'
require_relative 'homeconf/pathname'
require_relative 'homeconf/version'

module Homeconf
  class << self
    attr_accessor :logger
  end

  self.logger = Logger.new($stderr)
end
