/*
===============

LASERS

===============
*/

#ifdef HIPNOTIC

static void () laser_touch =
{
	vector spot1, spot2, oldvel;
	float damage;

	if (other != self.trueowner && !CheckValidSpikeTouch()) return;

	oldvel = normalize (self.movedir);
	spot1 = self.origin - (16 * oldvel);
	spot2 = self.origin + (16 * oldvel);
	traceline (spot1, spot2, FALSE, self);
	self.origin = trace_endpos;

	if (other.takedamage)
	{
		damage = self.dmg;
		
		// why are you hitting yourself?
		if (other == self.trueowner)
		{
			damage /= 2;
		}

		spawn_touchblood (damage);
		T_Damage (other, self, self.trueowner, damage);
	}
	else
	{
		if (self.cnt > 0 && random () >= 0.15)
		{
			self.owner = self;
			self.cnt--;

			self.dmg *= 0.9;

			// ricochet!
			self.velocity = oldvel + (2 * trace_plane_normal);
			self.velocity = normalize (self.velocity);
			self.velocity = 1000 * self.velocity;
			self.movedir = self.velocity;

			self.flags = not (self.flags, FL_ONGROUND);

			sound (self, CHAN_WEAPON, "hipweap/laserric.wav", 1, ATTN_STATIC);
			return;
		}

		gunshot (self.origin);
	}

	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	// toodles: Spawn the cool laser effect, too!
	particle (self.origin, trace_plane_normal * 0.01, 235, 15);

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
used by the player laser cannon
========
*/
static entity (vector org, vector vel, float damage, float lit) launch_cannonlaser =
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
		{
			launch_cannonlaser (org, dir, 25, TRUE);
		}
		else
		{
			launch_cannonlaser (org, dir, 18, FALSE);
		}
	}
	else
	{
		// two lasers from the bottom
		org = org - (aofs * v_up);

		org = org + (aofs * v_right);
		launch_cannonlaser (org, dir, 18, FALSE);

		org = org - (2 * aofs * v_right);
		launch_cannonlaser (org, dir, 18, FALSE);
	}

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	sound (self, CHAN_WEAPON, "hipweap/laserg.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;
	self.attack_finished = time + 0.095;
	self.cnt = cycle (self.cnt, 8);
}

#endif /* HIPNOTIC */
