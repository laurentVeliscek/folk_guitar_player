extends Node

"""
Tests et exemples pour GuitarPatternGenerator

Démontre la génération de patterns aléatoires dans différents styles.
"""

func _ready():
	print("\n" + "="*80)
	print("  TEST: Générateur de Patterns Aléatoires")
	print("="*80 + "\n")

	test_funky_generation()
	test_folk_generation()
	test_bossa_generation()
	test_rnb_generation()
	test_with_player()

	print("\n" + "="*80)
	print("  TESTS TERMINÉS")
	print("="*80 + "\n")


func test_funky_generation():
	"""Test 1: Génération de patterns Funky."""
	print("\n--- Test 1: Génération Funky (5 exemples) ---\n")

	var generator = GuitarPatternGenerator.new()

	for i in range(5):
		var result = generator.generate("Funky")
		print("Funky #%d: [%s] (step: %.3f)" % [i + 1, result.pattern, result.step_beat_length])


func test_folk_generation():
	"""Test 2: Génération de patterns Folk."""
	print("\n--- Test 2: Génération Folk (5 exemples) ---\n")

	var generator = GuitarPatternGenerator.new()

	for i in range(5):
		var result = generator.generate("Folk")
		print("Folk #%d:  [%s] (step: %.3f)" % [i + 1, result.pattern, result.step_beat_length])


func test_bossa_generation():
	"""Test 3: Génération de patterns Bossa."""
	print("\n--- Test 3: Génération Bossa (5 exemples) ---\n")

	var generator = GuitarPatternGenerator.new()

	for i in range(5):
		var result = generator.generate("Bossa")
		print("Bossa #%d: [%s] (step: %.3f)" % [i + 1, result.pattern, result.step_beat_length])


func test_rnb_generation():
	"""Test 4: Génération de patterns R'n B."""
	print("\n--- Test 4: Génération R'n B (5 exemples) ---\n")

	var generator = GuitarPatternGenerator.new()

	for i in range(5):
		var result = generator.generate("R'n B")
		print("R'n B #%d: [%s] (step: %.3f)" % [i + 1, result.pattern, result.step_beat_length])


func test_with_player():
	"""Test 5: Utilisation avec FolkGuitarPlayer."""
	print("\n--- Test 5: Intégration avec FolkGuitarPlayer ---\n")

	var generator = GuitarPatternGenerator.new(42)  # Seed fixe pour reproductibilité
	var player = FolkGuitarPlayer.new()

	# Créer une progression d'accords simple
	var g = GuitarChord.new()
	g.time = 0.0
	g.beat_length = 4.0
	g.notes = [43, 47, 50, 55, 59, 62]  # G

	var c = GuitarChord.new()
	c.time = 4.0
	c.beat_length = 4.0
	c.notes = [36, 43, 48, 52, 55, 60]  # C

	player.set_chord_grid([g, c])

	# Tester chaque style
	var styles = ["Funky", "Folk", "Bossa", "R'n B"]

	for style in styles:
		var result = generator.generate(style)

		# Créer un pattern avec le résultat
		var pattern = StrumPattern.create(result.pattern, result.step_beat_length)
		player.pattern_sequence = [pattern]

		# Générer les notes
		var notes = player.generate()

		print("\nStyle: %s" % style)
		print("  Pattern: [%s]" % result.pattern)
		print("  Step: %.3f" % result.step_beat_length)
		print("  Notes générées: %d" % notes.size())

		# Générer la tablature
		var tab = player.generate_ascii_tab(4, 60, false)
		print("  Tablature (extrait):")
		var lines = tab.split("\n")
		for i in range(min(7, lines.size())):
			print("    %s" % lines[i])


func test_determinism():
	"""Test 6: Vérifier que le seed fixe produit les mêmes résultats."""
	print("\n--- Test 6: Déterminisme avec seed fixe ---\n")

	# Génération 1
	var gen1 = GuitarPatternGenerator.new(12345)
	var pattern1 = gen1.generate("Folk")

	# Génération 2 avec même seed
	var gen2 = GuitarPatternGenerator.new(12345)
	var pattern2 = gen2.generate("Folk")

	print("Pattern 1: [%s]" % pattern1.pattern)
	print("Pattern 2: [%s]" % pattern2.pattern)

	if pattern1.pattern == pattern2.pattern:
		print("✓ Déterminisme confirmé : les patterns sont identiques")
	else:
		print("✗ Erreur : les patterns diffèrent malgré le même seed")


func test_variety():
	"""Test 7: Vérifier la variété des patterns générés."""
	print("\n--- Test 7: Variété des patterns ---\n")

	var generator = GuitarPatternGenerator.new()
	var patterns = {}

	# Générer 20 patterns Folk
	for i in range(20):
		var result = generator.generate("Folk")
		if patterns.has(result.pattern):
			patterns[result.pattern] += 1
		else:
			patterns[result.pattern] = 1

	print("20 patterns Folk générés:")
	print("  Patterns uniques: %d" % patterns.size())
	print("  Variété: %.1f%%" % (float(patterns.size()) / 20.0 * 100.0))

	print("\nPatterns générés:")
	for pattern in patterns.keys():
		print("  [%s] × %d" % [pattern, patterns[pattern]])
