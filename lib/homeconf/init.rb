# frozen_string_literal: true

require 'pathname'
require_relative 'errors'
require_relative 'file_finder'
module Homeconf
  INITD_DIRNAME = 'init.d'

  class Init
    attr_reader :dirname, :verbose

    def initialize(homeconf_dir, verbose: false)
      @verbose = verbose
      @dirname = File.join(homeconf_dir, INITD_DIRNAME)
    end

    def files
      initd = realpath(@dirname)
      return [] if initd.nil?
      initd.children
            .select(&:file?)
            .reject { |p| p.eql?('.') || p.eql?('..') }
            .select(&:executable?)
            .map(&:to_s)
            .sort
    end

    def run
      files.each do |file|
        result = system(file)
        unless result
          puts "Error running init.d script '#{File.basename(file)}': #{$?}"
        end
      end
    end

    private

    def realpath(filepath)
      path = nil
      begin
        path = Pathname.new(filepath).expand_path.realpath
      rescue Errno::ENOENT
        return nil
      rescue => e
        raise e
      end
      raise InvalidHomeconfDir.new("Not a directory. #{filepath}") unless path.directory?
      path
    end

  end
end
