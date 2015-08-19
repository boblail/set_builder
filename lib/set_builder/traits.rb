require 'set_builder/trait'
require 'set_builder/trait_builder'
require 'set_builder/modifier_collection'
require 'delegate'


module SetBuilder
  class Traits < SimpleDelegator



    def initialize(array=[], &block)
      super array
      TraitBuilder.new(self).instance_eval(&block) if block_given?
    end



    def [](index)
      case index
      when Symbol, String
        index = index.to_s
        self.find {|trait| trait.name == index}
      else
        super
      end
    end



    def to_json
      "[#{collect(&:to_json).join(",")}]"
    end



    def +(other_traits)
      return super unless other_traits.is_a?(self.class)
      self.class.new(self.__getobj__ + other_traits.__getobj__)
    end

    def concat(other_traits)
      return super unless other_traits.is_a?(self.class)
      self.class.new(self.__getobj__.concat other_traits.__getobj__)
    end



    def modifiers
      # !nb: not sure why inject was failing but it was modifying trait.modifiers!
      @modifiers = ModifierCollection.new
      each do |trait|
        trait.modifiers.each do |modifier|
          @modifiers << modifier unless @modifiers.member?(modifier)
        end
      end
      @modifiers
    end



  end
end
