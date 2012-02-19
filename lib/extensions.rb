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

class ActiveRecord::Base
  def self.calculate_metrics(metrics)
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}

    metrics.each do |metric|
      denominator = metric[:denominator]
      metric[:percent] = metric[:value].to_f / values[denominator] if denominator && metric[:value] > 0
    end
  end
end