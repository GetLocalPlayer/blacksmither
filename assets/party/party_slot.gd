extends PathFollow3D


@onready var _remote: RemoteTransform3D = RemoteTransform3D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_remote.update_position = true
	_remote.update_scale = true
	_remote.update_rotation = false
	_remote.remote_path = ""
	add_child(_remote)

	get_parent().child_entered_tree.connect(func(child: Node):
		if child == _remote: return
		_remote.remote_path = NodePath("../%s" % child.name)
	)

	get_parent().child_exiting_tree.connect(func(child: Node):
		if _remote.remote_path == NodePath("../%s" % child.name):
			_remote.remote_path = ""
	)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
