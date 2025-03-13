require 'rails_helper'

RSpec.describe CacheService do
  let(:key) { "test_key" }
  let(:key2) { "test_key-2" }
  let(:value) { "cached value" }
  let(:value2) { "cached value 2" }

  before(:each) do
    Rails.cache.clear
  end

  it "saves and returns value" do
    cached_value = CacheService.fetch(key, expires_in: 1.minute) { value }
    expect(cached_value).to eq(value)
    expect(Rails.cache.read(key)).to eq(value)
  end

  it "removes expired value" do
    Rails.cache.fetch(key, expires_in: 1.second) { value }
    expect(Rails.cache.read(key)).to eq(value)
    sleep 2
    expect(Rails.cache.read(key)).to be_nil
  end

  it "removes value by key" do
    Rails.cache.fetch(key, expires_in: 1.minute) { value }
    Rails.cache.fetch(key2, expires_in: 1.minute) { value2 }
    expect(Rails.cache.read(key)).to eq(value)
    CacheService.delete(key)
    expect(Rails.cache.read(key)).to be_nil
    expect(Rails.cache.read(key2)).to eq(value2)
  end

  it "clears cache" do
    Rails.cache.fetch(key, expires_in: 1.minute) { value }
    Rails.cache.fetch(key2, expires_in: 1.minute) { value2 }
    expect(Rails.cache.read(key)).to eq(value)
    expect(Rails.cache.read(key2)).to eq(value2)
    CacheService.clear
    expect(Rails.cache.read(key)).to be_nil
    expect(Rails.cache.read(key2)).to be_nil
  end
end
