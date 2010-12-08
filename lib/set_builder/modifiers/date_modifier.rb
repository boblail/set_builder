require 'set_builder/modifier/adverb'


module SetBuilder
  module Modifiers
    class DateModifier < Modifier::Adverb
      
      
      
      def self.operators
        {
          :ever => [],
          :before => [:date],
          :after => [:date],
          :on => [:date],
          :during_month => [:month],
          :during_year => [:number],
          :in_the_last => [:number, :period]
        }
      end
      
      
      
      def build_conditions_for(selector)
        case operator
        when :ever
          "#{selector} IS NOT NULL"
        when :before
          "#{selector}<'#{format_value}'"
        when :after
          "#{selector}>'#{format_value}'"
        when :on
          "#{selector}='#{format_value}'"
        when :during_month
          "MONTH(#{selector})=#{values[0]}"
        when :during_year
          "YEAR(#{selector})=#{values[0]}"
        when :in_the_last
          "#{selector}>='#{format_value}'"
        end
      end
      
      
      
    protected
      
      
      
      def get_date
        case operator
        when :in_the_last
          case values[1]
          when "years", "year"
            values[0].to_i.years.ago
          when "months", "month"
            values[0].to_i.months.ago
          when "weeks", "week"
            values[0].to_i.weeks.ago
          when "days", "day"
            values[0].to_i.days.ago
          end          
        else
          values[0].to_date
        end
      end
      
      
      
      def format_value
        get_date.strftime('%Y-%m-%d')
      end
      
      
      
    end
  end
end