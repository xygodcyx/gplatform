class_name MobileButton extends Button

var is_press_down: bool = false
signal button_press_down
signal button_press_up

func _process(_delta: float) -> void:
	if is_press_down:
		button_press_down.emit()

func _ready() -> void:
	button_down.connect(
		func():
			is_press_down = true
			button_press_down.emit()
	)
	button_up.connect(
		func():
			is_press_down = false
			button_press_up.emit()
	)
