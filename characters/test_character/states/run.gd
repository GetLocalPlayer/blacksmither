extends FSMState


var _actions = {
    left = "MoveLeft",
    right = "MoveRight",
    up = "MoveUp",
    down = "MoveDown"
}


func _update(_context: Node, _delta: float):
    var dir = Vector3.ZERO
    dir.x += 1 if Input.is_action_pressed(_actions.left) else 0
    dir.x -= 1 if Input.is_action_pressed(_actions.right) else 0
    dir.z += 1 if Input.is_action_pressed(_actions.up) else 0
    dir.z -= 1 if Input.is_action_pressed(_actions.down) else 0
    print(dir)
    var character = _context as CharacterBody3D
    character.velocity = dir.normalized() * _context.speed
    character.move_and_slide()
