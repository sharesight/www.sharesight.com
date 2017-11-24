module CapybaraFileHelpers
  def dir_list(path)
    Dir.entries(root_path + '/' + path)
  end

  private

  def root_path
    @root_path ||= File.expand_path(File.dirname(__FILE__) + "../../../..")
  end
end
