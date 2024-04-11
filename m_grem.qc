/*
==============================================================================

GREMLIN

==============================================================================
*/

#ifdef HIPNOTIC

$cd hipwork/models/grem
$origin 0 0 23
$scale 2
$base base

$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6
$frame stand7 stand8 stand9 stand10 stand11 stand12
$frame stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6
$frame walk7 walk8 walk9 walk10 walk11 walk12

$frame run1 run2 run3 run4 run5 run6 run7 run8
$frame run9 run10 run11 run12 run13 run14 run15

$frame jump1 jump2 jump3 jump4 jump5 jump6 jump7
$frame jump8 jump9 jump10 jump11 jump12 jump13 jump14
$frame jump15 jump16

$frame attk1 attk2 attk3 attk4 attk5 attk6
$frame attk7 attk8 attk9 attk10 attk11

$frame maul1 maul2 maul3 maul4 maul5 maul6
$frame maul7 maul8 maul9 maul10 maul11 maul12 maul13

$frame spawn1 spawn2 spawn3 spawn4 spawn5 spawn6

$frame look1 look2 look3 look4 look5 look6 look7
$frame look8 look9 look10

$frame pain1 pain2 pain3 pain4

$frame death1 death2 death3 death4 death5 death6 death7
$frame death8 death9 death10 death11 death12

$frame flip1 flip2 flip3 flip4 flip5 flip6 flip7
$frame flip8

$frame lunge1 lunge2 lunge3 lunge4 lunge5 lunge6 lunge7
$frame lunge8 lunge9 lunge10 lunge11

$frame gfire1 gfire2 gfire3 gfire4 gfire5 gfire6

$frame glook1 glook2 glook3 glook4 glook5 glook6 glook7
$frame glook8 glook9 glook10 glook11 glook12 glook13 
$frame glook14 glook15 glook16 glook17 glook18 glook19 glook20

$frame gpain1 gpain2 gpain3

$frame grun1 grun2 grun3 grun4 grun5 grun6 grun7
$frame grun8 grun9 grun10 grun11 grun12 grun13 grun14 grun15

//============================================================================

static void () drop_da_weapon =
{
	if (self.weaponindex != WPN_NONE)
	{
		// make sure it isn't negative
		self.ammo_shells = max (0, self.ammo_shells);
		self.ammo_nails = max (0, self.ammo_nails);
		self.ammo_rockets = max (0, self.ammo_rockets);
		self.ammo_shells = max (0, self.ammo_shells);
		DropBackpack ();
		self.weaponindex = WPN_NONE;
	}

	self.customflags = not (self.customflags, CFL_STOLEWEAPON);
}

/*
============
gremlin_find_victim

find a victim to shoot at
============
*/
static entity (entity last) gremlin_find_victim =
{
	entity e, selected;
	float dist, head_dist;

	self.search_time = time + 1.0;

	// look in our immediate vicinity
	selected = world;
	dist = 1000;

	for (e = findradius (self.origin, dist); e != world; e = e.chain)
	{
		if (e == self || !(e.flags & (FL_MONSTER | FL_CLIENT)) || (e.flags & FL_NOTARGET))
			continue;
		if (!visible (e) || !alive (e))
			continue;

		head_dist = vlen (e.origin - self.origin);

		if (e == last)
			head_dist = head_dist * 2;
		else if (e.flags & FL_CLIENT)
			head_dist = head_dist / 1.5;
		else if (e.classname == self.classname)
			head_dist = head_dist * 1.5;

		if (head_dist < dist)
		{
			selected = e;
			dist = head_dist;
		}
	}

	return selected;
}

static entity () gremlin_find_corpse =
{
	entity e, selected;
	float dist, head_dist;

	selected = world;
	dist = 200 + 500 * random (); // fixed this so its never absurdly small

	for (e = findradius (self.origin, dist); e != world; e = e.chain)
	{
		if (e == self || !(e.flags & FL_MONSTER) || alive (e))
			continue;
		if (!visible (e))
			continue;
		if ((e.customflags & CFL_GORGEDUPON) || fabs (e.origin_z - self.origin_z) >= 80)
			continue;

		head_dist = vlen (e.origin - self.origin);

		if (head_dist < dist)
		{
			selected = e;
			dist = head_dist;
		}
	}

	return selected;
}

static float () gremlin_find_gorge_target =
{
	entity e;

	if (time > self.wait)
	{
		self.wait = time + 1.0;
		e = gremlin_find_corpse ();

		if (e != world)
		{
			self.oldenemy = self.enemy;
			self.enemy = e;
			self.customflags |= CFL_GORGING;
			HuntTarget ();
			self.search_time = time + 4.0;
			return TRUE;
		}
	}

	return FALSE;
}

/*
===========
gremlin_find_target

gremlin is currently not attacking anything, so try to find a target
============
*/
static float () gremlin_find_target =
{
	entity e;
	float result;

	if (self.customflags & CFL_STOLEWEAPON)
	{
		e = gremlin_find_victim (self.lastvictim);

		if (e != world)
		{
			self.lastvictim = e;
			self.enemy = e;
			FoundTarget ();
			ai_attack_finished (0);
			self.search_time = time + 2.0;
			return TRUE;
		}
	}

	if (gremlin_find_gorge_target ())
		return TRUE;

	result = FindTarget ();
	self.search_time = time + 2.0;

	return result;
}

//============================================================================

