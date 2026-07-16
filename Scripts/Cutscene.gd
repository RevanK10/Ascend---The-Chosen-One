extends Control

var slides: Array = []
var current_slide: int = 0
var typing_timer: float = 0.0
var typed_chars: int = 0
var typing_speed: float = 38.0
var next_scene: String = ""
var is_transitioning: bool = false
var full_text: String = ""

@onready var bg_rect: ColorRect = $BgRect
@onready var title_label: Label = $VBox/TitleLabel
@onready var text_label: RichTextLabel = $VBox/TextLabel
@onready var prompt_label: Label = $PromptLabel
@onready var slide_counter: Label = $SlideCounter
@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	fade_rect.modulate.a = 1.0
	var tw = create_tween()
	tw.tween_property(fade_rect, "modulate:a", 0.0, 0.8)
	await tw.finished
	if slides.size() > 0:
		show_slide(0)

func show_slide(index: int) -> void:
	if index >= slides.size():
		finish()
		return
	current_slide = index
	var slide = slides[index]
	bg_rect.color = slide.get("bg_color", Color(0.05, 0.05, 0.1, 1))
	title_label.text = slide.get("title", "")
	full_text = slide.get("text", "")
	text_label.text = ""
	typed_chars = 0
	typing_timer = 0.0
	slide_counter.text = "%d / %d" % [index + 1, slides.size()]
	prompt_label.modulate.a = 0.0

func _process(delta: float) -> void:
	if slides.size() == 0 or is_transitioning:
		return
	typing_timer += delta
	var target = int(typing_timer * typing_speed)
	if target > typed_chars and typed_chars < full_text.length():
		typed_chars = min(target, full_text.length())
		text_label.text = full_text.substr(0, typed_chars)
	if typed_chars >= full_text.length():
		prompt_label.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.003)

func _input(event: InputEvent) -> void:
	if is_transitioning:
		return
	var pressed = false
	if event is InputEventKey and event.pressed and not event.echo:
		pressed = true
	if event is InputEventMouseButton and event.pressed:
		pressed = true
	if not pressed:
		return
	if typed_chars < full_text.length():
		typed_chars = full_text.length()
		text_label.text = full_text
	else:
		if current_slide + 1 >= slides.size():
			finish()
		else:
			show_slide(current_slide + 1)

func finish() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	var tw = create_tween()
	tw.tween_property(fade_rect, "modulate:a", 1.0, 0.8)
	await tw.finished
	var dest = next_scene if next_scene != "" else "res://Scenes/MainMenu.tscn"
	get_tree().change_scene_to_file(dest)
