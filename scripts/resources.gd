extends Node

@onready var player = get_node("/root/Game/Entities/Player")

const Items = {
	"Sword": {
		"damage": "emerson",
		"is_emerson": true,
		"obtainable": "emerson?",
		"may_be_used_by": "emerson??",
		"max_stack": 1
	}
}
