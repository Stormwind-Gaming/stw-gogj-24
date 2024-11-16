extends Node

class_name ConfigLoader

signal constants_loaded

# Cache of loaded values
var _values: Dictionary = {}

# Google Sheets API configuration
const SHEET_ID = "1TzJdWg-OfYQHSuT3lqEoHVVVSNJ7cnjfNcGScg9whpg"
const API_KEY = "AIzaSyDsYeyBZPlQbxacdjJOfrwfdtClzqQpVks"
const BASE_URL = "https://sheets.googleapis.com/v4/spreadsheets/%s/values/%s?key=%s"

func _ready():
    load_constants()

func load_constants():
    # Create HTTP request node
    var http = HTTPRequest.new()
    add_child(http)
    http.connect("request_completed", _on_constants_loaded)
    
    # Make request to Google Sheets API
    var url = BASE_URL % [SHEET_ID, "Constants!A2:C100", API_KEY]
    http.request(url)

func _on_constants_loaded(result, response_code, headers, body):
    if response_code != 200:
        print('failed to load constants from Google Sheets')
        push_error("Failed to load constants from Google Sheets")
        return
        
    var json = JSON.parse_string(body.get_string_from_utf8())
    var rows = json.values
    
    # Parse the rows into our values dictionary
    for row in rows:
        if row.size() < 2: continue
        var name = row[0]
        var value = parse_value(row[1])
        var type = row[2] if row.size() > 2 else "float"
        
        _values[name] = value

    emit_signal("constants_loaded")

func parse_value(value_str: String):
    # Handle different types (int, float, bool, etc)
    if value_str.is_valid_int():
        return value_str.to_int()
    elif value_str.is_valid_float():
        return value_str.to_float()
    elif value_str.to_lower() == "true":
        return true
    elif value_str.to_lower() == "false":
        return false
    return value_str

func get_value(name: String, default = null):
    return _values.get(name, default) 