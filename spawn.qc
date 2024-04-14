
#ifdef HIPNOTIC

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
		self.count = -1; // infinite spawner
	else
		self.count = -2; // single-use but, increment the monster total upon spawning

	self.spawnflags |= SPAWN_TRIGGERED;
	if (self.spawnsilent)
		self.spawnflags |= SPAWN_NO_TFOG;

	self.spawnfunction ();
}

void () func_spawn_small = func_spawn;

#endif /* HIPNOTIC */
