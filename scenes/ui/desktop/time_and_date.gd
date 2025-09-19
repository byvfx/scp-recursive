extends Control

func _ready() -> void:
	update_time()
	# Make sure you have a Timer node as a child and connect it
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.wait_time = 1.0  # Update every second
	$Timer.start()

func update_time() -> void:
	var date_dict: Dictionary = Time.get_datetime_dict_from_system()
	var suffix: String
	if date_dict.hour >= 12:
		date_dict.hour -= 12
		suffix = "PM"
	else:
		suffix = "AM"
		if date_dict.hour == 0:
			date_dict.hour = 12
	
	$VBoxContainer/TimeText.text = "[center]%02d:%02d %s" % [date_dict.hour, date_dict.minute, suffix]
	$VBoxContainer/DateText.text = "[center]%02d/%02d/%d" % [date_dict.month, date_dict.day, date_dict.year]

func _on_timer_timeout() -> void:
	update_time()
