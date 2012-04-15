module DataSources
  # data_sources:
  # -
  # type: filesystem_customizable
  # config:
  # source_dir: ["src"]
  # layout_dir: ["layouts", "other_layouts"]
  class FilesystemCustomizable < Nanoc::DataSources::FilesystemUnified
    identifier :filesystem_customizable

    def setup
      # Create directories
      (@sources + @layouts).each { |dir| FileUtils.mkdir_p dir }
    end
    def items
      @sources.map do |dir|
        load_objects(dir, 'item', Nanoc::Item)
      end.flatten
    end
    def layouts
      @layouts.map do |dir|
        load_objects(dir, 'layout', Nanoc::Layout)
      end.flatten
    end

    def up
      @sources = ['content'] + (config[:source_dir] || [])
      @layouts = ['layouts'] + (config[:layout_dir] || [])
    end
  end
end
