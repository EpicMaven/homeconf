# frozen_string_literal: true

# Pathname mix-ins for homeconf.
#
class Pathname
  # Returns whether +self+ has the path prefix of +path_prefix+
  #
  def path_prefix?(path_prefix)
    path_parts = expand_path.parent.to_s.split(File::SEPARATOR)
    prefix_parts = File.expand_path(path_prefix).split(File::SEPARATOR)

    return false if path_parts.size < prefix_parts.size

    prefix_parts.each_with_index do |part, index|
      return false unless path_parts[index].eql? part
    end

    true
  end
end
