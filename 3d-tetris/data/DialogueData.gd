# DialogueData.gd - Autoload singleton for managing dialogue content
extends Node

# Store all dialogue trees
var dialogue_trees: Dictionary = {}
var portraits: Dictionary = {}

func _ready():
	_load_portraits()
	_load_dialogue_trees()

func _load_portraits():
	# Load portrait images
	# portraits["narrator"] = preload("res://assets/portraits/narrator.png")
	# portraits["tetris_block"] = preload("res://assets/portraits/block.png")
	# portraits["voice_of_logic"] = preload("res://assets/portraits/logic.png")
	pass

func _load_dialogue_trees():
	# Example: Intro dialogue
	dialogue_trees["intro"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The blocks fall. They always fall. In this strange world of three dimensions, gravity is not just a law—it's a certainty.",
			"choices": [
				{"text": "[Look around]", "next": "look_around"},
				{"text": "[Question reality]", "next": "question"},
				{"text": "[Accept your fate]", "next": "accept"}
			]
		},
		"look_around": {
			"speaker": "PERCEPTION",
			"speaker_id": "narrator",
			"text": "A 5x13x5 grid stretches before you. The void below hungers. The red death-zone above glows ominously.",
			"next": "after_choice"
		},
		"question": {
			"speaker": "LOGIC",
			"speaker_id": "voice_of_logic",
			"text": "Why do we stack blocks? The answer is simple: because we must. Because there is nothing else.",
			"next": "after_choice"
		},
		"accept": {
			"speaker": "VOLITION",
			"speaker_id": "narrator",
			"text": "Yes. This is your purpose. You are the arranger. The organizer. The last defense against chaos.",
			"next": "after_choice"
		},
		"after_choice": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The first piece appears at the spawn point. Your journey begins.",
			"choices": []  # Empty choices = dialogue ends
		}
	}
	
	# Example: Game over dialogue
	dialogue_trees["game_over"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The tower has fallen. The blocks have breached the dead zone. All is lost.",
			"choices": [
				{"text": "[Try again]", "next": "try_again"},
				{"text": "[Reflect on failure]", "next": "reflect"}
			]
		},
		"try_again": {
			"speaker": "VOLITION",
			"speaker_id": "voice_of_logic",
			"text": "Get up. The blocks still need you. They will always need you.",
			"choices": []
		},
		"reflect": {
			"speaker": "INLAND EMPIRE",
			"speaker_id": "narrator",
			"text": "Perhaps... this was always meant to happen. Perhaps the chaos was inside us all along.",
			"choices": []
		}
	}
	
	# Example: Level complete dialogue
	dialogue_trees["level_complete"] = {
		"start": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The layer collapses. Matter reorganizes itself. You feel... satisfaction?",
			"choices": [
				{"text": "[Feel proud]", "next": "proud"},
				{"text": "[Want more]", "next": "want_more"}
			]
		},
		"proud": {
			"speaker": "EMPATHY",
			"speaker_id": "voice_of_logic",
			"text": "Yes. This is achievement. Small, perhaps. Meaningless in the grand scheme. But yours.",
			"choices": []
		},
		"want_more": {
			"speaker": "ELECTROCHEMISTRY",
			"speaker_id": "narrator",
			"text": "MORE! Clear another layer! And another! Feed the hunger for perfect organization!",
			"choices": []
		}
	}

func get_dialogue_tree(tree_id: String) -> Dictionary:
	return dialogue_trees.get(tree_id, {})

func get_portraits() -> Dictionary:
	return portraits
