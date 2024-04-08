/*
===============

MJOLNIR

===============
*/

#ifdef HIPNOTIC

void () W_MjolnirSwing =
{
	sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.8;
}

void () W_FireMjolnir =
{
	vector	source, org;
	float damage;
	if (self.health <= 0)
		return;

	makevectors (self.v_angle);
	source = self.origin + self.view_ofs;
	traceline2 (source, source + v_forward * 64, self, 0); // was 32
	if (trace_ent == self)
		return;	// some notrace shit happened
	if (trace_fraction == 1.0)
		return; // fixme: the lightning attack is stupid & i don't wanna deal with it right now
	
	self.show_hostile = time + 1; // wake monsters up
	
	org = trace_endpos - v_forward * 4;
	
	if (trace_ent.takedamage)
	{
		damage = 50;

		if (trace_ent.type == "zombie")
		{
			damage = 70;
		}

		trace_ent.customflags = trace_ent.customflags | CFL_AXEHITME;
		SpawnBlood (org, VEC_ORIGIN, damage);
		// just pulverize zombies, since that seemed to be the original intent
		T_Damage (trace_ent, self, self, damage, DMGTYPE_MELEE | DMGTYPE_ZKILL);

		if (trace_ent.flags & FL_MONSTER)
		{
			sound (self, CHAN_WEAPON, "hipweap/mjolslap.wav", 1, ATTN_NORM);
		}
		else
		{
			sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_IDLE);
		}
	}
	else
	{
		// hit wall
		sound (self, CHAN_WEAPON, "hipweap/mjoltink.wav", 1, ATTN_NORM);
		gunshot (org);
	}
}

#endif /* HIPNOTIC */
