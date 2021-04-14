require "test_helper"

class DatePrepositionTest < ActiveSupport::TestCase
  include SetBuilder::Modifiers

  attr_reader :table

  setup do
    @table = Arel::Table.new(:people)
  end


  test "should constrain our date queries to A.D." do
    Timecop.freeze do
      time = 5.years.ago
      modifier = DatePreposition.new(operator: :in_the_last, values: [5, "years"])
      assert_equal "\"people\".\"birthday\" >= '#{time}'",
        modifier.build_arel_for(table[:birthday]).to_sql
    end
  end

  test "should use 'IS NOT NULL' rather than '!= NULL'" do
    modifier = DatePreposition.new(operator: :ever, values: [])
    assert_equal "\"people\".\"birthday\" IS NOT NULL",
      modifier.build_arel_for(table[:birthday]).to_sql

    assert_equal "values.value::date IS NOT NULL",
      modifier.build_arel_for(Arel.sql("values.value::date")).to_sql
  end


end
