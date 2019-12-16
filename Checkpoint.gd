extends Area

var active = false
var recent = true

onready var mesh = $MeshInstance
onready var player = get_tree().get_nodes_in_group("players")[0]
onready var UI = get_tree().get_nodes_in_group("ui")[0]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("player_died", self, "player_respawn")	
	# assign a unique material
	mesh.material_override = mesh.material_override.duplicate()
	
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
		UI.show_info("Checkpoint set!")
		$AnimationPlayer.play("Activate")
	
		
		for i in get_tree().get_nodes_in_group("checkpoints"):
			if i != self:
				i.recent = false
		
		#print (self.name, " is now an active checkpoint")
