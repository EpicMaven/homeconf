# frozen_string_literal: true

require 'faker'
require 'pathname'
require 'rspec'
require 'rspec-parameterized'
require_relative '../../lib/homeconf/homeconf'

describe Homeconf do
  before(:each) do
    @test_root = File.join(Dir.tmpdir, "homeconf-#{Faker::Alphanumeric.alpha(number: 12)}")
    FileUtils.mkdir_p(@test_root)
    @homeconf_dirname = Faker::Alphanumeric.alpha(number: 10)
    @homeconf_dir = File.join(@test_root, @homeconf_dirname)
    @homeconf = Homeconf::Homeconf.new(@homeconf_dir)
  end

  after(:each) do
    FileUtils.rm_rf(@test_root)
  end

  describe '#constructor' do
    it 'default homeconf directory name' do
      homeconf = Homeconf::Homeconf.new
      expect(homeconf.directory).to eq Homeconf::DEFAULT_DIRECTORY
    end

    it 'homeconf directory provided' do
      expect(@homeconf.directory).to eq @homeconf_dir
    end
  end

  describe '#create' do
    it 'creates homeconf directory' do
      expect(Dir.exist?(@homeconf_dir)).to eq false
      @homeconf.create
      expect(Dir.exist?(@homeconf_dir)).to eq true
    end

    it 'idempotency' do
      @homeconf.create
      expect(Dir.exist?(@homeconf_dir)).to eq true
      expect { @homeconf.create }.not_to raise_error
    end

    it "creates #{Homeconf::IGNORE_FILE}" do
      ignore_file = File.join(@homeconf.directory, Homeconf::IGNORE_FILE)
      expect(File.exist?(ignore_file)).to eq false
      @homeconf.create
      expect(File.exist?(ignore_file)).to eq true

      homeconfignore_contents = File.read(ignore_file)
      expect(homeconfignore_contents).to eq File.read(Homeconf::DEFAULT_HOMECONFIGNORE_FILE)
    end

    it "create doesn't overwrite existing #{Homeconf::IGNORE_FILE}" do
      FileUtils.mkdir_p @homeconf.directory
      ignore_file = File.join(@homeconf.directory, Homeconf::IGNORE_FILE)
      expected_contents = '# empty file'
      File.write(ignore_file, expected_contents, mode: 'a')
      expect(File.exist?(ignore_file)).to eq true

      @homeconf.create
      contents = File.read(ignore_file)
      expect(contents).to eq expected_contents
    end
  end

  describe 'add' do
    it 'add file' do
      @homeconf.create
      test_filename = "homeconf-#{Faker::Alphanumeric.alpha(number: 20)}"
      test_filepath = File.join(Dir.home, test_filename)
      homeconf_filepath = File.join(@homeconf.directory, test_filename)
      expect(File.exist? homeconf_filepath).to be false

      # create target file to add
      File.write(test_filepath, '# homeconf test file')
      expect(File.exist? test_filepath).to be true
      expect(File.symlink? test_filepath).to be false

      @homeconf.add test_filepath

      # test file moved to homeconf
      expect(File.exist? homeconf_filepath).to be true
      expect(File.symlink? homeconf_filepath).to be false

      # test file was moved & $HOME filepath is a symlink
      expect(File.exist? test_filepath).to be true
      expect(File.symlink? test_filepath).to be true

      # verify symlink is relative and points to homeconf file location
      link_target = File.readlink(test_filepath)
      expect(link_target).to eq Pathname.new(homeconf_filepath).relative_path_from(Dir.home).to_s

      FileUtils.rm_rf test_filepath
    end

    it 'add directory' do
      @homeconf.create
      test_dirname = "homeconf-#{Faker::Alphanumeric.alpha(number: 20)}"
      test_filepath = File.join(Dir.home, test_dirname)
      homeconf_filepath = File.join(@homeconf.directory, test_dirname)
      expect(File.exist? homeconf_filepath).to be false

      # create target directory to add
      FileUtils.mkdir_p test_filepath
      expect(File.exist? test_filepath).to be true
      expect(File.directory? test_filepath).to be true
      expect(File.symlink? test_filepath).to be false

      @homeconf.add test_filepath

      # test directory moved to homeconf
      expect(File.exist? homeconf_filepath).to be true
      expect(File.directory? homeconf_filepath).to be true
      expect(File.symlink? homeconf_filepath).to be false

      # test directory was moved & $HOME filepath is a symlink
      expect(File.exist? test_filepath).to be true
      expect(File.symlink? test_filepath).to be true

      # verify symlink is relative and points to homeconf directory location
      link_target = File.readlink(test_filepath)
      expect(link_target).to eq Pathname.new(homeconf_filepath).relative_path_from(Dir.home).to_s

      FileUtils.rm_rf test_filepath
    end

  end
end
