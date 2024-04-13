/*
==============================================================================

SPIKE MINE

==============================================================================
*/

#ifdef HIPNOTIC

static void () spikemine_Home =
{
	entity head, selected;
	float cur_dist, head_dist;
	vector dir, vtemp;

	self.frame = cycle (self.frame, 9);
	self.nextthink = time + 0.2;
	self.think = spikemine_Home;

	// look in our immediate vicinity
	if (self.search_time < time)
	{
		selected = world;
		cur_dist = 2000;
		head = findradius (self.origin, 2000);
		while (head)
		{
			if (!(head.flags & FL_NOTARGET) && (head.flags & FL_CLIENT))
			{
				if (visible (head) && head.health > 0)
				{
					head_dist = vlen (head.origin - self.origin);
					if (head_dist < cur_dist)
					{
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}

		if (selected != world)
			sound (self, CHAN_VOICE, "hipitems/spikmine.wav", 1, ATTN_NORM);

		self.enemy = selected;
		self.search_time = time + 1.3;
	}

	if (self.enemy == world)
	{
		sound (self, CHAN_VOICE, "misc/null.wav", 1, ATTN_NORM);
		self.velocity = VEC_ORIGIN;
		return;
	}

	vtemp = self.enemy.origin + '0 0 10';
	dir = normalize (vtemp - self.origin);

	if (infront (self.enemy))
		self.velocity = dir * (skill * 50 + 50);
	else
		self.velocity = dir * (skill * 50 + 150);
}

static void () spikemine_die =
{
	sound (self, CHAN_VOICE, "misc/null.wav", 1, ATTN_NORM);
	T_RadiusDamage (self, self, 110, self);
	BecomeExplosion ();
}

static void () spikemine_Touch =
{
	if (self.health <= 0)
		return;
	if (!(other.flags & (FL_MONSTER | FL_CLIENT)) && other.classname != "spike")
		return;
	T_Damage (self, self, other, self.health + 10, DMGTYPE_SCRIPT);
}

static void () spike_mine_first_think =
{
	self.think = spikemine_Home;
	self.nextthink = time + 0.1;
	self.search_time = 0;
	self.takedamage = DAMAGE_AIM;
	self.use = monster_use;
}

/*QUAKED trap_spike_mine (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void () trap_spike_mine =
{
	if (!SUB_ShouldSpawn()) return;
	if (deathmatch)
	{
		remove (self);
		return;
	}

	precache_model ("progs/spikmine.mdl");
	precache_sound ("hipitems/spikmine.wav");

	setmodel (self, "progs/spikmine.mdl");
	setsize (self, self.mins, self.maxs);

	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_FLYMISSILE;

	self.avelocity = '-50 100 150';

	if (skill <= 1)
		self.health = 200;
	else
		self.health = 400;

	self.think = spike_mine_first_think;
	self.touch = spikemine_Touch;
	self.th_die = spikemine_die;
	self.th_stand = spikemine_Home;
	self.th_walk = spikemine_Home;
	self.th_run = spikemine_Home;
	self.th_melee = spikemine_Home;
	self.th_missile = spikemine_Home;
	self.nextthink = time + 0.2;
	self.flags |= FL_MONSTER;

	if (self.deathtype == string_null)
		self.deathtype = "was blasted by a spike mine";

	addmonster (1);
}

#endif /* HIPNOTIC */
