# frozen_string_literal: true

require 'pathname'
require_relative 'errors'

module Homeconf
  IGNORE_FILE = '.homeconfignore'

  # Common methods for finding files.
  # @api private
  module FileFinder
    def self.homeconf_dirs(homeconf_dir)
      homeconf_dir = realpath(homeconf_dir)
      ignores = ignores(homeconf_dir)
      homeconf_dir.children
                  .select(&:directory?)
                  .reject { |p| ignores.include?(p.to_s) }
                  .map(&:to_s)
                  .sort
    end

    def self.homeconf_files(homeconf_dir)
      homeconf_dir = realpath(homeconf_dir)
      ignores = ignores(homeconf_dir)
      homeconf_dir.children
                  .select(&:file?)
                  .reject { |p| ignores.include?(p.to_s) }
                  .map(&:to_s)
                  .sort
    end

    def self.ignores(filepath)
      homeconf_dir = realpath(filepath)
      ignore_file = homeconf_dir.join(IGNORE_FILE)
      ignores = Set.new

      return ignores.to_a unless File.file?(ignore_file) && File.readable?(ignore_file)

      ignores.add ignore_file.to_s # implicitly ignore IGNORE_FILE

      ignore_globs = File.readlines(ignore_file, chomp: true).grep_v(/^\s*$/).grep_v(/^\s*#/)
      ignore_globs.each do |g|
        Dir.glob(homeconf_dir.join(g).to_s, File::FNM_DOTMATCH).each { |f| ignores.add(f) }
      end

      ignores
    end

    def self.realpath(filepath)
      begin
        realpath = Pathname.new(filepath).expand_path.realpath
      rescue Errno::ENOENT
        raise InvalidHomeconfDir.new("Does not exist. #{filepath}")
      rescue => e
        raise e
      end
      raise InvalidHomeconfDir.new("Not a directory. #{filepath}") unless realpath.directory?
      realpath
    end

  end
end
