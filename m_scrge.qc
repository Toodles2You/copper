/*
==============================================================================

SCOURGE

==============================================================================
*/

#ifdef HIPNOTIC

$cd hipwork/models/scourge
$origin 0 0 23
$base base

$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6
$frame stand7 stand8 stand9 stand10 stand11 stand12

$frame walk1 walk2 walk3 walk4 walk5 walk6

$frame shoot1 shoot2

$frame sting1 sting2 sting3 sting4 sting5 sting6
$frame sting7 sting8 sting9 sting10 sting11

$frame pain1 pain2 pain3 pain4 pain5

$frame death1 death2 death3 death4 death5

static float () ScourgeCheckAttack =
{
	float chance;

	if (!CheckClearAttack ()) return FALSE;

	if (enemy_range == RANGE_MELEE && z_overlap (self.enemy))
	{
		if (CanDamage (self.enemy, self.origin))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (time < self.attack_finished)
		return FALSE;

	if (!enemy_vis)
		return FALSE;

	// randomly attack with melee if enemy has the ring of shadows
	if (has_invis (self.enemy))
	{
		if (random () < 0.2)
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	chance = (self.enemy.origin_z + self.enemy.view_ofs_z) - (self.origin_z + self.view_ofs_z);
	if (chance > 64)
	   return FALSE;
	else if (chance < -200)
	   return FALSE;

	if (time < self.attack_finished)
		return FALSE;

	if (enemy_range == RANGE_TOOFAR)
		return FALSE;

	self.attack_state = AS_MISSILE;
	self.attack_finished = time + 2 + 2 * random ();
	return TRUE;
}

//============================================================================

static void () ScourgeTriggerTouch =
{
	vector dir;

	if (!alive (self.owner))
	{
		remove (self);
		return;
	}

	if (other == self.owner)
		return;
	if (other.flags & (FL_MONSTER | FL_CLIENT))
		return;
	if (other.movetype != MOVETYPE_FLYMISSILE)
		return;

	// check if the missile is heading towards the scourge
	dir = self.owner.origin - other.origin;
	dir = normalize (dir);

	if ((dir * normalize (other.velocity)) < 0.8)
		return;

	// todo: this shouldn't be random on harder difficulties
	if (random () < 0.5)
		SUB_CallAsSelf (scourge_strafeleft1, self.owner);
	else
		SUB_CallAsSelf (scourge_straferight1, self.owner);

	self.touch = SUB_Null;
	self.nextthink = time + 1.5;
}

static void () ScourgeTriggerThink =
{
	if (!alive (self.owner))
	{
		remove (self);
		return;
	}

	self.touch = ScourgeTriggerTouch;

	// plop the trigger in front of the scourge
	makevectors (self.owner.angles);
	setorigin (self, self.owner.origin + (v_forward * 300));
	self.nextthink = time + 0.1;
}

static entity (entity e) scourge_spawn_field =
{
	entity trigger;
	trigger = spawn ();
	trigger.owner = e;
	trigger.solid = SOLID_TRIGGER;
	setsize (trigger, '-64 -64 -24', '64 64 64');
	trigger.think = ScourgeTriggerThink;
	trigger.touch = ScourgeTriggerTouch;
	trigger.nextthink = time + 0.1 + random ();
	return trigger;
}

//============================================================================

static void (float checkidle) scourge_scuttle =
{
	if (checkidle && random () < 0.1)
		sound (self, CHAN_VOICE, "scourge/idle.wav", 1, ATTN_IDLE);

	sound (self, CHAN_BODY, "scourge/walk.wav", 1, ATTN_IDLE);
}

static void () scourge_unscuttle =
{
	sound (self, CHAN_BODY, "misc/null.wav", 1, ATTN_IDLE);
}

//============================================================================

void() scourge_stand1 = [$stand1, scourge_stand2] {ai_stand (); scourge_unscuttle ();}
void() scourge_stand2 = [$stand2, scourge_stand3] {ai_stand ();}
void() scourge_stand3 = [$stand3, scourge_stand4] {ai_stand ();}
void() scourge_stand4 = [$stand4, scourge_stand5] {ai_stand ();}
void() scourge_stand5 = [$stand5, scourge_stand6] {ai_stand ();}
void() scourge_stand6 = [$stand6, scourge_stand7] {ai_stand ();}
void() scourge_stand7 = [$stand7, scourge_stand8] {ai_stand ();}
void() scourge_stand8 = [$stand8, scourge_stand9] {ai_stand ();}
void() scourge_stand9 = [$stand9, scourge_stand10] {ai_stand ();}
void() scourge_stand10 = [$stand10, scourge_stand11] {ai_stand ();}
void() scourge_stand11 = [$stand11, scourge_stand12] {ai_stand ();}
void() scourge_stand12 = [$stand12, scourge_stand1] {ai_stand ();}

//============================================================================

void() scourge_walk1 = [$walk1, scourge_walk2]
{
	scourge_scuttle (TRUE);
	ai_walk (8);
}
void() scourge_walk2 = [$walk2, scourge_walk3] {ai_walk (8);}
void() scourge_walk3 = [$walk3, scourge_walk4] {ai_walk (8);}
void() scourge_walk4 = [$walk4, scourge_walk5] {ai_walk (8);}
void() scourge_walk5 = [$walk5, scourge_walk6] {ai_walk (8);}
void() scourge_walk6 = [$walk6, scourge_walk1] {ai_walk (8);}

//============================================================================

void() scourge_run1 = [$walk1, scourge_run2]
{
	scourge_scuttle (TRUE);
	ai_run (18);
}
void() scourge_run2 = [$walk2, scourge_run3] {ai_run (14);}
void() scourge_run3 = [$walk3, scourge_run4] {ai_run (14);}
void() scourge_run4 = [$walk4, scourge_run5] {ai_run (14);}
void() scourge_run5 = [$walk5, scourge_run6] {ai_run (14);}
void() scourge_run6 = [$walk6, scourge_run1] {ai_run (14);}

//============================================================================

void() scourge_strafeleft1 = [$walk1, scourge_strafeleft2]
{
	scourge_scuttle (FALSE);
	ai_left (20);
}
void() scourge_strafeleft2 = [$walk2, scourge_strafeleft3] {ai_left (20);}
void() scourge_strafeleft3 = [$walk3, scourge_strafeleft4] {ai_left (20);}
void() scourge_strafeleft4 = [$walk4, scourge_strafeleft5] {ai_left (14);}
void() scourge_strafeleft5 = [$walk5, scourge_strafeleft6] {ai_left (14);}
void() scourge_strafeleft6 = [$walk6, scourge_run1] {ai_left (14);}

//============================================================================

void() scourge_straferight1 = [$walk1, scourge_straferight2]
{
	scourge_scuttle (FALSE);
	ai_right (20);
}
void() scourge_straferight2 = [$walk2, scourge_straferight3] {ai_right (20);}
void() scourge_straferight3 = [$walk3, scourge_straferight4] {ai_right (20);}
void() scourge_straferight4 = [$walk4, scourge_straferight5] {ai_right (14);}
void() scourge_straferight5 = [$walk5, scourge_straferight6] {ai_right (14);}
void() scourge_straferight6 = [$walk6, scourge_run1] {ai_right (14);}

//============================================================================

void() scourge_turn1 = [$walk1, scourge_turn2]
{
	scourge_scuttle (FALSE);
	ai_turn_in_place ();
}
void() scourge_turn2 = [$walk2, scourge_turn3] {ai_turn_in_place ();}
void() scourge_turn3 = [$walk3, scourge_turn4] {ai_turn_in_place ();}
void() scourge_turn4 = [$walk4, scourge_turn5] {ai_turn_in_place ();}
void() scourge_turn5 = [$walk5, scourge_turn6] {ai_turn_in_place ();}
void() scourge_turn6 = [$walk6, scourge_turn1] {ai_turn_in_place ();}

//============================================================================

static void (float ox) launch_scourgenail =
{
	vector src, vec;

	ai_face ();
	makevectors (self.angles);
	src = self.origin - '0 0 19' + v_right * ox + v_forward * 14;
	vec = self.enemy.origin + (200 * v_forward) - src;
	vec = normalize (vec);
	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	launch_nail (src, vec * 1000);

	self.attack_finished = time + 0.2;
}

static void() scourge_attack =
{
	self.effects |= EF_MUZZLEFLASH;

	float ox;
	switch (self.cnt)
	{
		case 0: ox = 40; break;
		case 1: ox = -56; break;
		case 2: ox = -40; break;
		case 3: ox = 56; break;
		case 4: ox = 40; break;
		case 5: ox = -56; break;
		case 6: ox = -40; break;
		case 7: ox = 56; break;
	}

	launch_scourgenail (ox);

	self.cnt = cycle (self.cnt, 8);
}

void() scourge_atk1 = [$shoot1, scourge_atk2]
{
	scourge_unscuttle ();
	self.cnt = 0;
	scourge_attack ();
}
void() scourge_atk2 = [$shoot2, scourge_atk3] {scourge_attack ();}
void() scourge_atk3 = [$shoot1, scourge_atk4] {scourge_attack ();}
void() scourge_atk4 = [$shoot2, scourge_atk5] {scourge_attack ();}
void() scourge_atk5 = [$shoot1, scourge_atk6] {scourge_attack ();}
void() scourge_atk6 = [$shoot2, scourge_atk7] {scourge_attack ();}
void() scourge_atk7 = [$shoot1, scourge_atk8] {scourge_attack ();}
void() scourge_atk8 = [$shoot2, scourge_run1]
{
	scourge_attack ();
	self.attack_finished = time + 4 * random ();
}

//============================================================================

static void () tail_whip =
{
	vector delta;
	float ldmg;

	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	ai_face ();
	if (self.deadflag) return;

	delta = self.enemy.origin - self.origin;

	if (vlen (delta) > 100)
		return;

	ldmg = (random () + random () + random ()) * 40;
	T_Damage (self.enemy, self, self, ldmg, DMGTYPE_MELEE);

	sound (self, CHAN_WEAPON, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward * 16, crandom () * 50 * v_right);
}

void() scourge_melee1 = [$sting1, scourge_melee2] {scourge_unscuttle (); ai_charge (3);}
void() scourge_melee2 = [$sting2, scourge_melee3] {ai_charge (3);}
void() scourge_melee3 = [$sting3, scourge_melee4] {ai_charge (2);}
void() scourge_melee4 = [$sting4, scourge_melee5] {ai_charge (2);}
void() scourge_melee5 = [$sting5, scourge_melee6]
{
	sound (self, CHAN_WEAPON, "scourge/tailswng.wav", 1, ATTN_NORM);
	ai_charge (3);
}
void() scourge_melee6 = [$sting6, scourge_melee7] {ai_charge (1);}
void() scourge_melee7 = [$sting7, scourge_melee8]
{
	tail_whip ();
}
void() scourge_melee8 = [$sting8, scourge_melee9] {ai_face ();}
void() scourge_melee9 = [$sting9, scourge_melee10] {ai_face ();}
void() scourge_melee10 = [$sting10, scourge_melee11] {ai_face ();}
void() scourge_melee11 = [$sting11, scourge_run1]
{
	ai_face ();
	ai_check_refire (scourge_melee1);
}

static void() scourge_melee =
{
	scourge_melee1 ();
	self.attack_finished = time + 2 * random ();
}

//============================================================================

void() scourge_pain1 = [$pain1, scourge_pain2]
{
	scourge_unscuttle ();
}
void() scourge_pain2 = [$pain2, scourge_pain3] {}
void() scourge_pain3 = [$pain3, scourge_pain4] {}
void() scourge_pain4 = [$pain4, scourge_pain5] {}
void() scourge_pain5 = [$pain5, scourge_run1] {}

static void (entity attacker, float damage) scourge_pain =
{
	if (random () * 50 > damage)
		return; // didn't flinch

	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "scourge/pain.wav", 1, ATTN_NORM);

	self.pain_finished = time + 2.0;
	scourge_pain1 ();
}

//============================================================================

void() scourge_die1 = [$death1, scourge_die2] {}
void() scourge_die2 = [$death2, scourge_die3] {}
void() scourge_die3 = [$death3, scourge_die4] {self.solid = SOLID_NOT;}
void() scourge_die4 = [$death4, scourge_die5] {}
void() scourge_die5 = [$death5, scourge_die5] {}

static void () scourge_die =
{
	remove (self.trigger_field);

	scourge_unscuttle ();

// check for gib
	if (self.health < -35)
	{
		Gib ("progs/h_scourg.mdl", self.health);
		return;
	}

// regular death
	sound (self, CHAN_VOICE, "scourge/pain2.wav", 1, ATTN_NORM);
	scourge_die1 ();
}

//============================================================================

static void () monster_scourge_spawn =
{
	self.classname = "monster_scourge";

	self.solid = SOLID_SLIDEBOX;

	setmodel (self, "progs/scor.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 300;

	self.th_stand = scourge_stand1;
	self.th_walk = scourge_walk1;
	self.th_run = scourge_run1;
	self.th_pain = scourge_pain;
	self.th_die = scourge_die;
	self.th_melee = scourge_melee;
	self.th_missile = scourge_atk1;
	self.th_checkattack = ScourgeCheckAttack;
	self.yaw_speed = 60;
	self.trigger_field = scourge_spawn_field (self);

	if (self.deathtype == string_null)
		self.deathtype = "was stung by a Centroid";

	walkmonster_start ();
}

void () monster_scourge_spawner = {mon_spawner_use (monster_scourge_spawn);}

/*QUAKED monster_scourge (1 0 0) (-32 -32 -24) (32 32 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Centroid, 300 health points.

Flags:
"ambush" only wake up on seeing the player, not another monster getting angry

"Triggered"	will not spawn until triggered - triggering again will wake him up. Set 'count' to make this a multi-use spawner.
"NoTfog" 	supress teleport glitter when spawned with 'triggered'
"NoTelefrag" will silently fail to spawn if doing so would telefrag an existing monster. will try again automatically 2x/second until it succeeds.
"Instawake" spawn angry at activator

Keys:
"target" entity to trigger when killed
"targetname" entity name
"movedir" set to a velocity to make the monster jump on awakening
*/
/*FGD
@PointClass base(Monster) size(-32 -32 -24, 32 32 64) model({ "path": ":progs/scor.mdl" }) = monster_scourge : "Centroid" []
*/
void () monster_scourge =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/scor.mdl");
	precache_model ("progs/h_scourg.mdl");
	precache_model2 ("progs/laser.mdl");
	precache_model ("progs/s_light.mdl");

	precache_sound ("scourge/idle.wav");
	precache_sound ("scourge/pain.wav");
	precache_sound ("scourge/pain2.wav");
	precache_sound ("scourge/sight.wav");
	precache_sound ("scourge/tailswng.wav");
	precache_sound ("scourge/walk.wav");
	precache_sound ("shambler/smack.wav");

	self.health = 300;

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	if ( monster_spawnsetup( monster_scourge_spawner ) ) return;

	addmonster (1);
	monster_scourge_spawn ();
}

#endif /* HIPNOTIC */
