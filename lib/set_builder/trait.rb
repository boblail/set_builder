require "set_builder/constraint"
require "set_builder/modifier"


module SetBuilder
  class Trait
    attr_reader :expression, :name, :modifiers, :direct_object_type, :negative



    def initialize(expression, &block)
      @expression = expression
      @name, @direct_object_type, @negative = find(:name), find(:direct_object_type), find(:negative)
      @direct_object_type = @direct_object_type.to_sym if @direct_object_type
      @block = block
      @modifiers = find_all(:modifier).map { |modifier_type| Modifier[modifier_type] }
    end



    def requires_direct_object?
      !@direct_object_type.nil?
    end
    alias :direct_object_required? :requires_direct_object?

    def negatable?
      negative.present?
    end



    def to_s(negative=false)
      parsed_expression.reject do |token, _|
        [:modifier, :direct_object_type].include?(token) || (!negative && token == :negative)
      end.map do |token, value|
        token == :name ? name : value
      end.join(" ")
    end

    def as_json(*)
      parsed_expression.map { |(token, value)| [token.to_s, value] }
    end

    def apply(constraint)
      SetBuilder::Constraint.new(self, constraint, &@block)
    end



  private



    def find_all(token)
      parsed_expression.select { |(_token, _)| _token == token }.map { |(_, value)| value }
    end

    def find(token)
      find_all(token).first
    end



    def parsed_expression
      @parsed_expression ||= parse(expression)
    end

    def parse(trait_definition)
      regex = Regexp.union(LEXER.values)
      trait_definition.split(regex).map do |lexeme|
        [token_for(lexeme), value_for(lexeme)] unless lexeme.strip.empty?
      end.compact
    end

    def token_for(lexeme)
      LEXER.each { |token, pattern| return token if pattern.match(lexeme) }
      return :string
    end

    def value_for(lexeme)
      lexeme.to_s.strip.gsub(/[<>"\[\]:]/, "")
    end

    LEXER = {
      name: /("[^"]+")/,
      direct_object_type: /(:[\w\-\.]+)/,
      negative: /(\[[^\]]+\])/,
      modifier: /(<\w+>)/
    }.freeze



  end
end
