# FolkGuitarPlayer Refactoring

## Résumé des changements

Cette refactorisation corrige l'architecture conceptuelle en séparant clairement les **données d'accord** (GuitarChord) et les **instructions d'interprétation** (FolkGuitarPlayer).

## Modifications principales

### 1. GuitarChord : Simplifié pour contenir uniquement les données

**Avant :**
```gdscript
var chord = GuitarChord.new()
chord.position = 0.0
chord.pattern = "DuDu"      # ❌ Pattern au niveau de l'accord
chord.step_length = 0.5     # ❌ Step length au niveau de l'accord
chord.notes = [40, 45, 50, 55, 59, 64]
```

**Après :**
```gdscript
var chord = GuitarChord.new()
chord.time = 0.0            # ✅ Renommé de "position" à "time"
chord.beat_length = 4.0     # ✅ Nouveau : durée de l'accord
chord.notes = [40, 45, 50, 55, 59, 64]
# OU
chord.midiNotes = PoolIntArray([40, 45, 50, 55, 59, 64])
```

**Propriétés supprimées :**
- `pattern` : déplacé vers FolkGuitarPlayer
- `step_length` : déplacé vers FolkGuitarPlayer
- `override_velocity_base` : supprimé (simplification)
- `override_strum_duration` : supprimé (simplification)

**Nouvelles propriétés :**
- `time` : position temporelle (renommé de "position")
- `beat_length` : durée de l'accord
- `midiNotes` : alternative à `notes` utilisant PoolIntArray

**Nouvelle méthode :**
- `get_notes()` : retourne les notes en Array (gère `notes` et `midiNotes`)

---

### 2. FolkGuitarPlayer : Pattern et step_length au niveau du player

**Avant :**
```gdscript
var player = FolkGuitarPlayer.new()
player.set_chord_grid(chords)  # Chaque accord définit son propre pattern
var notes = player.generate()
```

**Après :**
```gdscript
var player = FolkGuitarPlayer.new()
player.rhythm_pattern = "DuDuD Du"   # ✅ Pattern unique qui boucle
player.step_beat_length = 0.5        # ✅ Durée de chaque pas
player.set_chord_grid(chords)        # Les accords ne contiennent que les données
var notes = player.generate()
```

**Nouvelles propriétés :**
- `rhythm_pattern : String` - Pattern rythmique qui boucle sur toute la grille
- `step_beat_length : float` - Durée d'un pas du pattern (ex: 0.5 pour des croches)

---

### 3. Support des accords de taille variable (4, 5, 6 notes)

Le code s'adapte maintenant automatiquement aux accords de différentes tailles :

```gdscript
# Accord à 6 notes
var em6 = GuitarChord.new()
em6.notes = [40, 45, 50, 55, 59, 64]

# Accord à 5 notes
var am5 = GuitarChord.new()
am5.notes = [45, 50, 53, 57, 64]

# Accord à 4 notes
var c4 = GuitarChord.new()
c4.midiNotes = PoolIntArray([50, 55, 59, 64])

# Le player s'adapte automatiquement
player.set_chord_grid([em6, am5, c4])
```

---

## Exemple d'utilisation

```gdscript
# Créer la grille d'accords
var chords = []

# Em pendant 4 temps
var em = GuitarChord.new()
em.time = 0.0
em.beat_length = 4.0
em.notes = [40, 45, 50, 55, 59, 64]
chords.append(em)

# Am pendant 4 temps
var am = GuitarChord.new()
am.time = 4.0
am.beat_length = 4.0
am.notes = [40, 45, 50, 53, 57, 64]
chords.append(am)

# Configurer le player
var player = FolkGuitarPlayer.new()
player.rhythm_pattern = "DuDuD Du"   # Pattern folk classique
player.step_beat_length = 0.5        # Croches

# Optionnel : personnaliser la configuration
player.set_configuration({
    "humanize_timing": true,
    "velocity_randomization": 0.15
})

# Générer les notes MIDI
player.set_chord_grid(chords)
var midi_notes = player.generate()

# Afficher les résultats
player.print_notes()
print(player.get_stats())
```

---

## Architecture conceptuelle

```
┌─────────────────────┐
│   GuitarChord       │  Données pures de l'accord
│  ─────────────────  │
│  - time             │  Quand l'accord commence
│  - beat_length      │  Combien de temps il dure
│  - notes/midiNotes  │  Quelles notes jouer
│  - muted_strings    │  Cordes mutées (optionnel)
└─────────────────────┘
          │
          │ Fournit les accords à...
          ▼
┌─────────────────────┐
│ FolkGuitarPlayer    │  Interprète la grille
│  ─────────────────  │
│  - rhythm_pattern   │  Comment jouer (DuDu, etc.)
│  - step_beat_length │  Durée de chaque pas
│  - config           │  Paramètres de réalisme
└─────────────────────┘
          │
          │ Génère...
          ▼
┌─────────────────────┐
│   MIDI Notes        │  Notes MIDI finales
│  ─────────────────  │
│  - pitch            │
│  - position         │
│  - duration         │
│  - velocity         │
│  - string_index     │
└─────────────────────┘
```

---

## Avantages de cette architecture

1. **Séparation des responsabilités**
   - GuitarChord : données uniquement
   - FolkGuitarPlayer : interprétation et génération

2. **Flexibilité**
   - Un même pattern peut s'appliquer à toute une grille
   - Facile de changer le pattern sans modifier les accords
   - Le player peut avoir plusieurs modes (strum, arpège, ligne de basse...)

3. **Compatibilité**
   - Support de `notes` (Array) et `midiNotes` (PoolIntArray)
   - S'adapte automatiquement aux accords de 4, 5, ou 6 notes

4. **Simplicité**
   - API plus claire et intuitive
   - Moins de paramètres à gérer au niveau de l'accord
   - Pattern unique qui boucle = comportement prévisible

---

## Fichiers de test

- `example_usage.gd` : Exemples d'utilisation de la nouvelle API
- `test_refactoring.gd` : Tests unitaires (exécuter avec `godot --script test_refactoring.gd`)

---

## Breaking Changes

⚠️ **Migration nécessaire pour le code existant**

1. Remplacer `chord.position` par `chord.time`
2. Ajouter `chord.beat_length` pour chaque accord
3. Supprimer `chord.pattern` et `chord.step_length`
4. Définir `player.rhythm_pattern` et `player.step_beat_length`

**Exemple de migration :**
```gdscript
# Avant
chord.position = 0.0
chord.pattern = "DuDu"
chord.step_length = 0.5

# Après
chord.time = 0.0
chord.beat_length = 4.0
# Pattern et step_length sont maintenant au niveau du player
player.rhythm_pattern = "DuDu"
player.step_beat_length = 0.5
```
