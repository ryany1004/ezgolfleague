module EzglCalendar
	class CalendarUtils
		def self.datetime_for_picker_date(picker_date)
			input_format = "%m/%d/%Y %I:%M %p"
			input_parsed = DateTime.strptime(picker_date, input_format)

			output = input_parsed.strftime("%Y-%m-%d %I:%M %p")
			savings_safe_date = output.in_time_zone(Time.zone.name)

			return savings_safe_date
		end

		def self.date_for_picker_date(picker_date)
			input_format = "%m/%d/%Y"
			input_parsed = DateTime.strptime(picker_date, input_format)

			output = input_parsed.strftime("%Y-%m-%d")
			savings_safe_date = output.in_time_zone(Time.zone.name)

			return savings_safe_date
		end
	end
end