extends Node

"""
Test de la fonction generate_ascii_tab() - Génération de tablatures ASCII
"""

func _ready():
	print("\n" + "="*80)
	print("  TEST: GÉNÉRATION DE TABLATURES ASCII")
	print("="*80 + "\n")

	test_simple_strum_pattern()
	test_arpeggio_pattern()
	test_alternating_bass()
	test_combined_pattern()

	print("\n" + "="*80)
	print("  TESTS TERMINÉS")
	print("="*80 + "\n")


func test_simple_strum_pattern():
	"""Test 1: Pattern de strum simple."""
	print("\n--- Test 1: Pattern de strum simple (D d D d) ---\n")

	var player = FolkGuitarPlayer.new()

	# Accord de G (43, 47, 50, 55, 59, 62)
	var g_chord = GuitarChord.new()
	g_chord.time = 0.0
	g_chord.beat_length = 4.0
	g_chord.notes = [43, 47, 50, 55, 59, 62]  # G

	# Pattern simple: Down fort, down léger, répété
	var pattern = StrumPattern.create("D...d...D...d...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([g_chord])

	# Générer les notes
	var notes = player.generate()
	print("Notes générées: %d" % notes.size())

	# Générer la tablature ASCII
	var tab = player.generate_ascii_tab(4, 80, true)
	print("\nTablature ASCII:\n")
	print(tab)


func test_arpeggio_pattern():
	"""Test 2: Pattern d'arpège."""
	print("\n--- Test 2: Pattern d'arpège (0 1 2 3 4) ---\n")

	var player = FolkGuitarPlayer.new()

	# Accord de Em (40, 47, 52, 56, 59, 64)
	var em_chord = GuitarChord.new()
	em_chord.time = 0.0
	em_chord.beat_length = 4.0
	em_chord.notes = [40, 47, 52, 56, 59, 64]  # Em

	# Pattern d'arpège ascendant
	var pattern = StrumPattern.create("0...1...2...3...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([em_chord])

	# Générer les notes
	var notes = player.generate()
	print("Notes générées: %d" % notes.size())

	# Générer la tablature ASCII
	var tab = player.generate_ascii_tab(4, 80, true)
	print("\nTablature ASCII:\n")
	print(tab)


func test_alternating_bass():
	"""Test 3: Basse alternée (boom-chick)."""
	print("\n--- Test 3: Basse alternée (B b) ---\n")

	var player = FolkGuitarPlayer.new()

	# Accord de C (36, 43, 48, 52, 55, 60)
	var c_chord = GuitarChord.new()
	c_chord.time = 0.0
	c_chord.beat_length = 4.0
	c_chord.notes = [36, 43, 48, 52, 55, 60]  # C

	# Pattern boom-chick: basse principale, strum, basse alternative, strum
	var pattern = StrumPattern.create("B...d...b...d...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([c_chord])

	# Générer les notes
	var notes = player.generate()
	print("Notes générées: %d" % notes.size())

	# Générer la tablature ASCII
	var tab = player.generate_ascii_tab(4, 80, true)
	print("\nTablature ASCII:\n")
	print(tab)


func test_combined_pattern():
	"""Test 4: Pattern combiné avec plusieurs accords."""
	print("\n--- Test 4: Pattern combiné - G vers C ---\n")

	var player = FolkGuitarPlayer.new()

	# Accord de G
	var g_chord = GuitarChord.new()
	g_chord.time = 0.0
	g_chord.beat_length = 4.0
	g_chord.notes = [43, 47, 50, 55, 59, 62]  # G

	# Accord de C
	var c_chord = GuitarChord.new()
	c_chord.time = 4.0
	c_chord.beat_length = 4.0
	c_chord.notes = [36, 43, 48, 52, 55, 60]  # C

	# Pattern: basse + arpège + strum
	var pattern = StrumPattern.create("B.0.1.2.D...d...", 0.25)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([g_chord, c_chord])

	# Générer les notes
	var notes = player.generate()
	print("Notes générées: %d" % notes.size())

	# Générer la tablature ASCII avec résolution plus fine
	var tab = player.generate_ascii_tab(6, 80, true)
	print("\nTablature ASCII:\n")
	print(tab)


func test_custom_resolution():
	"""Test 5: Résolution personnalisée."""
	print("\n--- Test 5: Résolution personnalisée (2 chars/beat) ---\n")

	var player = FolkGuitarPlayer.new()

	# Accord de Am (40, 47, 52, 57, 60, 64)
	var am_chord = GuitarChord.new()
	am_chord.time = 0.0
	am_chord.beat_length = 2.0
	am_chord.notes = [40, 47, 52, 57, 60, 64]  # Am

	# Pattern rapide
	var pattern = StrumPattern.create("DuDuDuDu........", 0.125)
	player.pattern_sequence = [pattern]
	player.set_chord_grid([am_chord])

	# Générer les notes
	var notes = player.generate()
	print("Notes générées: %d" % notes.size())

	# Tablature avec faible résolution (2 chars par beat)
	var tab = player.generate_ascii_tab(2, 60, true)
	print("\nTablature ASCII (résolution faible):\n")
	print(tab)
