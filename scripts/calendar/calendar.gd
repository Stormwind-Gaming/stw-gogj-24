extends Node
class_name Calendar

# Initial date variables
var year: int = 1942
var month: int = 1
var day: int = 1

# Days per month, accounting for February in leap years
const DAYS_IN_MONTHS = { 1: 31, 2: 28, 3: 31, 4: 30, 5: 31, 6: 30, 7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31 }

func _ready():
    # Initialize with a random day in early 1942
    randomize()
    month = 1 #randi_range(1, 4)  # Start between January and April
    day = 1 #randi_range(1, DAYS_IN_MONTHS[month])

# Array of month names
var month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

# Function to get a string representation of the current date with the month name
func get_date_string() -> String:
    return "%02d %s %04d" % [day, month_names[month - 1], year]

# Function to check if a year is a leap year
func is_leap_year(y: int) -> bool:
    return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)

# Increment the date by one day
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

    print("New date:", get_date_string())

# Function to get a new birthdate for a character
func get_new_birthdate() -> String:
    var birth_year = year - randi_range(18, 40)
    var birth_month = randi_range(1, 12)
    var birth_day = randi_range(1, DAYS_IN_MONTHS[birth_month])
    return "%02d %s %04d" % [birth_day, month_names[birth_month - 1], birth_year]