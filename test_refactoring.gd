extends SceneTree

"""
Test script for FolkGuitarPlayer with the new pattern system.
Run with: godot --script test_refactoring.gd
"""

func _init():
	print("="*60)
	print("Testing FolkGuitarPlayer - Pattern Strumming System")
	print("="*60 + "\n")

	var all_passed = true

	all_passed = test_strum_pattern() and all_passed
	all_passed = test_guitar_chord() and all_passed
	all_passed = test_folk_guitar_player_basic() and all_passed
	all_passed = test_variable_chord_sizes() and all_passed
	all_passed = test_pattern_looping() and all_passed
	all_passed = test_duration_calculation() and all_passed
	all_passed = test_config_override() and all_passed
	all_passed = test_new_symbols() and all_passed
	all_passed = test_pitch_overlap() and all_passed

	print("\n" + "="*60)
	if all_passed:
		print("All tests PASSED")
	else:
		print("Some tests FAILED")
	print("="*60)

	quit()


func test_strum_pattern() -> bool:
	print("\n[TEST] StrumPattern structure")

	var pattern = StrumPattern.new()
	var passed = true

	# Test default pattern length
	if pattern.pattern.length() != 16:
		print("  FAIL: Default pattern should be 16 chars, got %d" % pattern.pattern.length())
		passed = false
	else:
		print("  OK: Default pattern is 16 characters")

	# Test pattern setter with short string
	pattern.pattern = "D.u."
	if pattern.pattern.length() != 16:
		print("  FAIL: Short pattern not padded to 16 chars")
		passed = false
	else:
		print("  OK: Short pattern padded to 16 characters")

	# Test pattern setter with long string
	pattern.pattern = "D.uDudu D.uDudu XX"
	if pattern.pattern.length() != 16:
		print("  FAIL: Long pattern not truncated to 16 chars")
		passed = false
	else:
		print("  OK: Long pattern truncated to 16 characters")

	# Test duration calculation
	pattern.step_beat_length = 0.25
	var expected_duration = 16 * 0.25  # 4 beats
	if abs(pattern.get_duration() - expected_duration) > 0.001:
		print("  FAIL: Duration calculation wrong")
		passed = false
	else:
		print("  OK: Duration calculation correct (%.2f beats)" % pattern.get_duration())

	# Test factory method
	var p2 = StrumPattern.create("D...d...D...d...", 0.5, [{"velocity_down_base": 110}])
	if p2.pattern.length() != 16 or p2.step_beat_length != 0.5 or p2.config_override.size() != 1:
		print("  FAIL: Factory method not working correctly")
		passed = false
	else:
		print("  OK: Factory method works correctly")

	return passed


func test_guitar_chord() -> bool:
	print("\n[TEST] GuitarChord structure")

	var chord = GuitarChord.new()
	chord.time = 2.0
	chord.beat_length = 4.0
	chord.notes = [40, 45, 50]

	var passed = true

	if chord.time != 2.0:
		print("  FAIL: time property")
		passed = false
	else:
		print("  OK: time property")

	if chord.beat_length != 4.0:
		print("  FAIL: beat_length property")
		passed = false
	else:
		print("  OK: beat_length property")

	var notes = chord.get_notes()
	if notes.size() != 3:
		print("  FAIL: get_notes() size")
		passed = false
	else:
		print("  OK: get_notes() returns correct array")

	# Test midiNotes alternative
	var chord2 = GuitarChord.new()
	chord2.midiNotes = PoolIntArray([60, 64, 67])
	var notes2 = chord2.get_notes()
	if notes2.size() != 3:
		print("  FAIL: midiNotes not working")
		passed = false
	else:
		print("  OK: midiNotes alternative works")

	return passed


