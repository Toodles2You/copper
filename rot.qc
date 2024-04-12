/*
==============================================================================

ROTATING OBJECTS

==============================================================================
*/

static void () rotate_door_reversedirection =
{
	vector start;

	// change to alternate textures
	self.frame = 1 - self.frame;

	if (self.state == STATE_CLOSING)
	{
		start = self.dest1;
		self.dest = self.dest2;
		self.state = STATE_OPENING;
	}
	else
	{
		start = self.dest2;
		self.dest = self.dest1;
		self.state = STATE_CLOSING;
	}

	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);

	self.rotate = (self.dest - start) * (1 / self.speed);
	self.think = rotate_door_think;
	self.nextthink = time + 0.02;
	self.endtime = time + self.speed - (self.endtime - time);
	self.ltime = time;
}

static void () rotate_door_group_reversedirection =
{
	string name;

	// tell all associated rotaters to reverse direction
	if (self.group)
	{
		name = self.group;
		self = find (world, group, name);
		while (self != world)
		{
			rotate_door_reversedirection ();
			self = find (self, group, name);
		}
	}
	else
	{
		rotate_door_reversedirection ();
	}
}

//============================================================================

static void () movewall_touch =
{
	if (time < self.owner.attack_finished)
		return;

	if (self.dmg != 0)
		T_Damage (other, self, self.owner, self.dmg, DMGTYPE_CRUSH);
	else if (self.owner.dmg != 0)
		T_Damage (other, self, self.owner, self.owner.dmg, DMGTYPE_CRUSH);

	self.owner.attack_finished = time + 0.5;
}

static void () movewall_blocked =
{
	if (time < self.owner.attack_finished)
		return;

	if (self.owner.classname == "func_rotate_door")
		SUB_CallAsSelf (rotate_door_group_reversedirection, self.owner);

	movewall_touch ();
}

static void () movewall_think =
{
	self.ltime = time;
	self.nextthink = time + 0.02;
}

/*QUAKED func_movewall (0 .5 .8) ? VISIBLE TOUCH NONBLOCKING
Used to emulate collision on rotating objects.

VISIBLE causes brush to be displayed.

TOUCH specifies whether to cause damage when touched by player.

NONBLOCKING makes the brush non-solid.  This is useless if VISIBLE is set.

"dmg" specifies the damage to cause when touched or blocked.
*/
void () func_movewall =
{
	self.angles = VEC_ORIGIN;
	self.movetype = MOVETYPE_PUSH;

	if (self.spawnflags & 4)
	{
		self.solid = SOLID_NOT;
	}
	else
	{
		self.solid = SOLID_BSP;
		self.blocked = movewall_blocked;
	}
	
	if (self.spawnflags & 2)
		self.touch = movewall_touch;

	setmodel (self, self.model);

	if (!(self.spawnflags & 1))
		self.model = string_null;

	self.think = movewall_think;
	self.nextthink = time + 0.02;
	self.ltime = time;
}

//============================================================================

/*QUAKED rotate_object (0 .5 .8) ?
This defines an object to be rotated.  Used as the target of func_rotate_door.
*/
void () rotate_object =
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;

	setmodel (self,self.model);
	setsize (self, self.mins, self.maxs);
}

//============================================================================

static void () RotateTargetsFinal =
{
	entity ent;

	ent = find (world, targetname, self.target);
	while (ent)
	{
		ent.velocity = VEC_ORIGIN;

		if (ent.rotate_type == OBJECT_ROTATE)
			ent.angles = self.angles;

	   	ent = find( ent, targetname, self.target);
   }
}

static void () rotate_door_think2 =
{
	float t;

	t = time - self.ltime;
	self.ltime = time;

	// change to alternate textures
	self.frame = 1 - self.frame;

	self.angles = self.dest;

	if (self.state == STATE_OPENING)
	{
		self.state = STATE_OPEN;
	}
	else
	{
		if (self.spawnflags & 1)
		{
			rotate_door_group_reversedirection ();
			return;
		}
		self.state = STATE_CLOSED;
	}

	sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	self.think = SUB_Null;

	RotateTargetsFinal ();
}

//============================================================================

