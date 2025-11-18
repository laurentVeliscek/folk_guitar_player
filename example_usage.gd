extends Node

"""
Example usage of FolkGuitarPlayer with the new pattern system.

Demonstrates:
- Creating 16-step patterns with StrumPattern
- Using pattern sequences with different step lengths
- Config overrides for dynamic changes
- New symbols (x, F, f)
"""

func _ready():
	example_basic_pattern()
	print("\n" + "="*60 + "\n")
	example_pattern_sequence()
	print("\n" + "="*60 + "\n")
	example_config_override()
	print("\n" + "="*60 + "\n")
	example_new_symbols()


func example_basic_pattern():
	"""Example with 6-string chords and a simple 16-step pattern."""
	print("=== Example 1: Basic 16-step pattern ===\n")

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

	# Create player with a folk pattern
	var player = FolkGuitarPlayer.new()

	# D.uDudu D.uDudu  (classic folk strum, 16th notes)
	var pattern = StrumPattern.create("D.uDudu D.uDudu ", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid(chords)

	# Generate MIDI notes
	var notes = player.generate()

	print("Generated %d MIDI notes" % notes.size())
	print("Pattern: %s" % pattern.pattern)
	print("Step length: %s beats (16th notes)" % pattern.step_beat_length)

	# Show first few notes
	print("\nFirst 5 notes:")
	for i in range(min(5, notes.size())):
		var note = notes[i]
		print("  Pitch: %3d | Time: %6.3f | Duration: %5.3f | Velocity: %3d" % [
			note.pitch, note.position, note.duration, note.velocity
		])


func example_pattern_sequence():
	"""Example with multiple patterns in sequence."""
	print("=== Example 2: Pattern sequence with different densities ===\n")

	var chords = []

	# G chord for 8 beats
	var g = GuitarChord.new()
	g.time = 0.0
	g.beat_length = 8.0
	g.notes = [43, 47, 50, 55, 59, 62]
	chords.append(g)

	# Create player
	var player = FolkGuitarPlayer.new()

	# First pattern: sparse (quarter notes feel)
	# Step = 0.5 (8th notes), pattern duration = 8 beats
	var p1 = StrumPattern.create("D...d...D...d...", 0.5)

	# Second pattern: dense (16th notes feel)
	# Step = 0.25 (16th notes), pattern duration = 4 beats
	var p2 = StrumPattern.create("DuduDuduDuduDudu", 0.25)

	player.pattern_sequence = [p1, p2]
	player.set_chord_grid(chords)

	var notes = player.generate()

	print("Pattern 1: '%s' (%.2f beats)" % [p1.pattern, p1.get_duration()])
	print("Pattern 2: '%s' (%.2f beats)" % [p2.pattern, p2.get_duration()])
	print("Total patterns duration: %.2f beats" % (p1.get_duration() + p2.get_duration()))
	print("Chord duration: %.2f beats" % g.beat_length)
	print("\nGenerated %d MIDI notes" % notes.size())

	# Show statistics
	var stats = player.get_stats()
	print("\nStatistics:")
	print("  Velocity range: %d - %d (avg: %.1f)" % [
		stats.velocity_min, stats.velocity_max, stats.velocity_avg
	])


func example_config_override():
	"""Example using config_override for dynamic changes."""
	print("=== Example 3: Config override (soft -> loud) ===\n")

	var chords = []

	# Single chord for 8 beats
	var em = GuitarChord.new()
	em.time = 0.0
	em.beat_length = 8.0
	em.notes = [40, 47, 52, 56, 59, 64]
	chords.append(em)

	var player = FolkGuitarPlayer.new()

	# First pattern: soft (low velocity)
	var p_soft = StrumPattern.create("D...d...D...d...", 0.25, [
		{"velocity_down_base": 60},
		{"velocity_down_light": 45}
	])

	# Second pattern: loud (high velocity, accent)
	var p_loud = StrumPattern.create("D...d...D...d...", 0.25, [
		{"velocity_down_base": 120},
		{"velocity_down_light": 90},
		{"accent_downbeat_factor": 1.3}
	])

	player.pattern_sequence = [p_soft, p_loud]
	player.set_chord_grid(chords)

	var notes = player.generate()

	print("Pattern 1: Soft (velocity_down_base=60)")
	print("Pattern 2: Loud (velocity_down_base=120)")
	print("\nGenerated %d MIDI notes" % notes.size())

	# Analyze velocity progression
	var first_half = []
	var second_half = []
	for note in notes:
		if note.position < 4.0:
			first_half.append(note.velocity)
		else:
			second_half.append(note.velocity)

	var avg1 = 0.0
	for v in first_half:
		avg1 += v
	avg1 /= max(1, first_half.size())

	var avg2 = 0.0
	for v in second_half:
		avg2 += v
	avg2 /= max(1, second_half.size())

	print("\nVelocity analysis:")
	print("  First pattern avg: %.1f" % avg1)
	print("  Second pattern avg: %.1f" % avg2)
	print("  Crescendo: %s" % ("Yes" if avg2 > avg1 else "No"))


func example_new_symbols():
	"""Example demonstrating new symbols: x, F, f."""
	print("=== Example 4: New symbols (x, F, f) ===\n")

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]

	var player = FolkGuitarPlayer.new()

	# Pattern with all new symbols:
	# F = strong flam (DU), f = light flam (du)
	# x = light mute, X = strong mute
	var pattern = StrumPattern.create("D.uFx.ufX.uD.ud.", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Pattern: '%s'" % pattern.pattern)
	print("Explanation:")
	print("  D = Down strong")
	print("  u = up light")
	print("  F = Flam DU (strong)")
	print("  x = mute light")
	print("  f = flam du (light)")
	print("  X = mute strong")
	print("\nGenerated %d MIDI notes" % notes.size())

	# Count different types
	var count_by_pos = {}
	for note in notes:
		var pos_key = "%.3f" % note.position
		if not count_by_pos.has(pos_key):
			count_by_pos[pos_key] = 0
		count_by_pos[pos_key] += 1

	print("\nNotes per time position (6 = single strum, 12 = flam):")
	var positions = count_by_pos.keys()
	positions.sort()
	for i in range(min(8, positions.size())):
		var pos = positions[i]
		print("  Time %.3f: %d notes" % [float(pos), count_by_pos[pos]])
