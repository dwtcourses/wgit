# @author Michael Telford
# Utility module containing generic methods.
module Utils
    def self.time_stamp
        Time.new
    end
    
    def self.to_h(obj, ignore = [])
        hash = {}
        obj.instance_variables.each do |var|
            next if ignore.include?(var)
            hash[var[1..-1]] = obj.instance_variable_get(var)
        end
        hash
    end
    
    def self.is_a?(obj_or_objs, type_or_types, msg = nil)
        if obj_or_objs.respond_to?(:each)
            obj_or_objs.each do |obj|
                return false unless is_type?(obj, type_or_types, msg)
            end
            true
        else
            is_type?(obj_or_objs, type_or_types, msg)
        end
    end

    def self.is_type?(obj, type_or_types, msg = nil)
        if type_or_types.respond_to?(:each)
            type_or_types.each do |type|
                return true if obj.is_a?(type)
            end
            if msg.nil?
                raise "obj.is_a?(#{type_or_types}) must be true"
            else
                raise msg
            end
        else
            type = type_or_types
            if (msg.nil?)
                raise "obj.is_a?(#{type}) must be true" unless obj.is_a?(type)
            else
                raise msg unless obj.is_a?(type)
            end
        end
        true
    end
    
    private_class_method :is_type?
end