func test_folk_guitar_player_basic() -> bool:
	print("\n[TEST] FolkGuitarPlayer basic functionality")

	var player = FolkGuitarPlayer.new()
	var passed = true

	# Test pattern_sequence property
	if not "pattern_sequence" in player:
		print("  FAIL: pattern_sequence property missing")
		passed = false
	else:
		print("  OK: pattern_sequence property exists")

	# Test with simple chord and pattern
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 45, 50, 55, 59, 64]

	var pattern = StrumPattern.create("D...d...D...d...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	if notes.size() == 0:
		print("  FAIL: generate() returned no notes")
		passed = false
	else:
		print("  OK: generate() produces notes (%d notes)" % notes.size())

	# Each note should have required fields
	if notes.size() > 0:
		var note = notes[0]
		if not ("pitch" in note and "position" in note and "duration" in note and "velocity" in note):
			print("  FAIL: note missing required fields")
			passed = false
		else:
			print("  OK: notes have required fields")

	return passed


func test_variable_chord_sizes() -> bool:
	print("\n[TEST] Variable chord sizes (4, 5, 6 notes)")

	var player = FolkGuitarPlayer.new()
	var pattern = StrumPattern.create("D               ", 1.0)  # Single D per 16 steps
	player.pattern_sequence = [pattern]

	var chords = []

	# 6-note chord
	var c6 = GuitarChord.new()
	c6.time = 0.0
	c6.beat_length = 16.0
	c6.notes = [40, 45, 50, 55, 59, 64]
	chords.append(c6)

	# 5-note chord
	var c5 = GuitarChord.new()
	c5.time = 16.0
	c5.beat_length = 16.0
	c5.notes = [45, 50, 55, 59, 64]
	chords.append(c5)

	# 4-note chord
	var c4 = GuitarChord.new()
	c4.time = 32.0
	c4.beat_length = 16.0
	c4.notes = [50, 55, 59, 64]
	chords.append(c4)

	player.set_chord_grid(chords)
	var notes = player.generate()

	var passed = true

	if notes.size() == 0:
		print("  FAIL: No notes generated")
		passed = false
	else:
		print("  OK: Generated %d notes from mixed chord sizes" % notes.size())

	# Pattern "D" = 1 strum per pattern (16 beats)
	# Total duration = 48 beats = 3 patterns
	# Each pattern has 1 D strum
	# 6 + 5 + 4 = 15 notes total
	if notes.size() != 15:
		print("  FAIL: Expected 15 notes (6+5+4), got %d" % notes.size())
		passed = false
	else:
		print("  OK: Correct number of notes for variable chord sizes")

	return passed


func test_pattern_looping() -> bool:
	print("\n[TEST] Pattern looping")

	var player = FolkGuitarPlayer.new()

	# Pattern: D at step 0, u at step 8 = 2 strums per pattern
	var pattern = StrumPattern.create("D.......u.......", 0.5)  # 16 * 0.5 = 8 beats
	player.pattern_sequence = [pattern]

	# Chord lasting 16 beats = 2 pattern loops
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 16.0
	chord.notes = [40, 45, 50, 55, 59, 64]

	player.set_chord_grid([chord])
	var notes = player.generate()

	var passed = true

	# 2 pattern loops * 2 strums * 6 strings = 24 notes
	if notes.size() != 24:
		print("  FAIL: Expected 24 notes, got %d" % notes.size())
		passed = false
	else:
		print("  OK: Pattern loops correctly (%d notes)" % notes.size())

	return passed


func test_duration_calculation() -> bool:
	print("\n[TEST] Duration calculation (max of chords vs patterns)")

	var player = FolkGuitarPlayer.new()
	var passed = true

	# Test 1: Patterns longer than chords
	print("  Subtest 1: Patterns > Chords")
	var chord1 = GuitarChord.new()
	chord1.time = 0.0
	chord1.beat_length = 4.0  # 4 beats
	chord1.notes = [40, 45, 50, 55, 59, 64]

	# 2 patterns of 4 beats each = 8 beats total
	var p1 = StrumPattern.create("D...............", 0.25)  # 4 beats
	var p2 = StrumPattern.create("D...............", 0.25)  # 4 beats
	player.pattern_sequence = [p1, p2]
	player.set_chord_grid([chord1])

	var notes1 = player.generate()
	# Should have 2 D strums (one per pattern) = 12 notes
	if notes1.size() != 12:
		print("    FAIL: Expected 12 notes when patterns > chords, got %d" % notes1.size())
		passed = false
	else:
		print("    OK: Correct notes when patterns longer than chords")

	# Test 2: Chords longer than patterns
	print("  Subtest 2: Chords > Patterns")
	var player2 = FolkGuitarPlayer.new()
	var chord2 = GuitarChord.new()
	chord2.time = 0.0
	chord2.beat_length = 8.0  # 8 beats
	chord2.notes = [40, 45, 50, 55, 59, 64]

	# 1 pattern of 4 beats
	var p3 = StrumPattern.create("D...............", 0.25)  # 4 beats
	player2.pattern_sequence = [p3]
	player2.set_chord_grid([chord2])

	var notes2 = player2.generate()
	# Should loop pattern twice = 2 D strums = 12 notes
	if notes2.size() != 12:
		print("    FAIL: Expected 12 notes when chords > patterns, got %d" % notes2.size())
		passed = false
	else:
		print("    OK: Correct notes when chords longer than patterns")

	return passed


func test_config_override() -> bool:
	print("\n[TEST] Config override")

	var player = FolkGuitarPlayer.new()
	var passed = true

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 8.0
	chord.notes = [40, 45, 50, 55, 59, 64]

	# Pattern with velocity override
	var p1 = StrumPattern.create("D...............", 0.25, [{"velocity_down_base": 50}])
	# Pattern without override (should use default)
	var p2 = StrumPattern.create("D...............", 0.25, [])

	player.pattern_sequence = [p1, p2]
	player.set_chord_grid([chord])

	var notes = player.generate()

	# Check velocities - first pattern should be lower
	var first_pattern_velocities = []
	var second_pattern_velocities = []

	for note in notes:
		if note.position < 4.0:
			first_pattern_velocities.append(note.velocity)
		else:
			second_pattern_velocities.append(note.velocity)

	if first_pattern_velocities.empty() or second_pattern_velocities.empty():
		print("  FAIL: Could not separate notes by pattern")
		passed = false
	else:
		var avg1 = 0.0
		for v in first_pattern_velocities:
			avg1 += v
		avg1 /= first_pattern_velocities.size()

		var avg2 = 0.0
		for v in second_pattern_velocities:
			avg2 += v
		avg2 /= second_pattern_velocities.size()

		if avg1 >= avg2:
			print("  FAIL: Config override not applied (avg1=%.1f, avg2=%.1f)" % [avg1, avg2])
			passed = false
		else:
			print("  OK: Config override applied correctly (avg1=%.1f < avg2=%.1f)" % [avg1, avg2])

	return passed


func test_new_symbols() -> bool:
	print("\n[TEST] New symbols (x, F, f)")

	var player = FolkGuitarPlayer.new()
	var passed = true

	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 45, 50, 55, 59, 64]

	# Test x (light mute)
	print("  Subtest: 'x' (light mute)")
	var p_x = StrumPattern.create("x...............", 0.25)
	player.pattern_sequence = [p_x]
	player.set_chord_grid([chord])
	var notes_x = player.generate()

	if notes_x.size() != 6:
		print("    FAIL: 'x' should produce 6 notes, got %d" % notes_x.size())
		passed = false
	else:
		# Check duration is short (muted)
		var is_short = true
		for note in notes_x:
			if note.duration > 0.05:
				is_short = false
				break
		if is_short:
			print("    OK: 'x' produces short muted notes")
		else:
			print("    FAIL: 'x' notes not short enough")
			passed = false

	# Test F (strong flam)
	print("  Subtest: 'F' (strong flam DU)")
	player.clear()
	var p_F = StrumPattern.create("F...............", 0.25)
	player.pattern_sequence = [p_F]
	player.set_chord_grid([chord])
	var notes_F = player.generate()

	# F = 2 strums (D + U) = 12 notes
	if notes_F.size() != 12:
		print("    FAIL: 'F' should produce 12 notes (2 strums), got %d" % notes_F.size())
		passed = false
	else:
		print("    OK: 'F' produces 12 notes (flam)")

	# Test f (light flam)
	print("  Subtest: 'f' (light flam du)")
	player.clear()
	var p_f = StrumPattern.create("f...............", 0.25)
	player.pattern_sequence = [p_f]
	player.set_chord_grid([chord])
	var notes_f = player.generate()

	if notes_f.size() != 12:
		print("    FAIL: 'f' should produce 12 notes (2 strums), got %d" % notes_f.size())
		passed = false
	else:
		# Check velocity is lower than F
		var avg_f = 0.0
		for note in notes_f:
			avg_f += note.velocity
		avg_f /= notes_f.size()

		var avg_F = 0.0
		for note in notes_F:
			avg_F += note.velocity
		avg_F /= notes_F.size()

		if avg_f < avg_F:
			print("    OK: 'f' produces lighter flam (vel=%.1f < %.1f)" % [avg_f, avg_F])
		else:
			print("    WARN: 'f' velocity not lower than 'F' (%.1f vs %.1f)" % [avg_f, avg_F])

	return passed


