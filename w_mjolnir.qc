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

static void (vector p1, vector p2, entity from, float damage) W_HammerDamage =
{
	entity e1, e2;
	vector f;

	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline2 (p1, p2, self, 0);

	if (trace_ent.takedamage && !has_wetsuit (trace_ent))
	{
		particle (trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage (trace_ent, from, from, damage, DMGTYPE_LIGHTNING);

		if (self.classname == "player" && other.classname == "player")
		{
			trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline2 (p1 + f, p2 + f, self, 0);

	if (trace_ent != e1 && trace_ent.takedamage && !has_wetsuit (trace_ent))
	{
		particle (trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage (trace_ent, from, from, damage, DMGTYPE_LIGHTNING);
	}
	e2 = trace_ent;

	traceline2 (p1 - f, p2 - f, self, 0);

	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage && !has_wetsuit (trace_ent))
	{
		particle (trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage (trace_ent, from, from, damage, DMGTYPE_LIGHTNING);
	}
}

static void () W_LightningThink =
{
	vector org, dst, vec, end;
	entity head, selected;
	float cur_dist, head_dist, dot, oldstate, dam;

	if (time > self.delay)
	{
		if (self.enemy != world)
		{
			self.enemy.customflags = not (self.enemy.customflags, CFL_STRUCKBYMJOLNIR);
		}
		remove (self);
		return;
	}

	oldstate = self.state;

	if (self.state == 0)
	{
		// look in our immediate vicinity
		self.enemy = world;
		selected = world;
		cur_dist = self.distance;

		head = findradius (self.owner.origin, self.distance);
		while (head)
		{
			if (!(head.flags & FL_NOTARGET) && (head.flags & (FL_MONSTER | FL_CLIENT)))
			{
				if (visible (head) && head != self.owner.owner && head.health > 0)
				{
					head_dist = vlen (head.origin - self.buddy.origin);
					if (head_dist < cur_dist && !(head.customflags & CFL_STRUCKBYMJOLNIR))
					{
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}

		if (selected != world)
		{
			self.state = 1;
			self.enemy = selected;
			self.enemy.customflags |= CFL_STRUCKBYMJOLNIR;
		}
		else
		{
			makevectors (self.v_angle);
			org = self.owner.origin;
			end = org + v_forward * 200;
			end = end + (((400 * random ()) - 200) * v_right);

			traceline2 (org, end, self, TRACE_NOMONSTERS);

			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
			WriteEntity (MSG_BROADCAST, self);
			WriteCoord (MSG_BROADCAST, org_x);
			WriteCoord (MSG_BROADCAST, org_y);
			WriteCoord (MSG_BROADCAST, org_z);
			WriteCoord (MSG_BROADCAST, trace_endpos_x);
			WriteCoord (MSG_BROADCAST, trace_endpos_y);
			WriteCoord (MSG_BROADCAST, trace_endpos_z);

			self.nextthink = time + 0.1;
			return;
		}
	}

	org = self.buddy.origin;
	dst = self.enemy.absmin + 0.25 * (self.enemy.absmax - self.enemy.absmin);
	dst = dst + (random () * 0.5 * (self.enemy.absmax - self.enemy.absmin));
	traceline2 (org, dst, self.owner.owner, TRACE_NOMONSTERS);

	if (trace_fraction != 1.0 || self.enemy.health <= 0)
	{
		self.enemy.customflags = not (self.enemy.customflags, CFL_STRUCKBYMJOLNIR);
		self.state = 0;
		self.nextthink = time + 0.1;
		return;
	}

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	vec = normalize (self.enemy.origin - self.owner.origin);
	dot = vec * self.owner.movedir;
	head = self;
	self = self.owner.owner;

	if (oldstate == 0)
		dam = 80;
	else
		dam = 30;

	if (dot > 0.3)
		W_HammerDamage (org, trace_endpos, self, dam);
	else
		W_HammerDamage (org, trace_endpos, self, dam * 0.5);

	self = head;
	self.nextthink = time + 0.2;
}

static void (entity prev, entity own, float dst) W_SpawnMjolnirLightning =
{
	entity e;
	// spawn actual lightning
	e = spawn ();
	e.delay = time + 0.8;
	e.state = 0;
	e.buddy = prev;
	e.distance = dst;
	e.owner = own;
	e.v_angle = self.angles;
	e.v_angle_x = 0;
	e.v_angle_z = 0;
	e.origin = own.origin;
	e.think = W_LightningThink;
	e.nextthink = time;
}

static void () W_SpawnMjolnirBase =
{
	entity e;
	// spawn lightning base
	e = spawn ();
	e.origin = trace_endpos;
	e.flags = 0;
	e.owner = self;
	e.customflags |= CFL_STRUCKBYMJOLNIR;
	e.think = SUB_Remove;
	e.nextthink = time + 1;
	// sound (e, CHAN_AUTO, "hipweap/mjolslap.wav", 1, ATTN_NORM);
	sound (e, CHAN_WEAPON, "hipweap/mjolhit.wav", 1, ATTN_NORM);
	makevectors (self.v_angle);
	e.movedir = v_forward;
	W_SpawnMjolnirLightning (e, e, 350);
	W_SpawnMjolnirLightning (e, e, 350);
	W_SpawnMjolnirLightning (e, e, 350);
	W_SpawnMjolnirLightning (e, e, 350);
}

void (vector source) W_FireMjolnirLightning =
{
	float cells;

	// explode if under water
	if (self.waterlevel >= WL_WAIST)
	{
		cells = max (self.ammo_cells, 15);

		self.ammo_cells = 0;
		W_SetCurrentAmmo ();

		T_RadiusDamage (self, self, 35 * cells, world, DMGTYPE_EXPLOSION | DMGTYPE_LIGHTNING);

		sound (self, CHAN_WEAPON, "hipweap/mjolhit.wav", 1, ATTN_NORM);
		return;
	}

	traceline2 (source , source - v_up * 50, self, 0);
	if (trace_ent == self)
		return;	// some notrace shit happened
	if (trace_fraction <= 0.3)
		return;
	if (trace_fraction == 1.0)
		return;

	self.show_hostile = time + 1; // wake monsters up
	self.currentammo = self.ammo_cells = max (self.ammo_cells - 15, 0);
	sound (self, CHAN_AUTO, "hipweap/mjolslap.wav", 1, ATTN_NORM);
	W_SpawnMjolnirBase ();
	self.attack_finished = time + 1.5;
}

void (float lightning) W_FireMjolnir =
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
	{
		// bring on the thundah
		// ...unless the player picked up cells mid-swing whilst underwater
		if (lightning || (self.ammo_cells >= 15 && self.waterlevel < WL_WAIST))
		{
			W_FireMjolnirLightning (source);
		}
		return;
	}
	
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
