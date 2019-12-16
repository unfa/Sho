extends Area

var active = false
var recent = true

onready var mesh = $MeshInstance
var material_inactive = preload("res://Assets/Checkpoint/CheckpointInactive.material")
var material_active = preload("res://Assets/Checkpoint/CheckpointActive.material")

onready var player = get_tree().get_nodes_in_group("players")[0]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("player_died", self, "player_respawn")
	
	mesh.material_override = material_inactive
	
	# assign a unique material
	#$MeshInstance.material_override = $MeshInstance.material_override.duplicate()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func player_respawn():
	if active and recent:
		player.respawn(self)

func _on_Checkpoint_body_entered(body):
	if body.is_in_group("players") and not active:
		active = true
		recent = true
	
		mesh.material_override = material_active	
		#$AnimationPlayer.play("Activate")
	
		
		for i in get_tree().get_nodes_in_group("checkpoints"):
			if i != self:
				i.recent = false
		
		#print (self.name, " is now an active checkpoint")
