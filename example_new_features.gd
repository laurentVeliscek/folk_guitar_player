extends Node

"""
Examples demonstrating new FolkGuitarPlayer features:
- Swing
- Bass notes (B, b)
- Arpeggios (0-4)
- Double mutes (W, w)
- Chord transitions
"""

func _ready():
	print("\n" + "="*60)
	print("  NEW FEATURES EXAMPLES")
	print("="*60)

	example_swing()
	example_alternating_bass()
	example_fingerpicking_arpeggio()
	example_percussive_rhythm()
	example_chord_transitions()

	print("\n" + "="*60)
	print("  EXAMPLES COMPLETED")
	print("="*60 + "\n")


func example_swing():
	"""Example demonstrating swing feel."""
	print("\n--- Example 1: Swing (Jazz/Blues feel) ---")

	var player = FolkGuitarPlayer.new()

	# Configure swing
	player.config.swing_amount = 0.6  # 60% swing (between binary and ternary)

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]  # Em7

	# Classic swing pattern
	var pattern = StrumPattern.create("DuDuDuDuDuDuDuDu", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Swing amount: %.1f%%" % (player.config.swing_amount * 100))
	print("Generated %d notes with swing feel" % notes.size())
	print("Pattern: %s" % pattern.pattern)


func example_alternating_bass():
	"""Example using alternating bass notes (country/folk style)."""
	print("\n--- Example 2: Alternating Bass (Country style) ---")

	var player = FolkGuitarPlayer.new()

	# G chord
	var g = GuitarChord.new()
	g.time = 0.0
	g.beat_length = 4.0
	g.notes = [43, 47, 50, 55, 59, 62]  # G

	# C chord
	var c = GuitarChord.new()
	c.time = 4.0
	c.beat_length = 4.0
	c.notes = [36, 43, 48, 52, 55, 60]  # C

	# Alternating bass pattern (boom-chick style)
	# B = bass, D/u = strums
	var pattern = StrumPattern.create("B.Du.b.Du.B.Du.b", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([g, c])

	var notes = player.generate()

	print("Pattern: %s" % pattern.pattern)
	print("Generated %d notes (bass + strums)" % notes.size())

	# Count bass notes
	var bass_count = 0
	for note in notes:
		if note.string_index == -1:  # Bass notes have string_index = -1
			bass_count += 1

	print("Bass notes: %d" % bass_count)


func example_fingerpicking_arpeggio():
	"""Example using arpeggio notation for fingerpicking."""
	print("\n--- Example 3: Fingerpicking Arpeggio ---")

	var player = FolkGuitarPlayer.new()

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [36, 43, 48, 52, 55, 60]  # C major

	# Ascending-descending arpeggio pattern
	# 0 = lowest note, 4 = highest note
	var pattern = StrumPattern.create("01234321012343210", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Pattern: %s" % pattern.pattern)
	print("Generated %d arpeggio notes" % notes.size())

	# Show first 8 notes
	print("\nFirst 8 notes:")
	for i in range(min(8, notes.size())):
		print("  Note %d: pitch=%d, time=%.3f" % [i, notes[i].pitch, notes[i].position])


func example_percussive_rhythm():
	"""Example using double mutes for percussive effect."""
	print("\n--- Example 4: Percussive Rhythm (Double Mutes) ---")

	var player = FolkGuitarPlayer.new()

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 47, 52, 56, 59, 64]  # Em

	# Pattern with double mutes for percussion
	# W/w = double mute, D/u = strums, X = single mute
	var pattern = StrumPattern.create("D.uWu.dxu.D.uWu.", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	print("Pattern: %s" % pattern.pattern)
	print("Generated %d notes" % notes.size())

	# Count muted notes
	var muted_count = 0
	for note in notes:
		if note.duration < 0.1:
			muted_count += 1

	print("Muted notes (percussive): %d" % muted_count)


func example_chord_transitions():
	"""Example demonstrating chord transition gaps."""
	print("\n--- Example 5: Chord Transitions (realistic gaps) ---")

	var player = FolkGuitarPlayer.new()

	# Configure transition gap
	player.config.chord_transition_gap = 0.75  # 75% of normal duration

	# Em chord
	var em = GuitarChord.new()
	em.time = 0.0
	em.beat_length = 2.0
	em.notes = [40, 47, 52, 56, 59, 64]

	# Am chord (shares some notes with Em)
	var am = GuitarChord.new()
	am.time = 2.0
	am.beat_length = 2.0
	am.notes = [40, 45, 50, 53, 57, 64]

	# Pattern that lets notes ring
	var pattern = StrumPattern.create("D...............", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([em, am])

	var notes = player.generate()

	print("Transition gap: %.0f%%" % (player.config.chord_transition_gap * 100))
	print("Generated %d notes across 2 chords" % notes.size())

	# Analyze note durations around transition
	print("\nNote durations around chord change (at t=2.0):")
	for note in notes:
		if note.position >= 1.5 and note.position <= 2.5:
			print("  t=%.3f: duration=%.3f, pitch=%d" % [
				note.position, note.duration, note.pitch
			])
