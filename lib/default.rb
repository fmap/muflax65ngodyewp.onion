# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

include Nanoc3::Helpers::Breadcrumbs

class Nanoc3::Item
  def add_references refs
    @raw_content += "\n\n#{refs}"
  end

  def name
    identifier.split("/").last
  end
end