void() gremlin_stand1 = [$stand1, gremlin_stand2] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand2 = [$stand2, gremlin_stand3] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand3 = [$stand3, gremlin_stand4] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand4 = [$stand4, gremlin_stand5] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand5 = [$stand5, gremlin_stand6] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand6 = [$stand6, gremlin_stand7] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand7 = [$stand7, gremlin_stand8] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand8 = [$stand8, gremlin_stand9] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand9 = [$stand9, gremlin_stand10] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand10 = [$stand10, gremlin_stand11] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand11 = [$stand11, gremlin_stand12] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand12 = [$stand12, gremlin_stand13] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand13 = [$stand13, gremlin_stand14] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand14 = [$stand14, gremlin_stand15] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand15 = [$stand15, gremlin_stand16] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand16 = [$stand16, gremlin_stand17] {ai_stand (); self.nextthink = time + 0.2;}
void() gremlin_stand17 = [$stand17, gremlin_stand1] {ai_stand (); self.nextthink = time + 0.2;}

//============================================================================

static void (float dist) gremlin_walk =
{
	if (!ai_check_liquid()) return;

	// check for noticing a player
	if (gremlin_find_target ())
		return;

	movetogoalplus (dist);
}

void() gremlin_walk1 = [$walk1, gremlin_walk2]
{
	if (random () < 0.1)
		sound (self, CHAN_VOICE, "grem/idle.wav", 1, ATTN_IDLE);
	gremlin_walk (8);
}
void() gremlin_walk2 = [$walk2, gremlin_walk3] {gremlin_walk (8);}
void() gremlin_walk3 = [$walk3, gremlin_walk4] {gremlin_walk (8);}
void() gremlin_walk4 = [$walk4, gremlin_walk5] {gremlin_walk (8);}
void() gremlin_walk5 = [$walk5, gremlin_walk6] {gremlin_walk (8);}
void() gremlin_walk6 = [$walk6, gremlin_walk7] {gremlin_walk (8);}
void() gremlin_walk7 = [$walk7, gremlin_walk8] {gremlin_walk (8);}
void() gremlin_walk8 = [$walk8, gremlin_walk9] {gremlin_walk (8);}
void() gremlin_walk9 = [$walk9, gremlin_walk10] {gremlin_walk (8);}
void() gremlin_walk10 = [$walk10, gremlin_walk11] {gremlin_walk (8);}
void() gremlin_walk11 = [$walk11, gremlin_walk12] {gremlin_walk (8);}
void() gremlin_walk12 = [$walk12, gremlin_walk1] {gremlin_walk (8);}

//============================================================================

static float (float dist) gremlin_gorge =
{
	float r;

	traceline2 (self.origin, self.enemy.origin, self, TRACE_NOMONSTERS);

	// something blocking
	if (trace_fraction != 1.0 || !visible (self.enemy))
	{
		self.customflags = not (self.customflags, CFL_GORGING);
		return FALSE;
	}

	r = vlen (self.enemy.origin - self.origin);

	// getting close
	if (r < 130)
	{
		ai_face ();

		if (r < 45)
		{
			// start snacking
			self.th_melee ();
			self.attack_state = AS_STRAIGHT;
		}
		else if (!walkmove (self.angles_y, dist))
		{
			// can't reach
			self.customflags = not (self.customflags, CFL_GORGING);
		}

		return TRUE;
	}

	movetogoalplus (dist);

	return TRUE;
}

static float () gremlin_has_ammo =
{
	if (self.weaponindex == WPN_SUPER_SHOTGUN || self.weaponindex == WPN_SUPER_NAILGUN)
	{
		if (self.currentammo > 1)
			return TRUE;
	}
	else
	{	
		if (self.currentammo > 0)
			return TRUE;
	}
	// just drop it now
	drop_da_weapon ();
	return FALSE;
}

static void (float dist) gremlin_run =
{
	float r, done, c;
	vector d, ang, end;

	if (!ai_check_liquid ()) return;	// died in slime/lava already

	if (self.customflags & CFL_STOLEWEAPON)
		self.frame += $grun1 - $run1;

	// gorge
	if (self.customflags & CFL_GORGING)
	{
		if (gremlin_gorge (dist))
			return;
	}

	// find a new target
	if (random () > 0.97)
	{
		if (gremlin_find_target ())
			return;
	}

	if (!(self.customflags & CFL_STOLEWEAPON))
	{
		ai_run (dist);
		return;
	}

	// get away from player if we stole a weapon

	if (!alive (self.enemy) && (self.enemy.flags & FL_CLIENT))
	{
		gremlin_glook1 ();
		return;
	}

	if (!gremlin_has_ammo ())
	{
		if (self.t_length == 1)
		{
			remove (self.trigger_field);
			self.goalentity = self.enemy;
			self.t_length = 0;
		}
		return;
	}

	d = self.origin - self.enemy.origin;
	r = vlen (d);
	d /= r;

	if (self.t_length == 0)
	{
		if (r < 150)
		{
			self.trigger_field = spawn ();
			setsize (self.trigger_field,'-1 -1 -1','1 1 1');
			self.t_length = 1;
		}
	}

	if (self.t_length == 1)
	{
		if (r > 250)
		{
			remove (self.trigger_field);
			self.goalentity = self.enemy;
			self.t_length = 0;
		}
		else
		{
			if (r < 160)
			{
				ang = vectoangles (d);
				done = 0;
				c = 0;

				while (done == 0)
				{
					makevectors (ang);
					end = self.enemy.origin + v_forward * 350;
					traceline (self.enemy.origin, end, FALSE, self);

					if (trace_fraction == 1.0)
					{
						traceline (self.origin,end, FALSE, self);
						if (trace_fraction == 1.0)
							done = 1;
					}

					ang_y = anglemod (ang_y + 36);
					c = c + 1;
					if (c == 10)
					{
						done = 1;
					}
				}
				setorigin (self.trigger_field,end);
			}

			self.goalentity = self.trigger_field;
			self.ideal_yaw = vectoyaw (normalize (self.goalentity.origin - self.origin));
			ChangeYaw ();
			movetogoalplus (dist);
			self.nextthink = time + 0.1;
			return;
		}
	}

	ai_run (dist);
}

