# FolkGuitarPlayer - Documentation Complète

Documentation exhaustive du système de génération de patterns de guitare folk avec MIDI et tablatures ASCII.

---

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [FolkGuitarPlayer](#folkguitarplayer)
3. [StrumPattern](#strumpattern)
4. [GuitarPatternGenerator](#guitarpatterngenerator)
5. [GuitarChord](#guitarchord)
6. [Symboles de Pattern](#symboles-de-pattern)
7. [Configuration](#configuration)
8. [Exemples d'utilisation](#exemples-dutilisation)
9. [Génération de tablatures ASCII](#génération-de-tablatures-ascii)

---

## Vue d'ensemble

**FolkGuitarPlayer** est un système de génération de patterns de guitare folk réaliste qui :
- Génère des notes MIDI à partir de grilles d'accords et de patterns rythmiques
- Simule un jeu de guitare humanisé (swing, vélocité variable, timing)
- Supporte de multiples techniques (strumming, arpèges, basses, mutes, flams)
- Génère des tablatures ASCII quantizées
- Permet la génération procédurale de patterns dans différents styles

### Architecture

```
FolkGuitarPlayer (classe principale)
├── StrumPattern (patterns de 16 caractères)
├── GuitarChord (accords avec positions)
└── GuitarPatternGenerator (génération procédurale)
```

---

## FolkGuitarPlayer

### Description

Classe principale qui génère des notes MIDI à partir d'une grille d'accords et d'une séquence de patterns.

### Propriétés publiques

```gdscript
var chord_grid: Array          # Array de GuitarChord
var pattern_sequence: Array    # Array de StrumPattern
var output_notes: Array        # Notes MIDI générées (lecture seule)
var config: Dictionary         # Configuration globale
```

### Création

```gdscript
var player = FolkGuitarPlayer.new()
```

### Méthodes principales

#### `generate() -> Array`

Génère toutes les notes MIDI à partir de la grille d'accords et des patterns.

**Retourne** : Array de Dictionary avec :
- `pitch` (int) : Note MIDI (0-127)
- `position` (float) : Position en beats
- `duration` (float) : Durée en beats
- `velocity` (int) : Vélocité (1-127)
- `string_index` (int) : Index de la corde (-1 si non applicable)

**Durée totale** : `max(durée_chord_grid, durée_pattern_sequence)`

Les deux bouclent automatiquement pour remplir la durée totale.

**Exemple** :
```gdscript
var player = FolkGuitarPlayer.new()
player.set_chord_grid([chord1, chord2])
player.pattern_sequence = [pattern1, pattern2]

var notes = player.generate()
print("Notes générées: %d" % notes.size())
```

#### `generate_ascii_tab(chars_per_beat: int = 4, line_width: int = 80, show_time_markers: bool = true) -> String`

Génère une tablature ASCII quantizée à partir des patterns et accords.

**Paramètres** :
- `chars_per_beat` : Résolution horizontale (caractères par beat)
- `line_width` : Largeur maximale avant retour à la ligne
- `show_time_markers` : Afficher les numéros de beats

**Retourne** : String contenant la tablature ASCII

**Caractéristiques** :
- Quantizée (pas de swing ni de strum duration)
- Utilise les vraies positions de frettes via `GuitarChord.get_tab_absolute_as_array()`
- Format standard 6 cordes (E A D G B e)

**Exemple** :
```gdscript
var tab = player.generate_ascii_tab(4, 80, true)
print(tab)
```

**Sortie** :
```
 0   1   2   3
e|--0--0--0--0--|
B|--1--1--1--1--|
G|--2--2--2--2--|
D|--2--2--2--2--|
A|--0--0--0--0--|
E|--------------|
```

#### `set_chord_grid(chords: Array) -> void`

Définit la grille d'accords à jouer.

**Paramètre** : Array de `GuitarChord`

#### `set_configuration(params: Dictionary) -> void`

Met à jour la configuration avec des paramètres personnalisés.

**Exemple** :
```gdscript
player.set_configuration({
    "swing_amount": 0.5,
    "velocity_down_base": 110,
    "max_chords_strings": 4
})
```

#### `get_configuration() -> Dictionary`

Retourne une copie de la configuration actuelle.

#### `get_strum_pattern_at_pos(pos_in_beats: float) -> StrumPattern`

Retourne le pattern actif à une position donnée (en beats).

**Retourne** : `StrumPattern` ou `null` si hors plage

**Prend en compte** le bouclage de `pattern_sequence`

**Exemple** :
```gdscript
var pattern = player.get_strum_pattern_at_pos(4.5)
if pattern:
    print("Pattern actif: %s" % pattern.pattern)
```

#### `clear() -> void`

Réinitialise complètement le player (grille, patterns, notes).

---

## StrumPattern

### Description

Représente un pattern de 16 caractères avec timing et configuration override.

### Propriétés

```gdscript
var pattern: String = "D...d...D...d..."  # 16 caractères exactement
var step_beat_length: float = 0.25        # Durée de chaque step en beats
var config_override: Dictionary = {}      # Override de config pour ce pattern
```

### Création

#### Factory method (recommandé)

```gdscript
var pattern = StrumPattern.create(
    "D.uDudu D.uDudu ",  # Pattern de 16 caractères
    0.25,                 # Step = croche
    {                     # Config override (optionnel)
        "velocity_down_base": 110,
        "swing_amount": 0.3
    }
)
```

#### Constructeur standard

```gdscript
var pattern = StrumPattern.new()
pattern.pattern = "D.uDudu D.uDudu "
pattern.step_beat_length = 0.25
pattern.config_override = {"velocity_down_base": 110}
```

### Méthodes

#### `get_duration() -> float`

Retourne la durée totale du pattern en beats (toujours `16 × step_beat_length`).

#### `duplicate() -> StrumPattern`

Crée une copie du pattern.

### Validation

Le pattern est **automatiquement** ajusté à 16 caractères :
- Si trop court : complété avec des espaces
- Si trop long : tronqué

**Exemple** :
```gdscript
var pattern = StrumPattern.new()
pattern.pattern = "D.u"  # Seulement 3 caractères
# Devient : "D.u             " (13 espaces ajoutés)
```

### Config Override

Le `config_override` permet de modifier temporairement les paramètres pour ce pattern spécifique :

```gdscript
var pattern_fort = StrumPattern.create(
    "DUDUDUDUDUDUDUDU",
    0.125,
    {"velocity_down_base": 120}  # Plus fort que la config globale
)

var pattern_doux = StrumPattern.create(
    "d.u.d.u.d.u.d.u.",
    0.25,
    {"velocity_down_base": 60}   # Plus doux
)
```

---

## GuitarPatternGenerator

### Description

Générateur procédural de patterns dans différents styles musicaux.

### Création

```gdscript
# Aléatoire
var generator = GuitarPatternGenerator.new()

# Déterministe (avec seed)
var generator = GuitarPatternGenerator.new(42)
```

### Méthode principale

#### `generate(style: String) -> Dictionary`

Génère un pattern dans le style demandé.

**Styles disponibles** : `"Funky"`, `"Folk"`, `"Bossa"`, `"R'n B"` (ou `"RnB"`)

**Retourne** : Dictionary avec :
- `pattern` (String) : Pattern de 16 caractères
- `step_beat_length` (float) : Durée du step

**Exemple** :
```gdscript
var generator = GuitarPatternGenerator.new()

var funky = generator.generate("Funky")
print(funky.pattern)          # "DxUdDxUdDxUdDxUd"
print(funky.step_beat_length) # 0.125

var folk = generator.generate("Folk")
print(folk.pattern)           # "D.uDudu.D.uDudu."
print(folk.step_beat_length)  # 0.25
```

### Styles disponibles

#### 1. **Funky** 🎸

Caractéristiques :
- **Step** : 0.125 (double croches)
- **Rythme** : Serré, énergique
- **Éléments** : D, d, U, u, x, X, w, W
- **Notes seules** : Rares (B, b, 0-4)
- **Silences** : Très rares
- **Symétrie** : Motifs de 2-6 pas répétés

Exemples générés :
```
DxUdDxUdDxUdDxUd  # Motif 4 pas × 4
DUxdWuXDDUxdWuXD  # Motif 8 pas × 2
DxuDxuDxuDxuDxuD  # Motif 3 pas × 5 + 1
```

#### 2. **Folk** 🎻

Caractéristiques :
- **Step** : 0.25 (croches)
- **Rythme** : Régulier, avec sustain
- **Éléments** : D, d, U, u, beaucoup de `.`
- **Down** : Sur temps forts (0, 4, 8, 12)
- **Up** : Entre les temps
- **Notes seules** : Occasionnelles (B surtout)

Exemples générés :
```
D.uDudu.D.uDudu.  # Classique
B.uDudu.D.uDudu.  # Avec basse
D..Du.u.D..Du.u.  # Swing folk
```

#### 3. **Bossa** 🎹

Caractéristiques :
- **Step** : 0.25 (croches)
- **Rythme** : Croche pointée (3+3+2)
- **Éléments** : D, d, U, u, `.`, ` ` (silences)
- **Style** : Syncopé, léger
- **Mutes** : Rares et légers

Exemples générés :
```
..D..u.D..D.u...  # Motif 3+3+2
..d..uD...d.u...  # Variation légère
 .D..u. ..D.u...  # Avec silences
```

#### 4. **R'n B** 🎵

Caractéristiques :
- **Step** : 0.25 ou 0.125 (variable)
- **Rythme** : Arpèges et notes seules
- **Éléments** : 0, 1, 2, 3, 4, `.`
- **Style** : Mélodique, symétrique
- **Motifs** : Montée/descente, palindrome, grappes

Exemples générés :
```
01234321........  # Montée-descente
0123.3210123.321  # Palindrome ABBA
00.11.22.33.44..  # Grappes répétées
012.210.012.210.  # Motif répété
```

### Utilisation avec FolkGuitarPlayer

```gdscript
var generator = GuitarPatternGenerator.new()
var player = FolkGuitarPlayer.new()

# Générer un pattern aléatoire
var result = generator.generate("Funky")

# Créer un StrumPattern
var pattern = StrumPattern.create(result.pattern, result.step_beat_length)

# Utiliser avec le player
player.pattern_sequence = [pattern]
player.set_chord_grid([chord1, chord2])
var notes = player.generate()
```

### Déterminisme

Avec un seed fixe, le générateur produit toujours les mêmes patterns :

```gdscript
var gen1 = GuitarPatternGenerator.new(12345)
var pattern1 = gen1.generate("Folk")

var gen2 = GuitarPatternGenerator.new(12345)
var pattern2 = gen2.generate("Folk")

# pattern1.pattern == pattern2.pattern (toujours vrai)
```

---

## GuitarChord

### Description

Représente un accord de guitare avec position temporelle.

**Note** : Cette classe n'est pas fournie avec FolkGuitarPlayer mais doit implémenter certaines méthodes pour être compatible.

### Propriétés requises

```gdscript
var time: float          # Position de l'accord en beats
var beat_length: float   # Durée de l'accord en beats
var notes: Array         # Array d'int : MIDI pitches (6 cordes, grave vers aigu)
```

### Méthodes requises

#### Pour la génération MIDI

```gdscript
func get_notes() -> Array
    # Retourne les notes MIDI (en int)

func is_string_muted(string_index: int) -> bool
    # Retourne true si la corde est mutée

func get_bass_notes() -> Array
    # Retourne [pitch_principal, pitch_alternatif] (int)

func get_arp_note(idx: int) -> int
    # Retourne le pitch MIDI de la note d'arpège (0-4)
```

#### Pour la génération de tablatures ASCII

```gdscript
func get_tab_absolute_as_array() -> Array
    # Retourne un tableau de 6 Strings : ["x", "0", "2", "2", "1", "0"]
    # De la 6ème corde (grave) à la 1ère (aigu)
    # "x" = corde mutée, "0"-"22" = numéro de frette

func get_bass_notes_with_string() -> Array
    # Retourne [{midi: int, string: int}, {midi: int, string: int}]
    # string : 0=E grave, 5=e aigu

func get_arp_note_with_string(idx: int) -> Dictionary
    # Retourne {midi: int, string: int}
```

### Exemple d'accord

```gdscript
# Accord de La mineur (Am)
var am = GuitarChord.new()
am.time = 0.0
am.beat_length = 4.0
am.notes = [40, 47, 52, 57, 60, 64]  # E A E A C E (MIDI)

# get_tab_absolute_as_array() devrait retourner:
# ["x", "0", "2", "2", "1", "0"]
#   6ème 5ème 4ème 3ème 2ème 1ère corde
```

---

## Symboles de Pattern

Tous les patterns sont composés de 16 caractères parmi les symboles suivants :

### Strums (coups d'accord)

| Symbole | Description | Vélocité | Direction |
|---------|-------------|----------|-----------|
| `D` | Down fort | `velocity_down_base` (100) | Bas → Haut |
| `d` | Down léger | `velocity_down_light` (75) | Bas → Haut |
| `U` | Up fort | `velocity_up_base` (95) | Haut → Bas |
| `u` | Up léger | `velocity_up_light` (70) | Haut → Bas |

### Mutes (étouffés)

| Symbole | Description | Durée |
|---------|-------------|-------|
| `X` | Mute fort | `mute_duration` (0.05 beats) |
| `x` | Mute léger | `mute_duration × 0.5` |
| `W` | Double mute fort | 2 mutes rapides (D+U fort) |
| `w` | Double mute léger | 2 mutes rapides (d+u léger) |

### Flams (roulements rapides)

| Symbole | Description |
|---------|-------------|
| `F` | Flam DU fort | Down+Up rapide dans 1 step (fort) |
| `f` | Flam du léger | down+up rapide dans 1 step (léger) |

### Notes simples

| Symbole | Description | Pitch |
|---------|-------------|-------|
| `B` | Basse principale | Note de basse la plus grave |
| `b` | Basse alternative | Note de basse alternative |
| `0` | Arpège note 0 | Note la plus grave |
| `1` | Arpège note 1 | 2ème note |
| `2` | Arpège note 2 | 3ème note |
| `3` | Arpège note 3 | 4ème note |
| `4` | Arpège note 4 | Note la plus aiguë |

**Notes sur les arpèges** :
- Les notes d'arpège se prolongent jusqu'à interruption (accord, silence, changement d'accord)
- Elles ne s'interrompent PAS mutuellement (peuvent sonner ensemble)
- L'accent (`accent_downbeat_factor`) s'applique sur les temps forts

### Autres symboles

| Symbole | Description |
|---------|-------------|
| `.` | Laisser sonner | Prolonge les notes actives |
| ` ` (espace) | Silence | Interrompt les arpèges |

### Exemples de patterns

```gdscript
"D.uDudu D.uDudu "  # Folk classique (croches)
"DUDUDUDUDUDUDUDU"  # Punk/Rock (double croches)
"D...d...D...d..."  # Folk lent avec sustain
"B.uDudu.B.uDudu."  # Alternating bass (country)
"0.1.2.3.4.3.2.1."  # Arpège ascendant/descendant
"DxUdDxUdDxUdDxUd"  # Funky avec mutes
"..D..u.D..D.u..."  # Bossa (croche pointée)
"W.w.X.x.W.w.X.x."  # Percussif avec mutes variés
"F.f.D.u.F.f.D.u."  # Flams et strums
```

---

## Configuration

### Paramètres disponibles

La configuration globale de `FolkGuitarPlayer` contient :

#### Timing et durées

```gdscript
"strum_duration_min": 0.015      # Durée minimale de balayette (beats)
"strum_duration_max": 0.030      # Durée maximale de balayette (beats)
"mute_duration": 0.05            # Durée des notes mutées (beats)
"note_overlap": 0.02             # Overlap entre notes (beats)
"swing_amount": 0.0              # 0.0=binaire, 1.0=ternaire
```

#### Vélocités

```gdscript
"velocity_down_base": 100        # Down fort
"velocity_down_light": 75        # down léger
"velocity_up_base": 95           # Up fort
"velocity_up_light": 70          # up léger
"single_note_velocity": 90       # Basses et arpèges
"accent_downbeat_factor": 1.15   # Boost temps forts (×115%)
```

#### Vélocité - Courbe et randomisation

```gdscript
"velocity_curve_shape": "gaussian"  # "gaussian", "linear", "flat"
"velocity_randomization": 0.10      # Facteur de randomisation (0-1)
```

#### Position du médiateur

```gdscript
"pick_position": 0.0              # -1.0 (graves) à 1.0 (aiguës)
"pick_position_influence": 0.5    # Intensité (0.0-1.0)
```

#### Humanisation

```gdscript
"humanize_timing": false          # Micro-décalages temporels
"timing_variance": 0.005          # Variance en beats
```

#### Transitions et cordes

```gdscript
"chord_transition_gap": 0.8       # Raccourcir notes non communes (80%)
"max_chords_strings": 6           # Nombre de cordes max (1-6)
```

### Modification de la configuration

#### Globale

```gdscript
var player = FolkGuitarPlayer.new()

# Modifier un paramètre
player.config.swing_amount = 0.5

# Ou plusieurs à la fois
player.set_configuration({
    "swing_amount": 0.5,
    "velocity_down_base": 110,
    "max_chords_strings": 4
})
```

#### Par pattern (config_override)

```gdscript
var pattern1 = StrumPattern.create(
    "D...d...D...d...",
    0.25,
    {
        "velocity_down_base": 120,  # Plus fort pour ce pattern
        "swing_amount": 0.3          # Un peu de swing
    }
)

var pattern2 = StrumPattern.create(
    "d.u.d.u.d.u.d.u.",
    0.25,
    {
        "velocity_down_base": 60,   # Plus doux
        "max_chords_strings": 3     # Que 3 cordes
    }
)

player.pattern_sequence = [pattern1, pattern2]
```

### Paramètres importants

#### swing_amount

Contrôle le swing (sensation ternaire vs binaire).

- `0.0` : Binaire pur (croches égales)
- `0.5` : Swing intermédiaire
- `1.0` : Ternaire complet (ratio 2:1)

**Affecte** : Seulement les positions impaires (1, 3, 5, 7, 9, 11, 13, 15)

**Exemple** :
```gdscript
player.config.swing_amount = 0.6  # Swing jazz/blues
```

#### max_chords_strings

Limite le nombre de cordes jouées pour les strums.

- Filtre les cordes **graves**
- Garde les cordes **aiguës**

**Exemple** :
```gdscript
# Accord à 6 notes, mais ne jouer que les 3 plus aiguës
player.config.max_chords_strings = 3
```

#### accent_downbeat_factor

Multiplie la vélocité sur les temps forts (beat % 1.0 == 0).

**S'applique à** :
- Down strums (D) sur temps forts
- Notes simples (B, b, 0-4) sur temps forts

**Exemple** :
```gdscript
player.config.accent_downbeat_factor = 1.3  # +30% sur temps forts
```

#### chord_transition_gap

Raccourcit les notes non communes avant un changement d'accord.

- `1.0` : Notes jusqu'au changement d'accord
- `0.8` : Notes raccourcies à 80% (par défaut)
- `0.5` : Notes raccourcies à 50%

**Simule** : Le guitariste qui lève les doigts avant le changement

---

## Exemples d'utilisation

### Exemple 1 : Pattern simple

```gdscript
var player = FolkGuitarPlayer.new()

# Créer un accord de G
var g = GuitarChord.new()
g.time = 0.0
g.beat_length = 4.0
g.notes = [43, 47, 50, 55, 59, 62]

# Pattern folk classique
var pattern = StrumPattern.create("D.uDudu D.uDudu ", 0.25)

player.set_chord_grid([g])
player.pattern_sequence = [pattern]

# Générer les notes MIDI
var notes = player.generate()
print("Notes générées: %d" % notes.size())

# Générer la tablature
var tab = player.generate_ascii_tab()
print(tab)
```

### Exemple 2 : Progression d'accords

```gdscript
var player = FolkGuitarPlayer.new()

# Progression G - C - D - G
var chords = []

var g = GuitarChord.new()
g.time = 0.0
g.beat_length = 4.0
g.notes = [43, 47, 50, 55, 59, 62]
chords.append(g)

var c = GuitarChord.new()
c.time = 4.0
c.beat_length = 4.0
c.notes = [36, 43, 48, 52, 55, 60]
chords.append(c)

var d = GuitarChord.new()
d.time = 8.0
d.beat_length = 4.0
d.notes = [50, 50, 50, 54, 57, 62]
chords.append(d)

var g2 = GuitarChord.new()
g2.time = 12.0
g2.beat_length = 4.0
g2.notes = [43, 47, 50, 55, 59, 62]
chords.append(g2)

player.set_chord_grid(chords)

# Un pattern qui boucle sur toute la progression
var pattern = StrumPattern.create("D.uDudu.D.udu.u.", 0.25)
player.pattern_sequence = [pattern]

var notes = player.generate()
```

### Exemple 3 : Patterns différents par accord

```gdscript
var player = FolkGuitarPlayer.new()

# Progression de 4 accords
player.set_chord_grid([chord1, chord2, chord3, chord4])

# Pattern différent pour chaque accord (4 beats chacun)
var patterns = [
    StrumPattern.create("D.uDudu.D.uDudu.", 0.25),  # Accord 1
    StrumPattern.create("B.uDudu.b.uDudu.", 0.25),  # Accord 2 (avec basses)
    StrumPattern.create("0.1.2.3.4.3.2.1.", 0.25),  # Accord 3 (arpège)
    StrumPattern.create("DxUdDxUdDxUdDxUd", 0.125), # Accord 4 (funky)
]

player.pattern_sequence = patterns
var notes = player.generate()
```

### Exemple 4 : Génération procédurale

```gdscript
var generator = GuitarPatternGenerator.new()
var player = FolkGuitarPlayer.new()

# Générer 4 patterns Folk aléatoires
var patterns = []
for i in range(4):
    var result = generator.generate("Folk")
    var pattern = StrumPattern.create(result.pattern, result.step_beat_length)
    patterns.append(pattern)
    print("Pattern %d: %s" % [i+1, result.pattern])

player.pattern_sequence = patterns
player.set_chord_grid([chord1, chord2, chord3, chord4])

var notes = player.generate()
```

### Exemple 5 : Évolution de style

```gdscript
var generator = GuitarPatternGenerator.new()
var player = FolkGuitarPlayer.new()

# Intro calme (Folk)
var intro = generator.generate("Folk")
var intro_pattern = StrumPattern.create(intro.pattern, intro.step_beat_length)

# Couplet énergique (Funky)
var verse = generator.generate("Funky")
var verse_pattern = StrumPattern.create(verse.pattern, verse.step_beat_length)

# Refrain mélodique (R'n B)
var chorus = generator.generate("R'n B")
var chorus_pattern = StrumPattern.create(chorus.pattern, chorus.step_beat_length)

player.pattern_sequence = [intro_pattern, verse_pattern, chorus_pattern]
player.set_chord_grid(chords)

var notes = player.generate()
```

### Exemple 6 : Avec config_override

```gdscript
var player = FolkGuitarPlayer.new()

# Pattern 1 : Fort et plein
var pattern1 = StrumPattern.create(
    "D.uDudu D.uDudu ",
    0.25,
    {
        "velocity_down_base": 120,
        "max_chords_strings": 6
    }
)

# Pattern 2 : Doux et fin (3 cordes seulement)
var pattern2 = StrumPattern.create(
    "d.u.d.u.d.u.d.u.",
    0.25,
    {
        "velocity_down_base": 60,
        "max_chords_strings": 3
    }
)

# Pattern 3 : Avec swing
var pattern3 = StrumPattern.create(
    "D..du.u.D..du.u.",
    0.25,
    {
        "swing_amount": 0.6
    }
)

player.pattern_sequence = [pattern1, pattern2, pattern3, pattern1]
player.set_chord_grid([chord1, chord2, chord3, chord4])

var notes = player.generate()
```

### Exemple 7 : Export tablature vers fichier

```gdscript
var player = FolkGuitarPlayer.new()

# ... configuration ...

var notes = player.generate()
var tab = player.generate_ascii_tab(4, 80, true)

# Sauvegarder dans un fichier
var file = File.new()
if file.open("res://my_tab.txt", File.WRITE) == OK:
    file.store_string(tab)
    file.close()
    print("Tablature sauvegardée !")
```

---

## Génération de tablatures ASCII

### Format de sortie

Les tablatures ASCII suivent le format standard 6 cordes :

```
 0   1   2   3   4
e|--0--3--0--3--0--|  (1ère corde - Mi aigu)
B|--0--0--0--0--0--|  (2ème corde - Si)
G|--1--0--1--0--1--|  (3ème corde - Sol)
D|--2--0--2--0--2--|  (4ème corde - Ré)
A|--2--2--2--2--2--|  (5ème corde - La)
E|-----------------|  (6ème corde - Mi grave)
```

### Caractéristiques

1. **Quantizée** : Pas de swing ni de durée de strum
2. **Alignée** : Les accords sont verticalement alignés
3. **Précise** : Utilise les vraies frettes via `GuitarChord.get_tab_absolute_as_array()`
4. **Lisible** : Format compatible avec tout éditeur de texte

### Symboles dans la tablature

| Symbole | Signification |
|---------|---------------|
| `-` | Corde non jouée à cet instant |
| `0` | Corde à vide |
| `1`-`22` | Numéro de frette |
| `x` | Corde mutée |

### Patterns dans la tablature

Tous les symboles sont représentés :

- **D, d, U, u, X, x** : Accord complet (toutes les cordes alignées)
- **F, f, W, w** : Accord complet (flams et double mutes affichés comme accord)
- **B, b** : Note de basse seule sur la bonne corde
- **0, 1, 2, 3, 4** : Note d'arpège seule sur la bonne corde
- **`.`** : Rien (laisser sonner précédent)
- **` `** : Rien (silence)

### Résolution

La résolution (`chars_per_beat`) contrôle la précision horizontale :

- **2** : Faible résolution (pour patterns lents)
- **4** : Standard (recommandé)
- **8** : Haute résolution (pour double croches)

**Exemple** avec step=0.25 et chars_per_beat=4 :
- 1 beat = 4 caractères
- 1 step (0.25 beat) = 1 caractère

### Largeur de ligne

Le paramètre `line_width` découpe automatiquement la tablature :

```gdscript
// Largeur 40
 0   1   2   3   4   5   6   7   8   9
e|--0--3--0--3--0--3--0--3--0--3--0--3-|
...

 10  11  12  13  14  15
e|--0--3--0--3--0--3--0--|
...
```

### Marqueurs de temps

Avec `show_time_markers = true`, les numéros de beats apparaissent :

```
 0   1   2   3
e|--0--0--0--0--|
B|--1--1--1--1--|
...
```

---

## Notes techniques

### Durée totale

La durée totale est calculée comme :
```gdscript
total_duration = max(
    durée_de_chord_grid,
    durée_de_pattern_sequence
)
```

Les deux bouclent pour remplir cette durée.

### Sustain des arpèges

Les notes d'arpège (0-4) se prolongent indéfiniment jusqu'à interruption par :
1. La même note rejouée (gère l'overlap)
2. Un changement d'accord dans `chord_grid`
3. Un strum (D, d, U, u, X, x, F, f, W, w)
4. Un silence (espace)

**Ne s'interrompent PAS** entre elles (peuvent sonner ensemble).

### Swing

Le swing n'affecte que les positions **impaires** (1, 3, 5, 7, 9, 11, 13, 15) du pattern 16 pas.

Formule : `time_swung = time + (step_length / 3.0) × swing_amount`

### Transitions d'accords

Le post-processing `_process_chord_transitions()` :
1. Identifie les notes communes entre accords consécutifs
2. Raccourcit les notes **non communes** selon `chord_transition_gap`
3. Laisse les notes communes en legato

### Pitch Overlap

Pour éviter les overlaps MIDI, `_handle_pitch_overlap()` tronque automatiquement une note si la même note (même pitch) est rejouée.

---

## Performances

### Optimisations

- Les patterns sont pré-calculés (pas de parsing à chaque beat)
- La grille d'accords utilise une recherche binaire optimisée
- Le swing est appliqué une seule fois par step

### Limites

- Maximum testé : 100 accords × 50 patterns = ~50 000 notes
- Génération instantanée pour des progressions typiques (4-8 accords)
- La tablature ASCII peut devenir large avec de longues durées

---

## Dépannage

### "Pattern must be exactly 16 characters"

**Cause** : Pattern trop court ou trop long

**Solution** : Le pattern est auto-ajusté, mais vérifier la longueur :
```gdscript
var p = "D.u"  # Trop court
# Devient automatiquement "D.u             "
```

### "Chord grid is empty"

**Cause** : `chord_grid` vide lors de `generate()`

**Solution** :
```gdscript
player.set_chord_grid([chord1, chord2])
```

### "No patterns in pattern_sequence"

**Cause** : `pattern_sequence` vide lors de `generate()`

**Solution** :
```gdscript
player.pattern_sequence = [pattern1]
```

### Les arpèges ne s'interrompent pas

**Cause** : Pas de symbole d'interruption dans le pattern

**Solution** : Ajouter un strum (D, u, etc.) ou un silence après les arpèges :
```gdscript
"0.1.2.3.D...d..."  # D interrompt les arpèges
"0.1.2.3. ...d..."  # Espace interrompt aussi
```

### Tablature incorrecte

**Cause** : Méthodes manquantes dans `GuitarChord`

**Solution** : Implémenter :
- `get_tab_absolute_as_array()`
- `get_bass_notes_with_string()`
- `get_arp_note_with_string(idx)`

---

## Licence et crédits

FolkGuitarPlayer - Système de génération de patterns de guitare folk

Développé pour Godot Engine (GDScript)

---

## Changelog

### Version actuelle

- ✅ Système de patterns 16 pas avec `StrumPattern`
- ✅ Génération MIDI avec humanisation
- ✅ Swing configurable (binaire → ternaire)
- ✅ Symboles : strums, mutes, flams, basses, arpèges
- ✅ Sustain prolongé pour arpèges
- ✅ Config override par pattern
- ✅ Transitions d'accords avec raccourcissement
- ✅ Tablatures ASCII quantizées
- ✅ Générateur procédural (`GuitarPatternGenerator`)
- ✅ Filtrage de cordes (`max_chords_strings`)
- ✅ Accents sur temps forts pour notes simples

---

**Fin de la documentation**
