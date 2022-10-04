extends Node

const CardsClass = preload("res://Scripts/Card.gd")
onready var card_slots = $GridContainer
var cards_allowed = 1
var cards_opened = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$GridContainer.visible = true
	var cards = card_slots.get_children()
	for i in range(cards.size()):
		cards[i].connect("gui_input", self, "slot_gui_input", [cards[i]])


func slot_gui_input(event: InputEvent, card: CardsClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if cards_allowed > cards_opened:
				card.open()
				cards_opened += 1
			else:
				queue_free()
