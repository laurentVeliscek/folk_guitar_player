extends Reference
class_name StrumPattern

"""
Represents a 16-step strumming pattern with its own timing and configuration.

Pattern symbols:
  D = Down fort (strong downstroke)
  d = Down léger (light downstroke)
  U = Up fort (strong upstroke)
  u = Up léger (light upstroke)
  X = Muté fort (strong muted strum)
  x = Muté léger (light muted strum, shorter and softer)
  F = Flam DU (rapid Down-Up, strong, legato)
  f = Flam du (rapid down-up, light, legato)
  . = Laisser sonner (let ring / sustain)
  ' ' = Silence (space = rest)

Usage:
	var pattern = StrumPattern.new()
	pattern.pattern = "D.uDudu D.uDudu "
	pattern.step_beat_length = 0.25  # 16th notes
	pattern.config_override = [{"velocity_down_base": 110}]
"""

# The 16-character pattern string
var pattern: String = "D...d...D...d..." setget set_pattern

# Duration of each step in beats
var step_beat_length: float = 0.25

# Array of dictionaries to override FolkGuitarPlayer.config during this pattern
# Example: [{"velocity_down_base": 110}, {"pick_position": 0.5}]
var config_override: Array = []


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


func duplicate() -> StrumPattern:
	"""Creates a copy of this pattern."""
	var copy = StrumPattern.new()
	copy.pattern = pattern
	copy.step_beat_length = step_beat_length
	copy.config_override = config_override.duplicate(true)
	return copy


static func create(p_pattern: String, p_step_beat_length: float = 0.25, p_config_override: Array = []) -> StrumPattern:
	"""Factory method to create a pattern with all parameters."""
	var sp = StrumPattern.new()
	sp.pattern = p_pattern
	sp.step_beat_length = p_step_beat_length
	sp.config_override = p_config_override
	return sp
