extends AudioStreamPlayer2D

onready var bus_index = AudioServer.get_bus_index(self.bus)
onready var pitch_shift = AudioServer.get_bus_effect(bus_index, 0)

func change_pitch():
	pitch_shift.pitch_scale = rand_range(1, 1.5)