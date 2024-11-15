extends Node
class_name Calendar

#|==============================|
#|          Constants           |
#|==============================|
"""
@brief Dictionary defining the number of days in each month (1-12).
Note: February (2) is set to 28 days, with leap years handled separately.
"""
const DAYS_IN_MONTHS = { 
    1: 31, 2: 28, 3: 31, 4: 30, 
    5: 31, 6: 30, 7: 31, 8: 31, 
    9: 30, 10: 31, 11: 30, 12: 31 
}

#|==============================|
#|      Member Variables        |
#|==============================|
var initialised: bool = false

# Date tracking
var year: int = 1942
var month: int = 1
var day: int = 1

# Month name lookup
var month_names = [
    "January", "February", "March", 
    "April", "May", "June", 
    "July", "August", "September", 
    "October", "November", "December"
]

#|==============================|
#|        Initialization        |
#|==============================|
"""
@brief Sets up the calendar with a random starting date in early 1942.
"""
func _setup_calendar():
    randomize()
    month = randi_range(1, 4)  # Start between January and April
    day = randi_range(1, DAYS_IN_MONTHS[month])

#|==============================|
#|           Getters           |
#|==============================|
"""
@brief Formats the current date as a string with the format "DD Month YYYY".
Optionally offsets the date by the given number of days.

@param days_offset Optional number of days to offset the date by (default: 0)
@return A formatted string representation of the current/offset date.
"""
func get_date_string(days_offset: int = 0) -> String:
    if not initialised:
        _setup_calendar()
        initialised = true
        
    var offset_day = day
    var offset_month = month 
    var offset_year = year
    
    # Apply the offset if non-zero
    for i in range(days_offset):
        offset_day += 1
        
        # Check if we need to increment month
        var days_in_current_month = DAYS_IN_MONTHS[offset_month]
        if offset_month == 2 and is_leap_year(offset_year):
            days_in_current_month = 29
            
        if offset_day > days_in_current_month:
            offset_day = 1
            offset_month += 1
            
            # Check if we need to increment year
            if offset_month > 12:
                offset_month = 1
                offset_year += 1
                
    return "%02d %s %04d" % [offset_day, month_names[offset_month - 1], offset_year]

"""
@brief Generates a random birthdate for character creation.
The birth year is calculated to ensure characters are between 18 and 40 years old.

@return A formatted string representing the generated birthdate.
"""
func get_new_birthdate() -> String:
    var birth_year = year - randi_range(18, 40)
    var birth_month = randi_range(1, 12)
    var birth_day = randi_range(1, DAYS_IN_MONTHS[birth_month])
    return "%02d %s %04d" % [birth_day, month_names[birth_month - 1], birth_year]

#|==============================|
#|       Helper Functions       |
#|==============================|
"""
@brief Determines if a given year is a leap year.

@param y The year to check.
@return True if the year is a leap year, false otherwise.
"""
func is_leap_year(y: int) -> bool:
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)

"""
@brief Advances the calendar by one day, handling month and year transitions.
Takes into account varying month lengths and leap years.
"""
func increment_day():
    day += 1

    # Check if we've gone past the last day of the current month
    var days_in_current_month = DAYS_IN_MONTHS[month]
    
    # Adjust for February in leap years
    if month == 2 and is_leap_year(year):
        days_in_current_month = 29

    # If we've gone past the last day, move to the next month
    if day > days_in_current_month:
        day = 1
        month += 1

        # If we've gone past December, move to the next year
        if month > 12:
            month = 1
            year += 1