func test_pitch_overlap() -> bool:
	print("\n[TEST] Pitch overlap handling")

	var player = FolkGuitarPlayer.new()
	var passed = true

	# Create chord with same pitch on multiple strings (e.g., octave E)
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 2.0
	chord.notes = [40, 45, 50, 55, 59, 64]  # E on strings 0 and 5 is different octaves

	# Let's use a chord where same pitch appears
	var chord2 = GuitarChord.new()
	chord2.time = 0.0
	chord2.beat_length = 2.0
	chord2.notes = [64, 64, 64, 64, 64, 64]  # Same pitch on all strings

	# Pattern with 2 strums close together
	var pattern = StrumPattern.create("D.D.............", 0.125)  # 2 strums at 0 and 0.25
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord2])

	var notes = player.generate()

	# Check that no notes overlap
	var has_overlap = false
	for i in range(notes.size()):
		var note1 = notes[i]
		for j in range(i + 1, notes.size()):
			var note2 = notes[j]
			if note1.pitch == note2.pitch:
				var end1 = note1.position + note1.duration
				if end1 > note2.position + 0.001:  # Small tolerance
					has_overlap = true
					print("    Overlap detected: pitch %d, note1 ends at %.3f, note2 starts at %.3f" % [
						note1.pitch, end1, note2.position
					])
					break
		if has_overlap:
			break

	if has_overlap:
		print("  FAIL: Pitch overlap detected")
		passed = false
	else:
		print("  OK: No pitch overlap (notes properly truncated)")

	return passed
