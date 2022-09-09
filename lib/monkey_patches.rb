# https://www.jvt.me/posts/2019/09/07/ruby-hash-keys-string-symbol/
class ::Hash
  # via https://stackoverflow.com/a/25835016/2257038
  def stringify_keys
    h = self.map do |k,v|
      transformed_values = case
                           when v.instance_of?(Hash) then v.stringify_keys
                           when v.instance_of?(Array) then v.map(&:stringify_keys)
                           else v
                           end

      [k.to_s, transformed_values]
    end

    Hash[h]
  end

  # via https://stackoverflow.com/a/25835016/2257038
  def symbolize_keys
    h = self.map do |k,v|
      transformed_values = case
                           when v.instance_of?(Hash) then v.symbolize_keys
                           when v.instance_of?(Array) then v.map(&:symbolize_keys)
                           else v
                           end

      [k.to_sym, transformed_values]
    end

    Hash[h]
  end
end

