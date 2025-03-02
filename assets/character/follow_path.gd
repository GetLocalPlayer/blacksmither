extends Path3D


## The distance at which following starts
@export var max_distance: float = 2
## The distance at which following stops
@export var min_distance: float = 1.5

@onready var _followed_body: CharacterBody3D = owner


func _physics_process(delta: float) -> void:
    for p in curve.get_baked_points():
        pass
