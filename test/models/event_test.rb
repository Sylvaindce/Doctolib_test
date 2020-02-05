require 'test_helper'

class EventTest < ActiveSupport::TestCase
  
  test "one simple test example" do
    
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "1 day 2 Events(1 WR)" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-11 12:30"), ends_at: DateTime.parse("2014-08-11 17:30"), weekly_recurring: false

    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    
    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "1 day 2 Events(1 WR) revert" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 12:30"), ends_at: DateTime.parse("2014-08-04 17:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-11 09:30"), ends_at: DateTime.parse("2014-08-11 12:30"), weekly_recurring: false

    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    
    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end
  
  test "2 same Events" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-09-04 09:30"), ends_at: DateTime.parse("2014-09-04 12:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-09-04 09:30"), ends_at: DateTime.parse("2014-09-04 12:30"), weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse("2014-09-10")
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities[1][:slots]
  end

  test "create event outside the 7 days compute" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-09-04 09:30"), ends_at: DateTime.parse("2014-09-04 12:30"), weekly_recurring: false

    availabilities = Event.availabilities DateTime.parse("2014-09-20")
    assert_equal [], availabilities[0][:slots]
  end

  test "WR event after availabilities date" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-12-04 09:30"), ends_at: DateTime.parse("2014-12-04 12:30"), weekly_recurring: true

    availabilities = Event.availabilities DateTime.parse("2014-09-20")
    #modify the assert for the good week day
    assert_equal [], availabilities[0][:slots]
  end
  
end
