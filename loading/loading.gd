extends CanvasLayer

const _preload_animation_name := "Preload"
const _postload_animation_name := "Postload"

var _is_loading := false
var _should_play_animation := false
var _progress_completion := []
var _scene_path: String

@onready var _animator: AnimationPlayer = %animator
@onready var _progress_bar: ProgressBar = %progress_bar
@onready var _background: ColorRect = %background

func _ready():
	_background.visible = false
	_background.modulate = Color(1, 1, 1, 0)

func load_scene(path: String, use_transition_scene: bool = false) -> void:
	if not _is_loading:
		_is_loading = true
		_should_play_animation = use_transition_scene
		call_deferred("_deferred_load_scene", path)
	else:
		printerr("Scene loading was called while another scene is already loading")

func _process(_delta: float) -> void:
	if _is_loading:
		var loading_status := ResourceLoader.load_threaded_get_status(
			_scene_path,
			_progress_completion)

		_progress_bar.value = _progress_completion[0]

		match loading_status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass
			ResourceLoader.THREAD_LOAD_LOADED:
				_set_new_scene()
			ResourceLoader.THREAD_LOAD_FAILED:
				printerr("Scene loading failed")
				_is_loading = false

func _deferred_load_scene(path: String) -> void:
	_scene_path = path
	ResourceLoader.load_threaded_request(_scene_path)
	_play_animation(_preload_animation_name)

func _set_new_scene() -> void:
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(_scene_path))

	_play_animation(_postload_animation_name)

	_is_loading = false
	_progress_completion[0] = 0.0

func _play_animation(animation_name: String) -> void:
	if _should_play_animation:
		_animator.play(animation_name)
