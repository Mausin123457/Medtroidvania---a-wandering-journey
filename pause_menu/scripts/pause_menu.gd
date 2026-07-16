class_name PauseMenu extends CanvasLayer

#region /// On ready variables
@onready var system: Control = $Control/System
@onready var pause_screen: Control = $Control/PauseScreen
@onready var menu_button: Button = %MenuButton
@onready var return_button: Button = %ReturnButton
@onready var quit_to_title_button: Button = %QuitToTitleButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var ui_slider: HSlider = %UISlider
@onready var pause_menu: PauseMenu = $"."
#endregion

var player: Player

func _ready() -> void:
	if pause_menu.visible == true:
		PlayerHud.visible = false
	else:
		PlayerHud.visible = true
	
	pass


func _unhandled_input(event: InputEvent) -> void:
	
	pass
