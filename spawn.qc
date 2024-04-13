
#ifdef HIPNOTIC

/*QUAKED func_spawn (0 .5 .8) (-32 -32 -24) (32 32 64) big/ambush megahealth
This will spawn a thing upon being used. The thing that
is spawned depends upon the value of "spawnfunction".
"spawnclassname" should contain the same value as "spawnfunction".
If "spawnfunction" is unspecified a random monster is chosen.
The angles, target and all flags are passed on
Think of it like setting up a normal entity.
"spawnsilent" set this to 1 if you want a silent spawn.
"spawnmulti" set this to 1 if you want this spawn to be reoccuring.
*/
void () func_spawn =
{
	float chance;

	if (!self.spawnfunction)
	{
		chance = random ();

		if (chance < 0.5)
			self.spawnfunction = monster_dog;
		else if (chance < 0.8)
			self.spawnfunction = monster_ogre;
		else if (chance < 0.92)
			self.spawnfunction = monster_demon1;
		else if (chance < 0.97)
			self.spawnfunction = monster_zombie;
		else
			self.spawnfunction = monster_shambler;
	}

	// turn into a copper monster spawner

	if (self.spawnmulti)
		self.count = -1;

	self.spawnflags |= SPAWN_TRIGGERED;
	if (self.spawnsilent)
		self.spawnflags |= SPAWN_NO_TFOG;

	self.spawnfunction ();
}

/*QUAKED func_spawn_small (0 .5 .8) (-16 -16 -24) (16 16 40) big/ambush megahealth
This will spawn a thing upon being used. The thing that
is spawned depends upon the value of "spawnfunction".
"spawnclassname" should contain the same value as "spawnfunction".
If "spawnfunction" is unspecified a random monster is chosen.
The angles, target and all flags are passed on
Think of it like setting up a normal entity.
"spawnsilent" set this to 1 if you want a silent spawn.
"spawnmulti" set this to 1 if you want this spawn to be reoccuring.
*/
void () func_spawn_small = func_spawn;

#endif /* HIPNOTIC */
