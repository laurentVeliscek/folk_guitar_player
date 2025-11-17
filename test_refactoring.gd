extends SceneTree

"""
Simple test script to validate the refactoring.
Run with: godot --script test_refactoring.gd
"""

func _init():
	print("="*60)
	print("Testing FolkGuitarPlayer Refactoring")
	print("="*60 + "\n")

	var all_passed = true

	all_passed = test_guitar_chord() and all_passed
	all_passed = test_folk_guitar_player_basic() and all_passed
	all_passed = test_variable_chord_sizes() and all_passed
	all_passed = test_pattern_looping() and all_passed

	print("\n" + "="*60)
	if all_passed:
		print("✓ All tests PASSED")
	else:
		print("✗ Some tests FAILED")
	print("="*60)

	quit()


func test_guitar_chord() -> bool:
	print("\n[TEST] GuitarChord structure")

	var chord = GuitarChord.new()
	chord.time = 2.0
	chord.beat_length = 4.0
	chord.notes = [40, 45, 50]

	var passed = true

	# Test properties
	if chord.time != 2.0:
		print("  ✗ FAIL: time property")
		passed = false
	else:
		print("  ✓ time property")

	if chord.beat_length != 4.0:
		print("  ✗ FAIL: beat_length property")
		passed = false
	else:
		print("  ✓ beat_length property")

	# Test get_notes()
	var notes = chord.get_notes()
	if notes.size() != 3:
		print("  ✗ FAIL: get_notes() size")
		passed = false
	else:
		print("  ✓ get_notes() returns correct array")

	# Test midiNotes alternative
	var chord2 = GuitarChord.new()
	chord2.midiNotes = PoolIntArray([60, 64, 67])
	var notes2 = chord2.get_notes()
	if notes2.size() != 3:
		print("  ✗ FAIL: midiNotes not working")
		passed = false
	else:
		print("  ✓ midiNotes alternative works")

	return passed


func test_folk_guitar_player_basic() -> bool:
	print("\n[TEST] FolkGuitarPlayer basic functionality")

	var player = FolkGuitarPlayer.new()
	var passed = true

	# Test properties
	if not "rhythm_pattern" in player:
		print("  ✗ FAIL: rhythm_pattern property missing")
		passed = false
	else:
		print("  ✓ rhythm_pattern property exists")

	if not "step_beat_length" in player:
		print("  ✗ FAIL: step_beat_length property missing")
		passed = false
	else:
		print("  ✓ step_beat_length property exists")

	# Test with simple chord
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 2.0
	chord.notes = [40, 45, 50, 55, 59, 64]

	player.rhythm_pattern = "D "
	player.step_beat_length = 0.5
	player.set_chord_grid([chord])

	var notes = player.generate()

	if notes.size() == 0:
		print("  ✗ FAIL: generate() returned no notes")
		passed = false
	else:
		print("  ✓ generate() produces notes (%d notes)" % notes.size())

	# Each note should have required fields
	if notes.size() > 0:
		var note = notes[0]
		if not ("pitch" in note and "position" in note and "duration" in note and "velocity" in note):
			print("  ✗ FAIL: note missing required fields")
			passed = false
		else:
			print("  ✓ notes have required fields")

	return passed


func test_variable_chord_sizes() -> bool:
	print("\n[TEST] Variable chord sizes (4, 5, 6 notes)")

	var player = FolkGuitarPlayer.new()
	player.rhythm_pattern = "D"
	player.step_beat_length = 1.0

	var chords = []

	# 6-note chord
	var c6 = GuitarChord.new()
	c6.time = 0.0
	c6.beat_length = 1.0
	c6.notes = [40, 45, 50, 55, 59, 64]
	chords.append(c6)

	# 5-note chord
	var c5 = GuitarChord.new()
	c5.time = 1.0
	c5.beat_length = 1.0
	c5.notes = [45, 50, 55, 59, 64]
	chords.append(c5)

	# 4-note chord
	var c4 = GuitarChord.new()
	c4.time = 2.0
	c4.beat_length = 1.0
	c4.notes = [50, 55, 59, 64]
	chords.append(c4)

	player.set_chord_grid(chords)
	var notes = player.generate()

	var passed = true

	if notes.size() == 0:
		print("  ✗ FAIL: No notes generated")
		passed = false
	else:
		print("  ✓ Generated %d notes from mixed chord sizes" % notes.size())

	# Should have generated notes for all three chords
	# Pattern "D" = 1 strum per chord
	# 6 + 5 + 4 = 15 notes total
	if notes.size() != 15:
		print("  ✗ FAIL: Expected 15 notes (6+5+4), got %d" % notes.size())
		passed = false
	else:
		print("  ✓ Correct number of notes for variable chord sizes")

	return passed


func test_pattern_looping() -> bool:
	print("\n[TEST] Pattern looping across chord grid")

	var player = FolkGuitarPlayer.new()
	player.rhythm_pattern = "Du"  # 2-step pattern
	player.step_beat_length = 1.0  # 1 beat per step

	# Single chord lasting 4 beats
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0  # Should loop pattern twice (Du Du)
	chord.notes = [40, 45, 50, 55, 59, 64]

	player.set_chord_grid([chord])
	var notes = player.generate()

	var passed = true

	# Pattern "Du" with step_length 1.0 over 4 beats = 2 loops = 2 strums
	# Each strum has 6 notes = 12 notes total
	if notes.size() != 12:
		print("  ✗ FAIL: Expected 12 notes (2 strums × 6 strings), got %d" % notes.size())
		passed = false
	else:
		print("  ✓ Pattern loops correctly (%d notes)" % notes.size())

	# Check that notes span the full chord duration
	if notes.size() > 0:
		var last_note = notes[notes.size() - 1]
		if last_note.position < 2.0:
			print("  ✗ FAIL: Pattern didn't loop to end of chord")
			passed = false
		else:
			print("  ✓ Pattern looped through full chord duration")

	return passed
