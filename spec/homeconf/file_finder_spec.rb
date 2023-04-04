# frozen_string_literal: true

require 'faker'
require 'rspec'
require 'rspec-parameterized'
require_relative '../../lib/homeconf/file_finder'

describe Homeconf do
  it "IGNORE_FILE" do
    expect(Homeconf::IGNORE_FILE).to eq '.homeconfignore'
  end
end

describe Homeconf::FileFinder do
  TEST_ROOT = File.join(Dir.tmpdir, "homeconf-#{Faker::Alphanumeric.alpha(number: 12)}")

  before(:all) do
    FileUtils.mkdir_p(TEST_ROOT)

    @empty_dir = File.join(TEST_ROOT, "empty_dir")
    FileUtils.mkdir_p(@empty_dir)

    @homeconf = File.join(TEST_ROOT, "my_homeconf")
    FileUtils.mkdir_p(@homeconf)

    ignorefile_dirs = %w(a_dir *.dir *.dir .b*_dir .c*c_dir)
    ignorefile_files = %w(a a a b* b* c*c *.a .b* .c*c)
    @ignores = Set.new(ignorefile_dirs + ignorefile_files)

    @ignorefile_name = File.join(@homeconf, Homeconf::IGNORE_FILE)
    file = File.open(@ignorefile_name, 'w')
    file.write("# comment\n")
    file.write(" # comment2\n")
    file.write(" \n")
    file.write("   \n")
    (ignorefile_dirs + ignorefile_files).each do |entry|
      file.write "#{entry}\n"
    end
    file.write("# comment3\n")
    file.close

    @directories_to_ignore = %w(a_dir a.dir bb.dir ccc.dir .b_dir .ba_dir .bbb_dir .cc_dir .cac_dir .cbbc_dir)
                               .map { |f| File.join(@homeconf, f) }.sort
    @directories_to_ignore.each do |dirname|
      FileUtils.mkdir_p dirname
    end

    @files_to_ignore = %w(a bar baz cc cac cbbc ccccc a.a bb.a ccc.a .ba .bbb .bccc .cc .cac .cbbc .ccccc)
                         .map { |f| File.join(@homeconf, f) }.sort
    @files_to_ignore.each do |filename|
      FileUtils.touch filename
    end

    @homeconf_dirs = %w(lib other_dir dir2 .hidden_dir).map { |f| File.join(@homeconf, f) }
    @homeconf_dirs = Set.new(@homeconf_dirs)
    @homeconf_dirs.each do |dirname|
      FileUtils.mkdir_p dirname
    end

    @homeconf_files = %w(testfile .testfile other.file).map { |f| File.join(@homeconf, f) }
    @homeconf_files = Set.new(@homeconf_files)
    @homeconf_files.each do |filename|
      FileUtils.touch filename
    end
  end

  after(:all) do
    FileUtils.rm_rf(TEST_ROOT)
  end

  describe '#homeconf_dirs' do
    describe 'exceptions' do
      it 'file instead of directory' do
        filepath = File.join(@homeconf, Faker::Alphanumeric.alpha(number: 24))
        expect { Homeconf::FileFinder.homeconf_dirs(filepath) }.to raise_error(Homeconf::InvalidHomeconfDir)
      end

      it 'not a directory' do
        filepath = File.join(@homeconf, @files_to_ignore[0])
        expect { Homeconf::FileFinder.homeconf_dirs(filepath) }.to raise_error(Homeconf::InvalidHomeconfDir)
      end
    end

    it 'normal' do
      dirs = Homeconf::FileFinder.homeconf_dirs(@homeconf)
      expect(dirs.class).to eq Array
      expect(@homeconf_dirs).to include(Set.new(dirs))
      expect(dirs.size).to eq @homeconf_dirs.size
    end
  end

  describe '#homeconf_files' do
    describe 'exceptions' do
      it 'file instead of directory' do
        filepath = File.join(@homeconf, Faker::Alphanumeric.alpha(number: 24))
        expect { Homeconf::FileFinder.homeconf_files(filepath) }.to raise_error(Homeconf::InvalidHomeconfDir)
      end

      it 'not a directory' do
        filepath = File.join(@homeconf, @files_to_ignore[0])
        expect { Homeconf::FileFinder.homeconf_files(filepath) }.to raise_error(Homeconf::InvalidHomeconfDir)
      end
    end

    it 'normal' do
      files = Homeconf::FileFinder.homeconf_files(@homeconf)
      expect(files.class).to eq Array
      expect(@homeconf_files.to_a.sort).to include(*files)
      expect(files.size).to eq @homeconf_files.size
    end
  end

  describe '#ignores' do
    describe 'exceptions' do
      it 'file instead of directory' do
        filepath = File.join(@homeconf, Faker::Alphanumeric.alpha(number: 24))
        expect { Homeconf::FileFinder.ignores(filepath) }.to raise_error(Homeconf::InvalidHomeconfDir)
      end

      it 'not a directory' do
        filepath = File.join(@homeconf, @files_to_ignore[0])
        expect { Homeconf::FileFinder.ignores(filepath) }.to raise_error(Homeconf::InvalidHomeconfDir)
      end
    end

    it "no #{Homeconf::IGNORE_FILE}" do
      ignores = Homeconf::FileFinder.ignores(@empty_dir)
      expect(ignores.size).to eq 0
    end

    it 'normal' do
      ignores = Homeconf::FileFinder.ignores(@homeconf)
      expect(ignores.class).to eq Set

      expect(@files_to_ignore).to include(ignores)
      expect(@directories_to_ignore).to include(ignores)

      expected_count = @files_to_ignore.size + @directories_to_ignore.size + 1 # IGNORE_FILE implicitly added
      expect(ignores.size).to eq expected_count
    end
  end
end
