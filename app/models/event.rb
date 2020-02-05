class Event < ApplicationRecord
   
    enum EVENT_TYPE: {OPEN: "opening", BOOKED: "appointment"}

    def self.availabilities(date)
        dates = [*date.to_date..date.to_date + (AVAILABILITIES_FOR_XX_DAYS - 1)]
        grouped_wanted_events = get_specific_event_from_db(dates)
        @result = {}

        dates.each_with_index do |date, index|
            @result[date] = []
        end
        dates = nil
        tmp_result_keys = @result.keys()

        Event.EVENT_TYPEs.each do |id, type|
            grouped_wanted_events[type].try(:each) do |event|
                if tmp_result_keys.include? event.starts_at.to_date then
                    type_switcher_computing_slot(type, event.starts_at.to_date, event)
                end
                
                if event.weekly_recurring.eql? true then
                    wday_result = tmp_result_keys.map{|day| day.wday}
                    event_wday = event.starts_at.to_date.wday
                    found_weekday_indexes =  wday_result.each_index.select {|index| wday_result[index] == event_wday}
                    found_weekday_indexes.try(:each) do |index|
                        type_switcher_computing_slot(type, tmp_result_keys[index], event)
                    end
                    wday_result, event_wday, found_weekday_indexes = nil
                end
            end
        end
        grouped_wanted_events, tmp_result_keys = nil
        formatted
    end

    def self.type_switcher_computing_slot(type, key, event)
        case type
        when Event.EVENT_TYPEs[:OPEN]
            @result[key] += event.compute_slots
        when Event.EVENT_TYPEs[:BOOKED]
            @result[key] -= event.compute_slots
        end
        @result[key] = @result[key]
    end

    def self.get_specific_event_from_db(dates)
        sql_query = "(starts_at BETWEEN ? AND ?) OR (weekly_recurring = ? AND kind = ? and starts_at <= ?)"
        Event.where(sql_query, dates[0], dates[-1], 1, Event.EVENT_TYPEs[:OPEN], dates[0])
             .order(starts_at: :asc)
             .group_by{|event| event.kind}
    end

    def self.formatted()
        formatted_result = [nil] * @result.length
        i = 0
        @result.try(:each) do |date, slots|
            formatted_result[i] = {date: date, slots: slots.uniq.sort().map{|hour| hour.strftime("%-H:%M")}}
            i += 1
        end
        @result, i = nil
        formatted_result
    end

    def compute_slots()
        begin_time = self.starts_at
        slots = []
        begin
            slots.push(begin_time.change(year: 1970, month: 1, day: 1))
            begin_time += SLOT_DURATION.minutes
        end while begin_time < self.ends_at
        begin_time = nil
        slots
    end

end