RSpec::Matchers.define :be_normal do
  match do |path|
    path.normal?(@itemkey)
  end

  chain :with_itemkey do |key|
    @itemkey      = key
  end
end
