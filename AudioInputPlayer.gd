extends AudioStreamPlayer

signal sound_changed(band, amp)

const VU_COUNT = 4
const FREQ_MAX = 11050.0

const WIDTH = 400
const HEIGHT = 100

const MIN_DB = 60

var spectrum
var band
var amp

var cmds : Array

func update():
	#warning-ignore:integer_division
#	print("---")
	var w = WIDTH / VU_COUNT
	var prev_hz = 0
	for i in range(1, VU_COUNT+1):
		var hz = i * FREQ_MAX / VU_COUNT;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length() if spectrum else 0
		var amp = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
		var height = amp * HEIGHT
		prev_hz = hz
		if amp > 0:
			emit_signal("sound_changed", i, amp)
#			print(i, ":", amp)
			

func _process(_delta):
	update()

func _on_AudioInputPlayer_sound_changed(band, amp):
	if not get_parent():
		return
	var main = get_parent()
	for cmd in cmds:
		for key in cmd.keys():
			# need for a check to avoid crash on removing cmds from band dictionaries
			if not cmd[key].has("addr"): return
			var addr = cmd[key]["addr"]
			var actor = cmd[key]["actor"].name
			var rangemin = cmd[key]["range"][0]
			var rangemax = cmd[key]["range"][1]
			var value = Helper.linlin(amp, 0.0, 1.0, rangemin, rangemax)
			main.evalOscCommand(addr, [actor, value], null)

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	for i in range(VU_COUNT):
		cmds.append({})
	connect("sound_changed", self, "_on_AudioInputPlayer_sound_changed")

func addSoundCmd( band, cmd, actor, minVal, maxVal ):
	var key = getKey(cmd, actor)
	cmds[min(int(band), len(cmds)-1)][key] = {"addr": cmd, "actor": actor, "range": [float(minVal), float(maxVal)]}
	print(cmds)

# removes all commands for BAND
func removeAllSoundCmds( band ):
	cmds[min(band, len(cmds)-1)] = {}
	print(cmds)

# removes only the CMD for ACTOR in BAND
func removeSoundCmd( band, cmd, actor ):
	var key = getKey(cmd, actor)
	cmds[min(int(band), len(cmds)-1)].erase(key)
	print(cmds)

func getKey(cmd, actor):
	return "%s/%s" % [cmd, actor.name]

func eventToOsc(cmdsList, value, inmin, inmax):
	if not get_parent():
		return
	var main = get_parent()
	for addr in cmdsList.keys():
		if not addr.begins_with("/"):
			addr = "/" + addr
		var minval = cmdsList[addr][0]
		var maxval = cmdsList[addr][1]
		value  = $Helper.linlin(value, inmin, inmax, minval, maxval)
		Logger.verbose("sending msg from MIDI: %s %f" % [addr, value])
		main.evalOscCommand(addr, [name, value], null)