static void () RotateTargets =
{
	entity ent;
	vector vx, vy, vz, org;

	makevectors (self.angles);

	ent = find (world, targetname, self.target);
	while (ent)
	{
		if (ent.rotate_type == OBJECT_SETORIGIN)
		{
			org = ent.oldorigin;
			vx = v_forward * org_x;
			vy = v_right * org_y;
			vy = vy * -1;
			vz = v_up * org_z;
			ent.neworigin = vx + vy + vz;
			setorigin (ent, ent.neworigin + self.origin);
		}
		else if (ent.rotate_type == OBJECT_ROTATE)
		{
			ent.angles = self.angles;
			org = ent.oldorigin;
			vx = v_forward * org_x;
			vy = v_right * org_y;
			vy = vy * -1;
			vz = v_up * org_z;
			ent.neworigin = vx + vy + vz;
			setorigin (ent, ent.neworigin + self.origin);
		}
		else
		{
			org = ent.oldorigin;
			vx = v_forward * org_x;
			vy = v_right * org_y;
			vy = vy * -1;
			vz = v_up * org_z;
			ent.neworigin = vx + vy + vz;
			ent.neworigin = self.origin - self.oldorigin + (ent.neworigin - ent.oldorigin);
			ent.velocity = (ent.neworigin - ent.origin) * 25;
		}
		ent = find (ent, targetname, self.target);
	}
}

static void () rotate_door_think =
{
	float t;

	t = time - self.ltime;
	self.ltime = time;

	if (time < self.endtime)
	{
		self.angles += self.rotate * t;
		RotateTargets ();
	}
	else
	{
		self.angles = self.dest;
		RotateTargets ();
		self.think = rotate_door_think2;
	}

	self.nextthink = time + 0.01;
}

//============================================================================

static void () LinkRotateTargets =
{
	entity ent;
	vector tempvec;

	self.oldorigin = self.origin;

	ent = find( world, targetname, self.target);
	while (ent)
	{
		if (ent.classname == "rotate_object")
		{
			ent.rotate_type = OBJECT_ROTATE;
			ent.oldorigin = ent.origin - self.oldorigin;
			ent.neworigin = ent.origin - self.oldorigin;
			ent.owner = self;
		}
		else if (ent.classname == "func_movewall")
		{
			ent.rotate_type = OBJECT_MOVEWALL;
			tempvec = (ent.absmin + ent.absmax) * 0.5;
			ent.oldorigin = tempvec - self.oldorigin;
			ent.neworigin = ent.oldorigin;
			ent.owner = self;
		}
		else
		{
			ent.rotate_type = OBJECT_SETORIGIN;
			ent.oldorigin = ent.origin - self.oldorigin;
			ent.neworigin = ent.origin - self.oldorigin;
		}
		ent = find (ent, targetname, self.target);
	}
}

static void () rotate_door_use =
{
	vector start;

	if (self.state != STATE_OPEN && self.state != STATE_CLOSED)
		return;

	if (self.cnt == 0)
	{
		self.cnt = 1;
		LinkRotateTargets ();
	}

	// change to alternate textures
	self.frame = 1 - self.frame;

	if (self.state == STATE_CLOSED)
	{
		start = self.dest1;
		self.dest = self.dest2;
		self.state = STATE_OPENING;
	}
	else
	{
		start = self.dest2;
		self.dest = self.dest1;
		self.state = STATE_CLOSING;
	}

	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);

	self.rotate = (self.dest - start) * (1 / self.speed);
	self.think = rotate_door_think;
	self.nextthink = time + 0.01;
	self.endtime = time + self.speed;
	self.ltime = time;
}

//============================================================================

/*QUAKED func_rotate_door (0 .5 .8) (-8 -8 -8) (8 8 8) STAYOPEN
Creates a door that rotates between two positions around a point of
rotation each time it's triggered.

STAYOPEN tells the door to reopen after closing.  This prevents a trigger-
once door from closing again when it's blocked.

"dmg" specifies the damage to cause when blocked.  Defaults to 2.  Negative numbers indicate no damage.
"speed" specifies how the time it takes to rotate

"sounds"
1) medieval (default)
2) metal
3) base
*/
void () func_rotate_door =
{
	if (!self.target)
		objerror ("rotate_door without target.");

	self.dest1 = VEC_ORIGIN;
	self.dest2 = self.angles;
	self.angles = self.dest1;

	// default to 2 seconds
	self.speed = zeroconvertdefault (self.speed, 2);

	if (self.dmg < 0)
		self.dmg = 0;
	self.dmg = zeroconvertdefault (self.dmg, 2);

	self.sounds = zeroconvertdefault (self.sounds, 1);

	if (self.sounds == 1)
	{
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	else if (self.sounds == 2)
	{
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	else if (self.sounds == 3)
	{
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}

	if (self.noise1 != string_null)
	{
		precache_sound_safe (self.noise1);
		precache_sound_safe (self.noise2);
		precache_sound_safe (self.noise3);
	}

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	setmodel (self, self.model);
	setorigin (self, self.origin);
	setsize (self, self.mins, self.maxs);
	self.state = STATE_CLOSED;
	self.use = rotate_door_use;
}