void() gremlin_run1 = [$run1, gremlin_run2]
{
	if (random () < 0.1)
		sound (self, CHAN_VOICE, "grem/idle.wav", 1, ATTN_IDLE);
	gremlin_run (0);
}
void() gremlin_run2 = [$run2, gremlin_run3] {gremlin_run (8);}
void() gremlin_run3 = [$run3, gremlin_run4] {gremlin_run (12);}
void() gremlin_run4 = [$run4, gremlin_run5] {gremlin_run (16);}
void() gremlin_run5 = [$run5, gremlin_run6] {gremlin_run (16);}
void() gremlin_run6 = [$run6, gremlin_run7] {gremlin_run (12);}
void() gremlin_run7 = [$run7, gremlin_run8] {gremlin_run (8);}
void() gremlin_run8 = [$run8, gremlin_run9] {gremlin_run (0);}
void() gremlin_run9 = [$run9, gremlin_run10] {gremlin_run (8);}
void() gremlin_run10 = [$run10, gremlin_run11] {gremlin_run (12);}
void() gremlin_run11 = [$run11, gremlin_run12] {gremlin_run (16);}
void() gremlin_run12 = [$run12, gremlin_run13] {gremlin_run (16);}
void() gremlin_run13 = [$run13, gremlin_run14] {gremlin_run (12);}
void() gremlin_run14 = [$run14, gremlin_run15] {gremlin_run (8);}
void() gremlin_run15 = [$run15, gremlin_run1] {gremlin_run (0);}

//============================================================================

static void () Gremlin_JumpTouch =
{
	// FL_ONGROUND: in contact with a horizontal surface (cos < 0.7) in any way, always set by SV_Phys after impact
	// if we're not touching anything horizontal it's not the ground so we don't care
	if (!(self.flags & FL_ONGROUND)) return;
	
	self.touch = SUB_Null;
	
	// checkbottom: false if any corners are more than a step's height above the surface beneath
	if (checkbottom (self))		// safely on ground
	{
		// we didn't even complete the leap animation, meaning we hit world right away
		if (time < self.attack_finished)
		{
			ai_attack_finished (1);	// so don't keep doing it
		}
		gremlin_jump12 ();
		return;
	}
	
	// jump randomly to not get hung up
	self.think = gremlin_jump1;
	self.nextthink = time + 0.1;
}

static void () gremlin_jump =
{
	self.touch = Gremlin_JumpTouch;
	makevectors (self.angles);
	self.velocity = v_forward * 300;
	self.velocity_z = 300;
	self.flags = not (self.flags, FL_ONGROUND);
}

void() gremlin_jump1 = [$jump1, gremlin_jump2]
{
	ai_face ();
	ai_attack_finished (0.5);
}
void() gremlin_jump2 = [$jump2, gremlin_jump3] {ai_face ();}
void() gremlin_jump3 = [$jump3, gremlin_jump4] {ai_face ();}
void() gremlin_jump4 = [$jump4, gremlin_jump5] {ai_face ();}
void() gremlin_jump5 = [$jump5, gremlin_jump6]
{
	ai_face ();
	gremlin_jump ();
}

static void () gremlin_airthink =
{
	self.think = gremlin_airthink;
	self.nextthink = time + 0.1;
	
	// if three seconds pass, assume gremlin is stuck and jump again
	if (time >= self.lifetime_finished)
	{
		if (!alive (self))
			gremlin_flip8 ();
		else
			gremlin_jump1 ();
		return;
	}
	// we aren't moving, assume leap is over so we don't get stuck with our arms up
	if (self.origin == self.oldorigin && (self.flags & FL_ONGROUND))
	{
		if (!alive (self))
			gremlin_flip8 ();
		else
			gremlin_jump12 ();
		return;
	}
	self.oldorigin = self.origin;
}

void() gremlin_jump6 = [$jump6, gremlin_jump7] {}
void() gremlin_jump7 = [$jump7, gremlin_jump8] {}
void() gremlin_jump8 = [$jump8, gremlin_jump9] {}
void() gremlin_jump9 = [$jump9, gremlin_jump10] {}
void() gremlin_jump10 = [$jump10, gremlin_jump11] {}
void() gremlin_jump11 = [$jump11, gremlin_airthink]
{
	self.oldorigin = self.origin;
	self.lifetime_finished = time + 3;
}

void() gremlin_jump12 = [$jump12, gremlin_jump13] {}
void() gremlin_jump13 = [$jump13, gremlin_jump14] {}
void() gremlin_jump14 = [$jump14, gremlin_jump15] {}
void() gremlin_jump15 = [$jump15, gremlin_jump16] {}
void() gremlin_jump16 = [$jump16, gremlin_run1] {}

//============================================================================

static float () gremlin_shoot =
{
	vector dir, ang;

	if (!gremlin_has_ammo ())
	{
		gremlin_run1 ();
		return FALSE;
	}

	self.show_hostile = time + 1; // wake monsters up

	ai_face ();

	// disasterous
	dir = normalize (self.enemy.origin - self.origin);
	ang = vectoangles (dir);
	makevectors (ang);
	dir = dir + crandom () * 0.1 * v_right + crandom () * 0.1 * v_up;
	dir = normalize (dir);
	self.v_angle = vectoangles (dir);
	self.v_angle_x = -self.v_angle_x;
	makevectors (self.v_angle);

	self.effects |= EF_MUZZLEFLASH;

	return TRUE;
}

