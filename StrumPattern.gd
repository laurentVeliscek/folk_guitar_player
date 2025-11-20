extends Reference
class_name StrumPattern

"""
Represents a 16-step strumming pattern with its own timing and configuration.

Pattern symbols:
  Strums:
	D = Down fort (strong downstroke)
	d = Down léger (light downstroke)
	U = Up fort (strong upstroke)
	u = Up léger (light upstroke)

  Mutes:
	X = Muté fort (strong muted strum)
	x = Muté léger (light muted strum, shorter and softer)
	W = Double mute fort (two fast muted strums: down+up, strong)
	w = Double mute léger (two fast muted strums: down+up, light)

  Flams:
	F = Flam DU (rapid Down-Up, strong, legato)
	f = Flam du (rapid down-up, light, legato)

  Bass & Arpeggios:
	B = Basse principale (main bass note - lowest)
	b = Basse alternative (alternative bass note)
	0, 1, 2, 3, 4 = Arpeggio notes (0=lowest, 4=highest)

  Other:
	. = Laisser sonner (let ring / sustain)
	' ' = Silence (space = rest)

Usage:
	var pattern = StrumPattern.new()
	pattern.pattern = "D.uDudu D.uDudu "
	pattern.step_beat_length = 0.25  # 16th notes
	pattern.config_override = {"velocity_down_base": 110, "swing_amount": 0.3}

Examples:
	"D.uDudu D.uDudu "  # Classic folk strum
	"B...b...B...b..."  # Alternating bass (country/folk)
	"0.1.2.3.4.3.2.1."  # Ascending/descending arpeggio
	"D.uWu.d.X.uWu.d."  # Rhythmic with double mutes
"""




# The 16-character pattern string
var pattern: String = "D...d...D...d..." setget set_pattern

# Duration of each step in beats
var step_beat_length: float = 0.5

# Dictionary to override FolkGuitarPlayer.config during this pattern
# Example: {"velocity_down_base": 110, "pick_position": 0.5}
var config_override: Dictionary = {}

func clone()->StrumPattern:
	var s:StrumPattern = get_script().new()
	s.pattern = pattern
	s.step_beat_length = step_beat_length
	s.config_override = config_override.duplicate(true)
	return s

func set_pattern(value: String) -> void:
	if value.length() != 16:
		push_warning("StrumPattern: Pattern must be exactly 16 characters, got %d. Padding/truncating." % value.length())
		if value.length() < 16:
			value = value + " ".repeat(16 - value.length())
		else:
			value = value.substr(0, 16)
	pattern = value


func get_duration() -> float:
	"""Returns the total duration of this pattern in beats."""
	return 16.0 * step_beat_length


