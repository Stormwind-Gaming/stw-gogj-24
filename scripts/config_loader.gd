extends NodeWithCleanup

class_name ConfigLoader

signal constants_loaded

# Cache of loaded values
var _values: Dictionary = {}

# Google Sheets API configuration
const SHEET_ID = "1TzJdWg-OfYQHSuT3lqEoHVVVSNJ7cnjfNcGScg9whpg"
const API_KEY = "AIzaSyDsYeyBZPlQbxacdjJOfrwfdtClzqQpVks" # This key is obsolete
const BASE_URL = "https://sheets.googleapis.com/v4/spreadsheets/%s/values/%s?key=%s"

func _ready():
    load_constants()

func load_constants():
    LogDuck.d("Starting to load constants from Google Sheets")
    # Create HTTP request node
    var http = HTTPRequest.new()
    http.accept_gzip = false
    add_child(http)
    http.connect("request_completed", _on_constants_loaded)
    
    # Make request to Google Sheets API
    var url = BASE_URL % [SHEET_ID, "Constants!A2:C100", API_KEY]
    LogDuck.d("Making HTTP request to URL: " + url)
    http.request(url)

func _on_constants_loaded(result, response_code, headers, body):
    # First check if the request itself was successful
    if result != HTTPRequest.RESULT_SUCCESS:
        LogDuck.e("HTTP Request failed", {"result": result})
        print("HTTP Request failed with result: " + str(result))
        push_error("HTTP Request failed with result: " + str(result))
        return
        
    # Then check the response code
    if response_code != 200:
        LogDuck.e("Failed to load constants", {"response_code": response_code})
        print('failed to load constants from Google Sheets. Response code: ' + str(response_code))
        push_error("Failed to load constants from Google Sheets. Response code: " + str(response_code))
        return
    
    LogDuck.d("Successfully received response from Google Sheets")
    
    # Safely parse JSON
    var json_string = body.get_string_from_utf8()
    var json = JSON.new()
    var parse_result = json.parse(json_string)
    
    if parse_result != OK:
        print('failed to parse JSON: ' + json.get_error_message() + ' at line ' + str(json.get_error_line()))
        push_error("Failed to parse JSON: " + json.get_error_message() + " at line " + str(json.get_error_line()))
        return
        
    var data = json.get_data()
    if not data.has("values"):
        print('JSON response missing "values" key')
        push_error("JSON response missing 'values' key")
        return
        
    # Parse the rows into our values dictionary
    LogDuck.d("Starting to parse rows from response")
    var parsed_count = 0
    for row in data.values:
        if row.size() < 2:
            LogDuck.warning("Skipping invalid row", {"row": row})
            continue
        var name = row[0]
        var value = parse_value(row[1])
        var type = row[2] if row.size() > 2 else "float"
        
        _values[name] = value

    emit_signal("constants_loaded")

func parse_value(value_str: String):
    LogDuck.d("Parsing value", {"value": value_str})
    # Handle different types (int, float, bool, etc)
    var result
    if value_str.is_valid_int():
        result = value_str.to_int()
    elif value_str.is_valid_float():
        result = value_str.to_float()
    elif value_str.to_lower() == "true":
        result = true
    elif value_str.to_lower() == "false":
        result = false
    else:
        result = value_str
    
    LogDuck.d("Parsed value result", {"input": value_str, "result": result})
    return result

func get_value(name: String, default = null):
    return _values.get(name, default)