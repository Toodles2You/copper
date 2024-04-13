/*
===============

LASERS

===============
*/

#ifdef HIPNOTIC

// find a monster within a narrow cone relative to the direction of the laser & veer towards it
static vector (vector dir) laser_ricochet =
{
	entity e;
	vector ric, delta;
	float head_dot, dot;

	// very narrow cone
	dot = 0.85;
	// default to normal velocity in-case no targets are found
	ric = dir;
	self.enemy = world;

	for (e = findradius (self.origin, 1000); e != world; e = e.chain)
	{
		// must be a monster & not our owner
		if (e == self || e == self.trueowner || !(e.flags & FL_MONSTER))
			continue;
		// must be alive & visible
		if (!alive (e) || !visible (e))
			continue;
		// don't target the same enemy as our buddy if we already have an enemy
		if (self.enemy && self.buddy && self.buddy.enemy == e)
			continue;

		// grab the direction to the target
		delta = normalize (e.origin - self.origin);
		// compare the direction to the normal velocity
		head_dot = dir * delta;

		// ensure the angle difference is the narrowest so far
		if (head_dot > dot)
		{
			// found a target
			head_dot = dot;
			ric = delta;
			self.enemy = e;
		}
	}

	return ric;
}

static void () laser_touch =
{
	vector spot1, spot2, oldvel;
	float damage, hurt, frac;

	if (other != self.trueowner && !CheckValidSpikeTouch()) return;

	oldvel = normalize (self.movedir);
	spot1 = self.origin - (16 * oldvel);
	spot2 = self.origin + (16 * oldvel);
	traceline (spot1, spot2, FALSE, self);
	self.origin = trace_endpos;

	hurt = FALSE;

	if (other.takedamage)
	{
		// scale damage based on travel time
		frac = 1.5 - clamp (self.attack_finished - time - 4.4, 0, 0.5) * 2;
		// round to nearest whole number
		damage = floor (self.dmg * frac + 0.5);
		
		// why are you hitting yourself?
		if (other == self.trueowner)
			damage /= 2;

		spawn_touchblood (damage);
		T_Damage (other, self, self.trueowner, damage);

		hurt = TRUE;
	}

	if (self.cnt > 0 && (!hurt || !(other.flags & (FL_MONSTER | FL_CLIENT))))
	{
		self.owner = self;
		self.cnt--;

		// ricochet!
		self.velocity = normalize (oldvel + 2 * trace_plane_normal);

		if (!deathmatch)
			self.velocity = laser_ricochet (self.velocity);

		self.velocity *= 1000;
		self.movedir = self.velocity;
		self.flags = not (self.flags, FL_ONGROUND);

		sound (self, CHAN_WEAPON, "hipweap/laserric.wav", 1, ATTN_STATIC);

		return;
	}

	if (!hurt)
		gunshot (self.origin);

	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);

	remove (self);
}

// toodles: doubled the frequency of this check
static void () laser_think =
{
	if (time > self.attack_finished)
	{
		remove (self);
		return;
	}

	self.flags = not (self.flags, FL_ONGROUND);
	self.velocity = self.movedir;
	self.angles = vectoangles (self.velocity);
	self.nextthink = time + 0.05;
}

/*
========
launch_cannonlaser
used by the player laser cannon & armagon
========
*/
entity (vector org, vector vel, float damage, float lit) launch_cannonlaser =
{
	entity spike;

	spike = launch_projectile (org, vel, "hiplaser");
	spike.movedir = vel;

	if (lit)
	{
		spike.effects = EF_DIMLIGHT;
	}

	SUB_ChangeModel (spike, "progs/lasrspik.mdl");
	spike.avelocity = '0 0 400';

	spike.dmg = damage;
	spike.cnt = 2; // how many times the laser can ricochet
	spike.touch = laser_touch;
	spike.think = laser_think;
	spike.nextthink = time;
	spike.attack_finished = time + 5; // when the laser will disappear

	return spike;
}

/*
=================
W_FireLaser
=================
*/
void () W_FireLaser =
{
	entity spike1, spike2;
	vector org, dir, v, out;
	float ofs, aofs;

	dir = aim (self, AUTOAIM_DIST);
	v = vectoangles (dir);
	v_x *= -1; // pitch comes back inverted from vectoangles :|
	makevectors (v);

	ofs = 6;
	out = v_forward;
	out_z = 0;
	out = normalize (out);
	org = self.origin + ((12 - ofs) * v_up) + (12 * out);
	dir = aim (self, 1000) * 1000;
	aofs = ofs * 0.707;

	if (mod (self.cnt, 2))
	{
		// one laser from the top
		org = org + (ofs * v_up);

		if (random () < 0.1)
			launch_cannonlaser (org, dir, 27, TRUE);
		else
			launch_cannonlaser (org, dir, 27, FALSE);
	}
	else
	{
		// two lasers from the bottom
		org = org - (aofs * v_up);

		org = org + (aofs * v_right);
		spike1 = launch_cannonlaser (org, dir, 14, FALSE);

		org = org - (2 * aofs * v_right);
		spike2 = launch_cannonlaser (org, dir, 14, FALSE);

		spike1.buddy = spike2;
		spike2.buddy = spike1;
	}

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	sound (self, CHAN_WEAPON, "hipweap/laserg.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;
	self.attack_finished = time + 0.095;
	self.cnt = cycle (self.cnt, 8);
}

#endif /* HIPNOTIC */
