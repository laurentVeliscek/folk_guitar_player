extends Node

"""
Example usage of FolkGuitarPlayer with the new API.

Demonstrates:
- Creating chords with different sizes (4, 5, 6 notes)
- Setting rhythm pattern at player level
- Generating MIDI notes
"""

func _ready():
	example_basic_pattern()
	print("\n" + "="*60 + "\n")
	example_variable_chord_sizes()


func example_basic_pattern():
	"""Example with 6-string chords and a simple pattern."""
	print("=== Example 1: Basic 6-string chords ===\n")

	# Create chord grid
	var chords = []

	# Em chord at time 0, lasting 4 beats
	var em = GuitarChord.new()
	em.time = 0.0
	em.beat_length = 4.0
	em.notes = [40, 45, 50, 55, 59, 64]  # E-B-E-G-B-E
	chords.append(em)

	# Am chord at time 4, lasting 4 beats
	var am = GuitarChord.new()
	am.time = 4.0
	am.beat_length = 4.0
	am.notes = [40, 45, 50, 53, 57, 64]  # E-A-E-A-C-E
	chords.append(am)

	# Create player
	var player = FolkGuitarPlayer.new()
	player.rhythm_pattern = "DuDuD Du"  # Folk strum pattern
	player.step_beat_length = 0.5       # Eighth notes
	player.set_chord_grid(chords)

	# Generate MIDI notes
	var notes = player.generate()

	print("Generated %d MIDI notes" % notes.size())
	print("Pattern: %s" % player.rhythm_pattern)
	print("Step length: %s beats" % player.step_beat_length)

	# Show first few notes
	print("\nFirst 5 notes:")
	for i in range(min(5, notes.size())):
		var note = notes[i]
		print("  Pitch: %3d | Time: %6.3f | Duration: %5.3f | Velocity: %3d" % [
			note.pitch, note.position, note.duration, note.velocity
		])

	player.print_notes()


func example_variable_chord_sizes():
	"""Example with chords of different sizes (4, 5, 6 notes)."""
	print("=== Example 2: Variable chord sizes ===\n")

	var chords = []

	# 6-note chord
	var chord_6 = GuitarChord.new()
	chord_6.time = 0.0
	chord_6.beat_length = 2.0
	chord_6.notes = [40, 45, 50, 55, 59, 64]
	chords.append(chord_6)

	# 5-note chord
	var chord_5 = GuitarChord.new()
	chord_5.time = 2.0
	chord_5.beat_length = 2.0
	chord_5.notes = [45, 50, 53, 57, 64]  # Missing low E
	chords.append(chord_5)

	# 4-note chord (using midiNotes instead of notes)
	var chord_4 = GuitarChord.new()
	chord_4.time = 4.0
	chord_4.beat_length = 2.0
	chord_4.midiNotes = PoolIntArray([50, 55, 59, 64])
	chords.append(chord_4)

	# Create player
	var player = FolkGuitarPlayer.new()
	player.rhythm_pattern = "D d "  # Down-down-rest
	player.step_beat_length = 0.5
	player.set_chord_grid(chords)

	# Generate
	var notes = player.generate()

	print("Chord 1: %d notes" % chord_6.get_notes().size())
	print("Chord 2: %d notes" % chord_5.get_notes().size())
	print("Chord 3: %d notes" % chord_4.get_notes().size())
	print("\nTotal MIDI notes generated: %d" % notes.size())

	# Show statistics
	var stats = player.get_stats()
	print("\nStatistics:")
	print("  Velocity range: %d - %d (avg: %.1f)" % [
		stats.velocity_min, stats.velocity_max, stats.velocity_avg
	])
	print("  Duration range: %.3f - %.3f (avg: %.3f)" % [
		stats.duration_min, stats.duration_max, stats.duration_avg
	])
