RSpec::Matchers.define :be_enabled do
  match do |subject|
    if subject.class.name == 'Serverspec::Type::Service'
      subject.enabled?(@level, @under)
    elsif subject.class.name == 'Serverspec::Type::ZabbixConfig'
      subject.enabled?(@itemkey)
    else
      subject.enabled?
    end
  end

  description do
    message = 'be enabled'
    message << " under #{@under}" if @under
    message << " with level #{@level}" if @level
    message
  end

  chain :with_level do |level|
    @level = level
  end

  chain :under do |under|
    @under = under
  end

  chain :with_itemkey do |key|
    @itemkey = key
  end
end
