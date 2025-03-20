extends AnimationTree


signal animation_track_triggered


func emit_animation_track_triggered() -> void:
	animation_track_triggered.emit()