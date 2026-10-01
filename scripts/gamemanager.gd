extends Node

@onready var scorelabel: Label = $"../TileMapLayers/Labels/Scorelabel"

var score = 0
func add_point():
	score += 1
	scorelabel.text = "YOU ATE " + str(score) + "COINS..."