void() gremlin_shot1 = [$gfire1, gremlin_shot2] {gremlin_shoot ();}
void() gremlin_shot2 = [$gfire2, gremlin_shot3] {}
void() gremlin_shot3 = [$gfire3, gremlin_shot4] {}
void() gremlin_shot4 = [$gfire4, gremlin_shot5] {}
void() gremlin_shot5 = [$gfire5, gremlin_shot6] {}
void() gremlin_shot6 = [$gfire6, gremlin_run1] {}

//============================================================================

void() gremlin_nail1 = [$gfire1, gremlin_nail2] {if (gremlin_shoot ()) {W_FireSpikes ();}}
void() gremlin_nail2 = [$gfire1, gremlin_nail3] {if (gremlin_shoot ()) {W_FireSpikes ();}}
void() gremlin_nail3 = [$gfire1, gremlin_nail4] {if (gremlin_shoot ()) {W_FireSpikes ();}}
void() gremlin_nail4 = [$gfire1, gremlin_nail5] {if (gremlin_shoot ()) {W_FireSpikes ();}}
void() gremlin_nail5 = [$gfire1, gremlin_nail6] {if (gremlin_shoot ()) {W_FireSpikes ();}}
void() gremlin_nail6 = [$gfire1, gremlin_nail7] {if (gremlin_shoot ()) {W_FireSpikes ();}}
void() gremlin_nail7 = [$gfire1, gremlin_run1] {}

//============================================================================

void() gremlin_laser1 = [$gfire1, gremlin_laser2] {if (gremlin_shoot ()) {W_FireLaser ();}}
void() gremlin_laser2 = [$gfire1, gremlin_laser3] {if (gremlin_shoot ()) {W_FireLaser ();}}
void() gremlin_laser3 = [$gfire1, gremlin_laser4] {if (gremlin_shoot ()) {W_FireLaser ();}}
void() gremlin_laser4 = [$gfire1, gremlin_laser5] {if (gremlin_shoot ()) {W_FireLaser ();}}
void() gremlin_laser5 = [$gfire1, gremlin_laser6] {if (gremlin_shoot ()) {W_FireLaser ();}}
void() gremlin_laser6 = [$gfire1, gremlin_laser7] {if (gremlin_shoot ()) {W_FireLaser ();}}
void() gremlin_laser7 = [$gfire1, gremlin_run1] {}

//============================================================================

void() gremlin_light1 = [$gfire1, gremlin_light2] {if (gremlin_shoot ()) {W_FireLightning ();}}
void() gremlin_light2 = [$gfire1, gremlin_light3] {if (gremlin_shoot ()) {W_FireLightning ();}}
void() gremlin_light3 = [$gfire1, gremlin_light4] {if (gremlin_shoot ()) {W_FireLightning ();}}
void() gremlin_light4 = [$gfire1, gremlin_light5] {if (gremlin_shoot ()) {W_FireLightning ();}}
void() gremlin_light5 = [$gfire1, gremlin_run1] {}

//============================================================================

void() gremlin_rocket1 = [$gfire1, gremlin_rocket2] {gremlin_shoot ();}
void() gremlin_rocket2 = [$gfire2, gremlin_rocket3] {}
void() gremlin_rocket3 = [$gfire3, gremlin_rocket4] {}
void() gremlin_rocket4 = [$gfire4, gremlin_rocket5] {}
void() gremlin_rocket5 = [$gfire5, gremlin_rocket6] {}
void() gremlin_rocket6 = [$gfire6, gremlin_run1] {}

//============================================================================

static void (float side) gremlin_melee =
{
	float	ldmg;
	vector	delta;

	ai_face ();

	delta = self.enemy.origin - self.origin;

	if (vlen (delta) > 100)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	sound (self, CHAN_WEAPON, "grem/attack.wav", 1, ATTN_NORM);
	ldmg = 10 + 5 * random ();
	T_Damage (self.enemy, self, self, ldmg, DMGTYPE_MELEE);

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward * 16, side * v_right);
}

void() gremlin_lunge1 = [$lunge1, gremlin_lunge2] {ai_face ();}
void() gremlin_lunge2 = [$lunge2, gremlin_lunge3] {ai_face ();}
void() gremlin_lunge3 = [$lunge3, gremlin_lunge4] {ai_face ();}
void() gremlin_lunge4 = [$lunge4, gremlin_lunge5] {ai_face ();}
void() gremlin_lunge5 = [$lunge5, gremlin_lunge6] {ai_face ();}
void() gremlin_lunge6 = [$lunge6, gremlin_lunge7] {ai_face ();}
void() gremlin_lunge7 = [$lunge7, gremlin_lunge8] {ai_charge (15);}
void() gremlin_lunge8 = [$lunge8, gremlin_lunge9] {ai_face (); gremlin_melee (0);}
void() gremlin_lunge9 = [$lunge9, gremlin_lunge10] {ai_face ();}
void() gremlin_lunge10 = [$lunge10, gremlin_lunge11] {ai_face ();}
void() gremlin_lunge11 = [$lunge11, gremlin_run1] {ai_face ();}

//============================================================================

