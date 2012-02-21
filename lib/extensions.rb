class String
  def words
    strip.split /\s+/
  end
end

class Hash
  def subhash(*keys)
    keys = keys.flatten
    select {|k,v| keys.include? k}
  end
end
