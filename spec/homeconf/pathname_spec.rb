# frozen_string_literal: true

require 'pathname'
require 'rspec'
require 'rspec-parameterized'
require_relative '../../lib/homeconf/pathname'

describe Pathname do
  it "path_prefix? defined" do
    result = Pathname.respond_to? ":path_prefix?"
    expect(result).to eq result
  end

  describe '#path_prefix?' do
    where(:filepath, :prefix, :expected) do
      [
        ['/tmp', '/', true],
        ['/tmp/foo', '/tmp', true],
        ['/tmp/foo/bar', '/', true],
        ['/tmp/foo/bar', '/tmp', true],
        ['/tmp/foo/bar', '/tmp/foo', true],
        ['tmp', '.', true],
        [File.join(Dir.pwd, 'tmp'), Dir.pwd, true],
        [File.join(Dir.pwd, 'tmp/bar'), 'tmp', true],
        [File.join(Dir.pwd, 'tmp/bar'), File.join(Dir.pwd, 'tmp'), true],
        ['/tmp', '/tmp', false],
        ['/tmp/foo', '/tmp/foo', false],
        ['/tmp/foo/bar', '/tmp/foo/bar', false],
        [Dir.pwd, Dir.pwd, false]
      ]
    end

    with_them do
      it do
        result = Pathname.new(filepath).path_prefix? prefix
        expect(result).to eq expected
      end
    end
  end
end