void() gremlin_claw1 = [$attk1, gremlin_claw2] {ai_face ();}
void() gremlin_claw2 = [$attk2, gremlin_claw3] {ai_face ();}
void() gremlin_claw3 = [$attk3, gremlin_claw4] {ai_face ();}
void() gremlin_claw4 = [$attk4, gremlin_claw5] {ai_face ();}
void() gremlin_claw5 = [$attk5, gremlin_claw6] {ai_face ();}
void() gremlin_claw6 = [$attk6, gremlin_claw7] {ai_face (); gremlin_melee (200 * signrandom ());}
void() gremlin_claw7 = [$attk7, gremlin_claw8] {ai_charge (15);}
void() gremlin_claw8 = [$attk8, gremlin_claw9] {ai_face ();}
void() gremlin_claw9 = [$attk9, gremlin_claw10] {ai_face ();}
void() gremlin_claw10 = [$attk10, gremlin_claw11] {ai_face ();}
void() gremlin_claw11 = [$attk11, gremlin_run1] {ai_face ();}

//============================================================================

void () gremlin_throw_head =
{
	string gibname;

	if (self.classname == "monster_ogre")
		gibname = "progs/h_ogre.mdl";
	else if (self.classname == "monster_knight")
		gibname = "progs/h_knight.mdl";
	else if (self.classname == "monster_shambler")
		gibname = "progs/h_shams.mdl";
	else if (self.classname == "monster_demon1")
		gibname = "progs/h_demon.mdl";
	else if (self.classname == "monster_wizard")
		gibname = "progs/h_wizard.mdl";
	else if (self.classname == "monster_zombie")
		gibname = "progs/h_zombie.mdl";
	else if (self.classname == "monster_dog")
		gibname = "progs/h_dog.mdl";
	else if (self.classname == "monster_hell_knight")
		gibname = "progs/h_hellkn.mdl";
	else if (self.classname == "monster_enforcer")
		gibname = "progs/h_mega.mdl";
	else if (self.classname == "monster_army")
		gibname = "progs/h_guard.mdl";
	else if (self.classname == "monster_shalrath")
		gibname = "progs/h_shal.mdl";
	else if (self.classname == "monster_gremlin")
		gibname = "progs/h_grem.mdl";
	else if (self.classname == "monster_scourge")
		gibname = "progs/h_scourg.mdl";
	else if (self.classname == "monster_fish")
		gibname = "progs/gib1.mdl";
	else
		gibname = "progs/h_player.mdl";

	ThrowHead (gibname, -15);
}

static void () gremlin_split =
{
	entity grem, temp, e;
	float done, c, proceed;
	vector ang, pos;

	// fixme: add gremlin count check back

	done = FALSE;
	c = 0;
	ang = self.angles;

	while (!done)
	{
		makevectors (ang);
		pos = self.origin + 80 * v_forward;

		// make sure there aren't any monsters or players in the way
		proceed = TRUE;
		for (e = findradius (pos, 35); e != world; e = e.chain)
		{
			if (alive (e) && (e.flags & (FL_MONSTER | FL_CLIENT)))
			{
				proceed = FALSE;
				break;
			}
		}

		if (proceed)
		{
			// make sure there's room
			traceline (self.origin, pos, FALSE, self);
			if (trace_fraction == 1)
			{
				traceline (self.origin, pos - '40 40 0', FALSE, self);
				if (trace_fraction == 1)
				{
					traceline (self.origin, pos + '40 40 0', FALSE, self);
					if (trace_fraction == 1)
					{
						traceline (self.origin, pos + '0 0 64', FALSE, self);
						if (trace_fraction == 1)
						{
							traceline (self.origin, pos - '0 0 64', FALSE, self);
							if (trace_fraction != 1)
								done = TRUE;
						}
					}
				}
			}
		}

		if (!done)
		{
			ang_y = ang_y + 36;
			c = c + 1;
			if (c == 10)
			{
				return;
			}
		}
	}

	// birth a new gremlin
	grem = spawn();
	grem.origin = pos;
	grem.angles = self.angles;

	// split the health
	self.health = max (100, floor (self.health / 2) * 2);
	grem.health = self.health / 2;
	self.health = self.health / 2;

	temp = self;
	self = grem;

	// spawn the gremlin
	addmonster (1);
	monster_gremlin_spawn ();
	gremlin_spawn1 ();

	self = temp;
}

static void (float side) gorge =
{
	float ldmg;

	sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	ldmg = 7 + 5 * random ();
	self.enemy.health -= ldmg;

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward * 16, side * v_right);

	if (self.enemy.health < -200)
	{
		if (!(self.enemy.customflags & CFL_GORGEDUPON))
		{
			self.enemy.customflags |= CFL_GORGEDUPON;
			SUB_CallAsSelf (gremlin_throw_head, self.enemy);

			sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
			
			// heal
			ldmg = 150 + 100 * random ();
			T_Heal (self, ldmg, FALSE);

			// split
			gremlin_split ();
		}

		self.enemy = world;
		self.customflags = not (self.customflags, CFL_GORGING);
		gremlin_look1 ();
	}
}

void() gremlin_gorge1 = [$maul1, gremlin_gorge2] {ai_face ();}
void() gremlin_gorge2 = [$maul2, gremlin_gorge3] {ai_face ();}
void() gremlin_gorge3 = [$maul3, gremlin_gorge4] {ai_face ();}
void() gremlin_gorge4 = [$maul4, gremlin_gorge5] {ai_face ();}
void() gremlin_gorge5 = [$maul5, gremlin_gorge6] {ai_face ();}
void() gremlin_gorge6 = [$maul6, gremlin_gorge7] {ai_face (); gorge (200);}
void() gremlin_gorge7 = [$maul7, gremlin_gorge8] {ai_face ();}
void() gremlin_gorge8 = [$maul8, gremlin_gorge9] {ai_face (); gorge (-200);}
void() gremlin_gorge9 = [$maul9, gremlin_gorge10] {ai_face ();}
void() gremlin_gorge10 = [$maul10, gremlin_gorge11] {ai_face ();}
void() gremlin_gorge11 = [$maul11, gremlin_gorge12] {ai_face ();}
void() gremlin_gorge12 = [$maul12, gremlin_gorge13] {ai_face ();}
void() gremlin_gorge13 = [$maul13, gremlin_gorge1] {ai_face ();}

