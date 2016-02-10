class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      #define getter
      define_method(name) do
        self.instance_variable_get("@#{name}")
      end
      #define setter
      define_method("#{name}=") do |new_name|
        self.instance_variable_set("@#{name}", new_name)
      end
    end
  end
end
