require 'spec_helper'

description = 'enterprise magento v1.14 under apache with single redis, mysql, and php 5.5'
describe description do
  it_behaves_like 'magento under apache'
end

describe description do
  it_behaves_like 'magento under mysql'
end

describe description do
  it_behaves_like 'php55 under apache'
end