//============================================================================

static void () gremlin_look =
{
	// lose interest in the stolen weapon
	drop_da_weapon ();

	if (self.oldenemy != world && alive (self.oldenemy))
	{
		// look for our old enemy
		self.enemy = self.oldenemy;
		HuntTarget ();
	}
	else
	{
		// back to patrol
		if (self.goalentity)
			self.th_walk ();
		else
			self.th_stand ();
	}
}

void() gremlin_look1 = [$look1, gremlin_look2] {self.nextthink = time + 0.2;}
void() gremlin_look2 = [$look2, gremlin_look3] {self.nextthink = time + 0.2;}
void() gremlin_look3 = [$look3, gremlin_look4] {self.nextthink = time + 0.2;}
void() gremlin_look4 = [$look4, gremlin_look5] {self.nextthink = time + 0.2;}
void() gremlin_look5 = [$look5, gremlin_look6] {self.nextthink = time + 0.2;}
void() gremlin_look6 = [$look6, gremlin_look7] {self.nextthink = time + 0.2;}
void() gremlin_look7 = [$look7, gremlin_look8] {self.nextthink = time + 0.2;}
void() gremlin_look8 = [$look8, gremlin_look9] {self.nextthink = time + 0.2;}
void() gremlin_look9 = [$look9, gremlin_run1] {gremlin_look ();}

void() gremlin_glook1 = [$glook1, gremlin_glook2] {}
void() gremlin_glook2 = [$glook2, gremlin_glook3] {}
void() gremlin_glook3 = [$glook3, gremlin_glook4] {}
void() gremlin_glook4 = [$glook4, gremlin_glook5] {}
void() gremlin_glook5 = [$glook5, gremlin_glook6] {}
void() gremlin_glook6 = [$glook6, gremlin_glook7] {}
void() gremlin_glook7 = [$glook7, gremlin_glook8] {}
void() gremlin_glook8 = [$glook8, gremlin_glook9] {}
void() gremlin_glook9 = [$glook9, gremlin_glook10] {}
void() gremlin_glook10 = [$glook10, gremlin_glook11] {}
void() gremlin_glook11 = [$glook11, gremlin_glook12] {}
void() gremlin_glook12 = [$glook12, gremlin_glook13] {}
void() gremlin_glook13 = [$glook13, gremlin_glook14] {}
void() gremlin_glook14 = [$glook14, gremlin_glook15] {}
void() gremlin_glook15 = [$glook15, gremlin_glook16] {}
void() gremlin_glook16 = [$glook16, gremlin_glook17] {}
void() gremlin_glook17 = [$glook17, gremlin_glook18] {}
void() gremlin_glook18 = [$glook18, gremlin_glook19] {}
void() gremlin_glook19 = [$glook19, gremlin_glook20] {}
void() gremlin_glook20 = [$glook20, gremlin_glook20] {gremlin_look ();}

//============================================================================

void() gremlin_pain1 = [$pain1, gremlin_pain2] {ai_back (4);}
void() gremlin_pain2 = [$pain2, gremlin_pain3] {ai_back (4);}
void() gremlin_pain3 = [$pain3, gremlin_pain4] {ai_back (2);}
void() gremlin_pain4 = [$pain4, gremlin_run1] {}

void() gremlin_gunpain1 = [$gpain1, gremlin_gunpain2] {ai_back (4);}
void() gremlin_gunpain2 = [$gpain2, gremlin_gunpain3] {ai_back (2);}
void() gremlin_gunpain3 = [$gpain3, gremlin_run1] {}

