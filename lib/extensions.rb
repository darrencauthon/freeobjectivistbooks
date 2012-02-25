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

# to_bool

class TrueClass
  def to_bool
    self
  end
end

class FalseClass
  def to_bool
    self
  end
end

class NilClass
  def to_bool
    false
  end
end

class String
  def to_bool
    downcase.in? %w{true t yes y 1}
  end
end

class Integer
  def to_bool
    self != 0
  end
end
