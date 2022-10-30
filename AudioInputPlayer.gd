extends AudioStreamPlayer

signal sound_changed(band, amp)

const VU_COUNT = 16
const FREQ_MAX = 11050.0

const WIDTH = 400
const HEIGHT = 100

const MIN_DB = 60

var spectrum
var band
var amp

func update():
	#warning-ignore:integer_division
#	print("---")
	var w = WIDTH / VU_COUNT
	var prev_hz = 0
	for i in range(1, VU_COUNT+1):
		var hz = i * FREQ_MAX / VU_COUNT;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var amp = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
		var height = amp * HEIGHT
#		draw_rect(Rect2(w * i, HEIGHT - height, w, height), Color.white)
		prev_hz = hz
		if amp > 0:
			emit_signal("sound_changed", i, amp)
#			print(i, ":", amp)
			


func _process(_delta):
	update()

func _on_AudioInputPlayer_sound_changed(band, amp):
	print(band, ":", amp)

func _ready():
#	connect("sound_changed", self, "_on_AudioInputPlayer_sound_changed")
	spectrum = AudioServer.get_bus_effect_instance(0,0)

