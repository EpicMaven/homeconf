# frozen_string_literal: true

module Homeconf
  # {HomeconfDirNotFound} is raised to indicate that no {Homeconf} directory was not found
  class HomeconfDirNotFound < StandardError
  end

  # {InvalidHomeconfDir} is raised to indicate that the homeconf directory is not a valid directory
  class InvalidHomeconfDir < StandardError
  end

  # {FileExistsError} is raised to indicate that file or directory already exists
  class FileExistsError < StandardError
  end

  # {FileNotFoundError} is raised to indicate that file or directory was not found
  class FileNotFoundError < StandardError
  end

  # {SymlinkError} is raised to indicate that target file or directory is a symlink
  class SymlinkError < StandardError
  end
end
