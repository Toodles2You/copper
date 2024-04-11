/*
================================================================

EXPLOSIONS

================================================================
*/

#ifdef HIPNOTIC

static void () exploder_fire =
{
	activator = other;
	SUB_UseTargets ();

	if (self.dmg < 120)
		sound (self , CHAN_AUTO, "misc/shortexp.wav", self.volume, self.speed);
	else
		sound (self , CHAN_AUTO, "misc/longexpl.wav", self.volume, self.speed);

	if (self.dmg > 0)
		T_RadiusDamage (self, self.owner, self.dmg, world, DMGTYPE_SCRIPT | DMGTYPE_EXPLOSION);

	if (self.spawnflags & 1)
		BecomeExplosion ();
	else
		BecomeCrappyExplosion ();
}

static void () exploder_use =
{
	if (self.delay > 0)
	{
		self.nextthink = time + self.delay;
		self.delay = 0;
		self.think = exploder_fire;
	}
	else
	{
		exploder_fire ();
	}
}

/*QUAKED func_exploder (0.4 0 0) (0 0 0) (8 8 8) particles
Spawns an explosion when triggered.  Triggers any targets.

"dmg" specifies how much damage to cause.  Negative values
indicate no damage.  Default or 0 indicates 120.
"volume" volume at which to play explosions (default 1.0)
"speed" attenuation for explosions (default normal)
*/
void () func_exploder =
{
	precache_sound ("misc/shortexp.wav");
	precache_sound ("misc/longexpl.wav");
	self.classname = "exploder";
	self.use = exploder_use;

	if (self.dmg < 0)
		self.dmg = 0;
	self.dmg = zeroconvertdefault (self.dmg, 120);
	self.speed = zeroconvertdefault (self.speed, 1);
	self.volume = zeroconvertdefault (self.volume, 1);
}

static void () multi_exploder_fire =
{
	entity expl;

	self.nextthink = time + self.wait;
	if (self.state == 0)
	{
		self.state = 1;
		self.duration = time + self.duration;

		activator = other;
		SUB_UseTargets ();
	}

	if (time > self.duration)
	{
		remove (self);
		return;
	}

	expl = spawn();
	expl.owner = self.owner;
	expl.dmg = self.dmg;
	expl.origin_x = self.absmin_x + (random() * (self.absmax_x - self.absmin_x));
	expl.origin_y = self.absmin_y + (random() * (self.absmax_y - self.absmin_y));
	expl.origin_z = self.absmin_z + (random() * (self.absmax_z - self.absmin_z));

	sound (expl , CHAN_VOICE, "misc/shortexp.wav", self.volume, self.speed);

	if (self.dmg > 0)
		T_RadiusDamage (expl, self.owner, self.dmg, world, DMGTYPE_SCRIPT | DMGTYPE_EXPLOSION);

	if (self.spawnflags & 1)
		SUB_CallAsSelf (BecomeExplosion, expl);
	else
		SUB_CallAsSelf (BecomeCrappyExplosion, expl);
}

void (vector loc, float rad, float damage, float dur, float pause, float vol) multi_kaboom =
{
	entity expl;

	expl = spawn ();
	expl.origin = loc;
	expl.dmg = damage;
	expl.duration = dur;
	expl.wait = pause;
	expl.owner = world;
	expl.absmin = expl.origin - (rad * '1 1 1');
	expl.absmax = expl.origin + (rad * '1 1 1');
	expl.think = multi_exploder_fire;
	expl.volume = vol;

	SUB_CallAsSelf (multi_exploder_fire, expl);
}

static void () multi_exploder_use =
{
	if (self.delay > 0)
	{
		self.nextthink = time + self.delay;
		self.delay = 0;
		self.think = multi_exploder_fire;
	}
	else
	{
		self.think = multi_exploder_fire;
		multi_exploder_fire ();
	}
}

/*QUAKED func_multi_exploder (0.4 0 0) ?
Spawns an explosion when triggered.  Triggers any targets.
size of brush determines where explosions will occur.

"dmg" specifies how much damage to cause from each explosion
Negative values indicate no damage.  Default or 0 indicates 120.
"delay" delay before exploding (Default 0 seconds)
"duration" how long to explode for (Default 1 second)
"wait" time between each explosion (default 0.25 seconds)
"volume" volume to play explosion sound at (default 0.5)
"speed" attenuation for explosions (default normal)
*/
void () func_multi_exploder =
{
	precache_sound ("misc/shortexp.wav");
	precache_sound ("misc/longexpl.wav");
	self.classname = "exploder";
	self.use = multi_exploder_use;

	setmodel (self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";

	self.dmg = zeroconvertdefault (self.dmg, 120);
	self.duration = zeroconvertdefault (self.duration, 1);
	self.speed = zeroconvertdefault (self.speed, 1);
	self.volume = zeroconvertdefault (self.volume, 0.5);
	self.wait = zeroconvertdefault (self.wait, 0.25);
}

#endif /* HIPNOTIC */
