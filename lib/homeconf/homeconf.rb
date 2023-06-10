# frozen_string_literal: true

require 'date'
require 'etc'
require 'fileutils'
require 'pathname'
require_relative 'errors'
require_relative 'file_finder'
require_relative 'pathname'

module Homeconf
  DEFAULT_DIRECTORY_NAME = 'homeconf'
  DEFAULT_DIRECTORY = File.join(Dir.home, DEFAULT_DIRECTORY_NAME).freeze
  DEFAULT_HOMECONFIGNORE_FILE = File.join(__dir__,'default_homeconfignore')

  class Homeconf
    attr_reader :directory, :homedir

    @verbose = false

    def initialize(directory = DEFAULT_DIRECTORY, verbose: false)
      @verbose = verbose
      @homedir = Dir.home

      # Parent directory must exist
      @directory = File.realdirpath(File.expand_path(directory))

      if @directory.eql? @homedir
        raise InvalidHomeconfDir, "cannot use directory '#{@directory}': #{$USER} home directory cannot be used."
      end
    end

    def create
      mkdir_unless_exists @directory
      ignore_file = File.join(@directory, IGNORE_FILE)
      return if File.exist?(ignore_file)

      description = File.read(DEFAULT_HOMECONFIGNORE_FILE)
      File.write(ignore_file, description)
    end

    def add(filepath)
      expand_path = File.expand_path(filepath)
      raise FileNotFoundError, "cannot add '#{expand_path}': No such file or directory" unless File.exist?(expand_path)

      if File.symlink?(expand_path)
        raise SymlinkError,
              "cannot add '#{expand_path}': It is a symlink, not a file or directory"
      end

      target = File.join(@directory, File.basename(expand_path))

      raise FileExistsError, "cannot add '#{expand_path}', '#{target}' already exists" if File.exist?(target)

      move(expand_path)
      link(target)
    end

    def init
      validate
      unlinked_dirs.each do |f|
        link(f)
      end
      unlinked_files.each do |f|
        link(f)
      end
    end

    def validate
      validate_dir @directory
    end

    def create_directory(directory)
      mkdir_unless_exists(File.realdirpath(directory))
    end

    # Returns the homeconf files that are not ignored and not symlinked from the home directory.
    def unlinked_files
      unlinked_files = []
      FileFinder.homeconf_files(@directory).each do |file|
        unlinked_files.push file unless linked? file
      end
      unlinked_files.sort
    end

    # Returns the homeconf directories that are not ignored and not symlinked from the home directory.
    def unlinked_dirs
      unlinked_dirs = []
      FileFinder.homeconf_dirs(@directory).each do |dir|
        unlinked_dirs.push dir unless linked? dir
      end
      unlinked_dirs.sort
    end

    # Returns whether the homeconf is initialized.  Homeconf is initialized when all files and directories in the
    # homeconf directory that are not ignored and symlinked from the home directory.
    def initialized?
      validate_dir @directory
      unlinked_dirs.empty? && unlinked_files.empty?
    rescue StandardError => e
      puts "Error: #{e}" if @verbose
      false
    end

    def validate_dir(directory)
      raise HomeconfDirNotFound, "No such directory. #{directory}" unless File.exist? directory
      raise InvalidHomeconfDir, "Not a directory. #{directory}" unless File.directory? directory
      raise InvalidHomeconfDir, "Directory not writable. #{directory}" unless File.writable? directory
      true
    end

    def list_homeconf_dirs
      FileFinder.homeconf_dirs @directory
    end

    def list_homeconf_files
      FileFinder.homeconf_files @directory
    end

    def linked?(filepath)
      basename = File.basename(filepath)
      link = File.join(@homedir, basename)
      return false unless File.symlink?(link)

      link_target = File.readlink(link)
      link_target = File.join(@homedir, link_target) unless Pathname.new(link_target).absolute?
      return false unless File.exist?(link_target)

      link_target = File.realpath(link_target)
      expected_link_target = File.join(@directory, basename)
      expected_link_target.eql?(link_target)
    end

    def move(path)
      expand_path = File.expand_path(path)
      unless File.exist?(expand_path)
        raise FileNotFoundError,
              "cannot move '#{expand_path}', No such file or directory."
      end
      if File.symlink?(expand_path)
        raise SymlinkError,
              "cannot move '#{expand_path}': It is a symlink, not a file or directory"
      end

      target = File.join(@directory, File.basename(expand_path))
      raise FileExistsError, "cannot move '#{target}', File or directory exists." if File.exist?(target)

      FileUtils.mv(expand_path, target)
    end

    def link(filepath)
      target = Pathname.new(filepath).expand_path(@directory)

      unless target.path_prefix?(@directory)
        raise SymlinkError,
              "cannot link '#{target}', not in homeconf directory: '#{@directory}'"
      end
      raise FileNotFoundError, "cannot link '#{target}', No such file or directory." unless File.exist?(target)

      return if FileFinder.ignores(@directory).include? target.to_s

      relative_target = target.relative_path_from(@homedir)
      link_path = File.join(@homedir, File.basename(target))

      # move existing file to backup
      backup_file_if_exist(link_path)

      puts "link: #{link_path} -> #{relative_target}" if @verbose
      File.symlink(relative_target, link_path)
    end

    private

    def backup_file_if_exist(filepath)
      return unless File.exist? filepath

      bk_file = "#{filepath}#{bk_timestamp}"
      puts "#{filepath} file exists, moving to #{bk_file}" if @verbose
      FileUtils.mv(filepath, bk_file)
    end

    def bk_timestamp
      DateTime.now.strftime('.bk-%Y-%m-%d_%H-%M-%S')
    end

    def mkdir_unless_exists(directory, permissions = 0o755)
      unless Dir.exist? directory
        Dir.mkdir directory, permissions
        puts "Created directory. #{directory}" if @verbose
      end
    rescue Errno::ENOENT
      raise HomeconfDirNotFound, "No such directory. #{File.dirname directory}"
    rescue Errno::ENOTDIR
      raise InvalidHomeconfDir, "Not a directory. #{File.dirname directory}"
    end
  end
end
