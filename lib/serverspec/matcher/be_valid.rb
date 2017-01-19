RSpec::Matchers.define :be_valid do
  match do |path|
    if @target == :item
      path.valid_item?(@itemkey)
    else
      path.valid?
    end
  end

  chain :with_itemkey do |key|
    @itemkey      = key
  end
end
