# This applies to every non-custom mapper!  Custom mappers can use it too.
class DefaultMapper < ContentfulMiddleman::Mapper::Base
  def map(context, entry)
    super
  end
end
