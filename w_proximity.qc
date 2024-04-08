
/*
===============

BOMBS

===============
*/

#ifdef HIPNOTIC

static void () ProximityExplode =
{
	T_RadiusDamage (self, self.trueowner, 95, world, DMGTYPE_EXPLOSION);
	BecomeExplosion ();
}

static void () ProximityGrenadeExplode =
{
	self.takedamage = DAMAGE_NO;
	self.nextthink = time + 0.1;
	self.think = ProximityExplode;
}

static void() ProximityBomb =
{
	entity e;

	self.nextthink = time + 0.25;

	// bomb has expired or the object it's stuck to has moved
	if (time > self.lifetime_finished || self.buddy.velocity != VEC_ORIGIN)
	{
		ProximityGrenadeExplode ();
		ProximityExplode ();
		return;
	}

	self.owner = world;
	self.takedamage = DAMAGE_YES;

	for (e = findradius (self.origin, 140); e != world; e = e.chain)
	{
		if (e == self)
			continue;

		// check for living monsters or players
		if ((e.flags & (FL_CLIENT | FL_MONSTER)) != 0)
		{
			if (e.takedamage == DAMAGE_NO || e.health <= 0)
				continue;
		}
		else
		{
			// check for any moving proximity bombs
			if (e.state != 0 || e.classname != self.classname)
				continue;
		}

		// line of sight
		traceline2 (self.origin, e.origin, self, TRACE_NOMONSTERS);

		if (trace_fraction != 1.0 && trace_ent != e)
			continue;

		// beep beep!
		sound (self, CHAN_WEAPON, "hipweap/proxwarn.wav", 1, ATTN_NORM);
		ProximityGrenadeExplode ();
		self.nextthink = time + 0.5;
		break;
	}
}

static void () ProximityGrenadeTouch =
{
	if (other == self.owner) return; // don't explode on owner
	if (CheckProjectilePassthru()) return;

	if (other.classname == self.classname)
		return;

	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	self.movetype = MOVETYPE_TOSS;

	// already armed
	if (self.state == 1)
		return;

	if (other.takedamage == DAMAGE_AIM || other.velocity != VEC_ORIGIN)
	{
		T_MissileExplode (95, 95);
		T_ExplosiveTouch ();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM); // bounce sound

	// still object, stick to it
	self.movetype = MOVETYPE_NONE;
	self.velocity = VEC_ORIGIN;
	self.avelocity = VEC_ORIGIN;
	setsize (self, '-8 -8 -8', '8 8 8');

	self.state = 1;
	self.buddy = other;

	// restore the original think delay
	self.think = ProximityBomb;
	if (self.pausetime > time)
	{
		self.nextthink = self.pausetime;
	}
	else
	{
		self.think ();
	}
}

/*
================
W_FireProximityGrenade
================
*/
void() W_FireProximityGrenade =
{
	entity g;
	float base;
	vector gvel;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	sound (self, CHAN_WEAPON, "hipweap/proxbomb.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;

	// set grenade speed
	makevectors (self.v_angle);
	base = 200;
	if (self.v_angle_x)
		gvel = v_forward * base * 3 + v_up * base + crandom() * v_right * 10 + crandom() * v_up * 10;
	else
	{
		gvel = aim(self, AUTOAIM_DIST);
		gvel = gvel * base * 3;
		gvel_z = base;
	}

	g = toss_projectile (self.origin, gvel, "proximity_grenade");
	g.lifetime_finished = time + 15 + (10 * random ());
	setsize (g, '-1 -1 -1', '1 1 1');

	SUB_ChangeModel (g, "progs/proxbomb.mdl");
	g.avelocity = '100 600 100';

	// retooled this to work with copper projectile thinking
	g.health = 5;
	g.buddy = world;
	g.pausetime = time + 2;
	g.touch = ProximityGrenadeTouch;
	g.th_die = ProximityGrenadeExplode;

	self.attack_finished = time + 0.6;
}

#endif /* HIPNOTIC */
