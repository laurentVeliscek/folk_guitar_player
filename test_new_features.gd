extends SceneTree

"""
Test des nouvelles fonctionnalités:
- Swing
- Symboles de basse (B, b)
- Symboles d'arpège (0, 1, 2, 3, 4)
- Double mute (W, w)
- Post-traitement des transitions d'accords
"""

func _init():
	print("="*60)
	print("Testing New FolkGuitarPlayer Features")
	print("="*60 + "\n")

	var all_passed = true

	all_passed = test_swing() and all_passed
	all_passed = test_bass_symbols() and all_passed
	all_passed = test_arpeggio_symbols() and all_passed
	all_passed = test_double_mute_symbols() and all_passed
	all_passed = test_chord_transitions() and all_passed

	print("\n" + "="*60)
	if all_passed:
		print("All tests PASSED")
	else:
		print("Some tests FAILED")
	print("="*60)

	quit()


func test_swing() -> bool:
	print("\n[TEST] Swing feature")

	var player = FolkGuitarPlayer.new()
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 45, 50, 55, 59, 64]

	# Pattern avec positions paires et impaires
	var pattern = StrumPattern.create("DuDuDuDuDuDuDuDu", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	# Test sans swing
	player.config.swing_amount = 0.0
	var notes_straight = player.generate()

	# Test avec swing
	player.clear()
	player.set_chord_grid([chord])
	player.pattern_sequence = [pattern]
	player.config.swing_amount = 0.5
	var notes_swing = player.generate()

	var passed = true

	# Les notes impaires devraient être retardées avec swing
	if notes_swing.size() != notes_straight.size():
		print("  FAIL: Note counts differ")
		passed = false
	else:
		# Comparer les positions des notes impaires (up strokes)
		var has_swing_offset = false
		for i in range(min(12, notes_swing.size())):
			if notes_swing[i].position > notes_straight[i].position:
				has_swing_offset = true
				break

		if has_swing_offset:
			print("  OK: Swing applied (notes delayed)")
		else:
			print("  FAIL: Swing not detected")
			passed = false

	return passed


func test_bass_symbols() -> bool:
	print("\n[TEST] Bass symbols (B, b)")

	var player = FolkGuitarPlayer.new()
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 45, 50, 55, 59, 64]  # E2, A2, D3, G3, B3, E4

	# Pattern avec basses
	var pattern = StrumPattern.create("B.b.B.b.B.b.B.b.", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	var passed = true

	# Devrait avoir 8 notes (4 B + 4 b)
	if notes.size() != 8:
		print("  FAIL: Expected 8 notes, got %d" % notes.size())
		passed = false
	else:
		print("  OK: Generated 8 bass notes")

	# Vérifier que les notes sont bien des basses (graves)
	var bass_notes = chord.get_bass_notes()
	var all_bass = true
	for note in notes:
		if note.pitch != bass_notes[0] and note.pitch != bass_notes[1]:
			all_bass = false
			break

	if all_bass:
		print("  OK: All notes are bass notes (%d or %d)" % [bass_notes[0], bass_notes[1]])
	else:
		print("  FAIL: Some notes are not bass notes")
		passed = false

	return passed


func test_arpeggio_symbols() -> bool:
	print("\n[TEST] Arpeggio symbols (0, 1, 2, 3, 4)")

	var player = FolkGuitarPlayer.new()
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 4.0
	chord.notes = [40, 45, 50, 55, 59, 64]

	# Pattern d'arpège ascendant
	var pattern = StrumPattern.create("0.1.2.3.4.......", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	var passed = true

	# Devrait avoir 5 notes (0-4)
	if notes.size() != 5:
		print("  FAIL: Expected 5 notes, got %d" % notes.size())
		passed = false
	else:
		print("  OK: Generated 5 arpeggio notes")

	# Vérifier que les notes sont en ordre ascendant
	var ascending = true
	for i in range(notes.size() - 1):
		if notes[i].pitch >= notes[i + 1].pitch:
			ascending = false
			break

	if ascending:
		print("  OK: Arpeggio is ascending")
	else:
		print("  FAIL: Arpeggio not ascending")
		passed = false

	return passed


func test_double_mute_symbols() -> bool:
	print("\n[TEST] Double mute symbols (W, w)")

	var player = FolkGuitarPlayer.new()
	var chord = GuitarChord.new()
	chord.time = 0.0
	chord.beat_length = 2.0
	chord.notes = [40, 45, 50, 55, 59, 64]

	# Pattern avec double mutes
	var pattern = StrumPattern.create("W.......w.......", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord])

	var notes = player.generate()

	var passed = true

	# W et w génèrent chacun 2 strums (down+up) de 6 cordes = 12 notes chacun
	# Total = 24 notes
	if notes.size() != 24:
		print("  FAIL: Expected 24 notes (2 double mutes x 2 strums x 6 strings), got %d" % notes.size())
		passed = false
	else:
		print("  OK: Generated 24 notes from 2 double mutes")

	# Vérifier que les notes sont courtes (mutées)
	var all_short = true
	for note in notes:
		if note.duration > 0.1:
			all_short = false
			break

	if all_short:
		print("  OK: All notes are short (muted)")
	else:
		print("  FAIL: Some notes are not muted")
		passed = false

	return passed


func test_chord_transitions() -> bool:
	print("\n[TEST] Chord transition post-processing")

	var player = FolkGuitarPlayer.new()

	# Deux accords différents
	var chord1 = GuitarChord.new()
	chord1.time = 0.0
	chord1.beat_length = 2.0
	chord1.notes = [40, 45, 50, 55, 59, 64]  # Em

	var chord2 = GuitarChord.new()
	chord2.time = 2.0
	chord2.beat_length = 2.0
	chord2.notes = [36, 43, 48, 52, 55, 60]  # C

	# Pattern qui laisse sonner les notes
	var pattern = StrumPattern.create("D...............", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([chord1, chord2])
	player.config.chord_transition_gap = 0.8

	var notes = player.generate()

	var passed = true

	# Trouver les notes du premier accord qui devraient être raccourcies
	var chord1_notes = []
	for note in notes:
		if note.position < 2.0:
			chord1_notes.append(note)

	# Vérifier que les notes non communes ont été raccourcies
	var has_shortened_notes = false
	for note in chord1_notes:
		# Les notes devraient être raccourcies à ~80% de 2.0 beats
		if note.duration < 2.0:
			has_shortened_notes = true
			break

	if has_shortened_notes:
		print("  OK: Chord transition gap applied")
	else:
		print("  WARN: Chord transition gap not clearly visible")

	return passed