static void (entity attacker, float damage) gremlin_pain =
{
	float r;

	if (self.touch == Gremlin_JumpTouch)
		return;
	if (self.pain_finished > time)
		return;
	if (random () < 0.8)
		return;

	self.pain_finished = time + 1;

	r = random ();
	if (r < 0.33)
		sound (self, CHAN_VOICE, "grem/pain1.wav", 1, ATTN_NORM);
	else if (r < 0.66)
		sound (self, CHAN_VOICE, "grem/pain2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "grem/pain3.wav", 1, ATTN_NORM);

	if (self.customflags & CFL_STOLEWEAPON)
		gremlin_gunpain1 ();
	else
		gremlin_pain1 ();
}

//============================================================================

void() gremlin_spawn1 = [$spawn1, gremlin_spawn2]
{
	self.takedamage = DAMAGE_NO;
	self.nextthink = time + 0.3;
}
void() gremlin_spawn2 = [$spawn2, gremlin_spawn3] {self.nextthink = time + 0.3;}
void() gremlin_spawn3 = [$spawn3, gremlin_spawn4] {self.nextthink = time + 0.3;}
void() gremlin_spawn4 = [$spawn4, gremlin_spawn5] {self.nextthink = time + 0.3;}
void() gremlin_spawn5 = [$spawn5, gremlin_spawn6] {self.nextthink = time + 0.3;}
void() gremlin_spawn6 = [$spawn6, gremlin_run1]
{
	self.takedamage = DAMAGE_YES;
	self.th_pain = gremlin_pain;
}

//============================================================================

void() gremlin_die1 = [$death1, gremlin_die2]
{
	sound (self, CHAN_VOICE, "grem/death.wav", 1, ATTN_NORM);
}
void() gremlin_die2 = [$death2, gremlin_die3] {ai_forward(2);}
void() gremlin_die3 = [$death3, gremlin_die4] {ai_forward(1);}
void() gremlin_die4 = [$death4, gremlin_die5] {ai_forward(2);}
void() gremlin_die5 = [$death5, gremlin_die6] {ai_forward(1);}
void() gremlin_die6 = [$death6, gremlin_die7] {self.solid = SOLID_NOT;}
void() gremlin_die7 = [$death7, gremlin_die8] {ai_forward(2);}
void() gremlin_die8 = [$death8, gremlin_die9] {ai_forward(1);}
void() gremlin_die9 = [$death9, gremlin_die10] {ai_forward(2);}
void() gremlin_die10 = [$death10, gremlin_die11] {ai_forward(1);}
void() gremlin_die11 = [$death11, gremlin_die12] {ai_forward(2);}
void() gremlin_die12 = [$death12, gremlin_die12] {}

//============================================================================

static void () Gremlin_FlipTouch =
{
	// FL_ONGROUND: in contact with a horizontal surface (cos < 0.7) in any way, always set by SV_Phys after impact
	// if we're not touching anything horizontal it's not the ground so we don't care
	if (!(self.flags & FL_ONGROUND))
	{
		gremlin_flip8 ();
		return;
	}
	
	self.touch = SUB_Null;
	
	// checkbottom: false if any corners are more than a step's height above the surface beneath
	if (checkbottom (self))		// safely on ground
	{
		// we didn't even complete the leap animation, meaning we hit world right away
		gremlin_flip8 ();
		return;
	}
	
	// just freaking explode
	Gib ("progs/h_grem.mdl", -35);
}

static void () gremlin_flip =
{
	self.touch = Gremlin_FlipTouch;
	makevectors (self.angles);
	self.velocity = v_forward * -200;
	self.velocity_z = 350;
	self.flags = not (self.flags, FL_ONGROUND);
}

void() gremlin_flip1 = [$flip1, gremlin_flip2]
{
	ai_face ();
	gremlin_flip ();
}
void() gremlin_flip2 = [$flip2, gremlin_flip3] {ai_face ();}
void() gremlin_flip3 = [$flip3, gremlin_flip4] {}
void() gremlin_flip4 = [$flip4, gremlin_flip5] {}
void() gremlin_flip5 = [$flip5, gremlin_flip6] {}
void() gremlin_flip6 = [$flip6, gremlin_flip7] {}
void() gremlin_flip7 = [$flip7, gremlin_airthink]
{
	self.oldorigin = self.origin;
	self.lifetime_finished = time + 3;
}

void() gremlin_flip8 = [$flip8, gremlin_flip8] {self.solid = SOLID_NOT;}

//============================================================================

void() gremlin_die =
{
	float dot;

	drop_da_weapon ();

	// check for gib
	if (self.health < -35)
	{
		Gib ("progs/h_grem.mdl", self.health);
		return;
	}

	self.customflags = not (self.customflags, CFL_GORGING);

	if ((self.flags & FL_ONGROUND) && random () < 0.5)
	{
		makevectors (self.angles);
		dot = normalize (damage_attacker.origin - self.origin) * v_forward;

		if (dot > 0.7)
		{
			// cartwheel backwards
			gremlin_flip1 ();
			return;
		}
	}

	// regular death
	gremlin_die1 ();
}

/*
===========
steal_weapon

see if we can steal enemy's weapon
============
*/
static float (entity victim) steal_weapon =
{
	vector delta, fl;
	float weap, a;

	if (!alive (victim) || !(victim.flags & FL_CLIENT))
		return FALSE;

	if (random () >= 0.2)
		return FALSE;

	delta = victim.origin - self.origin;

	if (vlen (delta) > 100)
		return FALSE;

	// we are within range so lets go for it

	// ...maybe not
	if (victim.weaponindex < WPN_SUPER_SHOTGUN
	 || victim.weaponindex == WPN_MJOLNIR
	 || victim.weaponindex > WPN_LASER_CANNON)
		return FALSE;
	
	// take that weapon from the entity
	weap = victim.weaponindex;
	W_SetHasWeapon (victim, weap, FALSE);

	// give it to our gremlin
	W_SetHasWeapon (self, weap, TRUE);
	self.weaponindex = weap;
	fl = W_ItemForWeapon (self.weaponindex);
	self.weapon = fl_x + fl_y * IT2_SHIFT;

	// take some ammo while we are at it
	a = 2;
	self.items = not (self.items, IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);

	switch (self.weaponindex)
	{
		case WPN_SHOTGUN:
		case WPN_SUPER_SHOTGUN:
			a = min (victim.ammo_shells, 20);
			victim.ammo_shells -= a;
			self.ammo_shells += a;
			self.items |= IT_SHELLS;
			break;
		case WPN_NAILGUN:
		case WPN_SUPER_NAILGUN:
			a = min (victim.ammo_nails, 40);
			victim.ammo_nails -= a;
			self.ammo_nails += a;
			self.items |= IT_NAILS;
			break;
		case WPN_GRENADE_LAUNCHER:
		case WPN_PROXIMITY_GUN:
		case WPN_ROCKET_LAUNCHER:
			a = min (victim.ammo_rockets, 5);
			victim.ammo_rockets -= a;
			self.ammo_rockets += a;
			self.items |= IT_ROCKETS;
			break;
		case WPN_LIGHTNING:
		case WPN_LASER_CANNON:
			a = min (victim.ammo_cells, 40);
			victim.ammo_cells -= a;
			self.ammo_cells += a;
			self.items |= IT_CELLS;
			break;
	}

	self.currentammo = a;

	sprint (victim, "Gremlin stole your ");
	sprint (victim, weapon_strings[self.weaponindex]);
	sprint (victim, "\n");

	// force the victim to switch weapons
	SUB_CallAsSelf (W_SelectBestWeapon, victim);

	// tag the gremlin as having stolen a weapon
	self.customflags |= CFL_STOLEWEAPON;
	ai_attack_finished (0);

	// don't fire the first shot at the person we stole the weapon from all the time
	if (random () > 0.65)
		self.lastvictim = victim;
	else
		self.lastvictim = self;

	if (gremlin_find_target ())
		self.search_time = time + 1.0;

	return TRUE;
}

static void () Gremlin_MeleeAttack =
{
	float num;

	if (self.customflags & CFL_GORGING)
	{
		gremlin_gorge1 ();
		return;
	}

	if (steal_weapon (self.enemy))
		return;

	num = random ();
	if (num < 0.3)
	{
		gremlin_claw1 ();
	}
	else if (num < 0.6)
	{
		gremlin_lunge1 ();
	}
	else
	{
		gremlin_claw1 ();
	}
}

/*
============
gremlin_weapon_attack

attack with a weapon
============
*/
static float() gremlin_weapon_attack =
{
	if (!gremlin_has_ammo ())
		return FALSE;

	if (self.weaponindex == WPN_SHOTGUN)
	{
		gremlin_shot1 ();
		W_FireShotgun ();
	}
	else if (self.weaponindex == WPN_SUPER_SHOTGUN)
	{
		gremlin_shot1 ();
		W_FireSuperShotgun ();
	}
	else if (self.weaponindex == WPN_NAILGUN || self.weaponindex == WPN_SUPER_NAILGUN)
	{
		gremlin_nail1 ();
	}
	else if (self.weaponindex == WPN_GRENADE_LAUNCHER)
	{
		gremlin_rocket1 ();
		W_FireGrenade ();
	}
	else if (self.weaponindex == WPN_ROCKET_LAUNCHER)
	{
		gremlin_rocket1 ();
		W_FireRocket ();
	}
	else if (self.weaponindex == WPN_LIGHTNING)
	{
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		gremlin_light1 ();
	}
	else if (self.weaponindex == WPN_LASER_CANNON)
	{
		gremlin_laser1 ();
	}
	else if (self.weaponindex == WPN_PROXIMITY_GUN)
	{
		gremlin_rocket1 ();
		W_FireProximityGrenade ();
	}

	ai_attack_finished (1);
	return TRUE;
}

static void () Gremlin_MissileAttack =
{
	if (self.customflags & CFL_STOLEWEAPON)
	{
		if (gremlin_weapon_attack ())
			return;

		if (random () >= 0.1)
			return;
	}

	if (self.flags & FL_ONGROUND)
		gremlin_jump1 ();
}

static float () GremlinCheckAttack =
{
	vector delta;

	if (time < self.attack_finished)
		return FALSE;

	if (self.customflags & CFL_STOLEWEAPON)
	{
		// missile attack
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
	else
	{
		if (enemy_range == RANGE_MELEE && z_overlap (self.enemy))
		{
			delta = self.enemy.origin - self.origin;

			if (vlen (delta) <= 100)
			{
				self.attack_state = AS_MELEE;
				return TRUE;
			}
		}

		// missile attack
		if (random () < 0.03)
		{
			self.attack_state = AS_MISSILE;
			return TRUE;
		}
	}

	return FALSE;
}

//============================================================================

static void () monster_gremlin_spawn =
{
	self.classname = "monster_gremlin";

	self.solid = SOLID_SLIDEBOX;

	setmodel (self, "progs/grem.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 100;
	self.yaw_speed = 40;

	self.th_stand = gremlin_stand1;
	self.th_walk = gremlin_walk1;
	self.th_run = gremlin_run1;
	self.th_die = gremlin_die;
	self.th_melee = Gremlin_MeleeAttack; // one of two attacks
	self.th_missile = Gremlin_MissileAttack; // check for random jump or firing of weapon
	self.th_pain = gremlin_pain;
	self.th_checkattack = GremlinCheckAttack;

	if (self.deathtype == string_null)
		self.deathtype = "was outsmarted by a Gremlin";

	walkmonster_start ();
}

void () monster_gremlin_spawner = {mon_spawner_use (monster_gremlin_spawn);}

/*QUAKED monster_gremlin (1 0 0) (-32 -32 -24) (32 32 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Gremlin, 100 health points.

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
@PointClass base(Monster) size(-32 -32 -24, 32 32 64) model({ "path": ":progs/grem.mdl" }) = monster_gremlin : "Gremlin" []
*/
void () monster_gremlin =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/grem.mdl");
	precache_model ("progs/h_grem.mdl");

	precache_sound ("grem/death.wav");
	precache_sound ("grem/attack.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("grem/pain1.wav");
	precache_sound ("grem/pain2.wav");
	precache_sound ("grem/pain3.wav");
	precache_sound ("grem/idle.wav");
	precache_sound ("grem/sight1.wav");

	self.health = 100;

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	if ( monster_spawnsetup( monster_gremlin_spawner ) ) return;

	addmonster (1);
	monster_gremlin_spawn ();
}

#endif /* HIPNOTIC */
