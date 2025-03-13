class CacheService
  def self.fetch(key, expires_in: 10.minutes, &block)
    Rails.cache.fetch(key, expires_in: expires_in, &block)
  end

  def self.delete(key)
    Rails.cache.delete(key)
  end
  
  def self.clear
    Rails.cache.clear
  end
end
