# Adding Your Own 3D Meshes (Enemies, Bosses, Player Weapon)

This project ships with procedurally-generated capsule/sphere enemy bodies so it
runs with zero external assets. If you have your own meshes (`.glb`, `.gltf`,
`.fbx`, or `.obj`), here's how to drop them in.

## 1. Importing the mesh into Godot

1. Copy your model file (e.g. `Soldier.glb`) into `Assets/Models/` (create the
   folder if it doesn't exist).
2. Open the project in the Godot editor once — Godot will auto-import the file
   and generate a `.import` file next to it. (This step requires the actual
   Godot editor; it can't be done by hand-editing text files.)
3. Drag the imported model from the FileSystem dock into a new empty scene,
   or just reference it directly as a `PackedScene` — both work.

## 2. Hooking it up to an enemy

Every enemy (`BaseEnemy.tscn` and the 5 boss scenes in `Enemies/`) now has an
exported field for this:

```
custom_mesh_scene : PackedScene
```

In the Godot editor:
1. Select the enemy or boss scene (e.g. `Enemies/Archangel.tscn`).
2. Select the root `BaseEnemy` node.
3. In the Inspector, find **Custom Mesh Scene** and drag your `.glb`/model
   scene into the slot.

At runtime, `BaseEnemy.gd` will:
- Hide all procedural body parts (torso, head, arms, legs)
- Instance your mesh under `EnemyRoot`
- Automatically resize the black **corruption overlay** capsule to roughly
  wrap your mesh's bounding box

You do not need to edit any code — this is purely a scene/Inspector change.

## 3. Mesh requirements / tips

- **Origin**: your model's origin (0,0,0) should be at the character's feet,
  matching how the procedural body is set up (feet at y=0, head around y=1.8
  for a human-scale enemy).
- **Forward direction**: the character should face -Z (Godot's forward) in
  its rest pose, since `BaseEnemy.gd` rotates the whole `CharacterBody3D` to
  face the player.
- **Scale**: aim for roughly 1.8–2.0 units tall (Godot units ≈ meters) so it
  matches the existing collision capsule (`radius 0.4, height 1.9`). If your
  model is a different scale, adjust the `scale` of the node you drag in
  inside your custom mesh's sub-scene, not the BaseEnemy node itself (that's
  reserved for the boss 2x/enemy_scale system).
- **Animation**: if your model has its own `AnimationPlayer` (walk/idle/attack
  clips), you can extend `BaseEnemy.gd`'s `_animate()` function to call
  `anim_player.play("walk")` etc. instead of the procedural bob/swing — the
  hook points are clearly marked by `AnimState.WALK`, `.IDLE`, `.ATTACK`.

## 4. Replacing the player's spear

The spear already uses a real model: `Assets/SpearModel/SpearModel.obj`,
wired up in `Scenes/ThrownSpear.tscn` and `Scenes/Player.tscn` (the
`spear_scene` export on the Player). To swap it:
1. Drop your new weapon model in `Assets/Models/`.
2. Open `Scenes/ThrownSpear.tscn`, replace the `MeshInstance3D.mesh` with
   your model's mesh resource (or replace the whole node with your imported
   scene, keeping the `CollisionShape3D` and the root script attached).

## 5. World/environment props

`Scripts/WorldProps*.gd` (one per world: Heaven, Astral, Human, Serpent,
Hell) builds the environment purely from primitive meshes at runtime. If you
have your own environment assets (rocks, ruins, trees, buildings), the
cleanest approach is:

1. Build a small scene per prop (e.g. `Assets/Models/Pillar.glb` → wrap with
   collision in a `.tscn`).
2. In the relevant `WorldProps*.gd` script, replace a `make_box(...)` /
   `make_cylinder(...)` call with:
   ```gdscript
   var prop = preload("res://Assets/Models/Pillar.tscn").instantiate()
   prop.position = Vector3(x, y, z)
   add_child(prop)
   ```
   Add your own `CollisionShape3D` inside that prop's scene if you want the
   player/enemies to collide with it.

This lets you mix-and-match: keep the procedural geometry for most of a
world's set-dressing, and swap in real models only where it matters most
(e.g. the boss throne, a hero statue, the demon king's altar).
