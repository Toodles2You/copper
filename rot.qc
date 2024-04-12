/*
==============================================================================

ROTATING OBJECTS

==============================================================================
*/

static void () LinkRotateTargets =
{
	entity ent;
	vector tempvec;

	self.oldorigin = self.origin;

	ent = find (world, targetname, self.target);
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

static void () RotateTargetsFinal =
{
	entity ent;

	ent = find (world, targetname, self.target);
	while (ent)
	{
		ent.velocity = VEC_ORIGIN;

		if (ent.rotate_type == OBJECT_ROTATE)
			ent.angles = self.angles;

	   	ent = find (ent, targetname, self.target);
   }
}

//============================================================================

/*QUAKED info_rotate (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as the point of rotation for rotatable objects.
*/
void () info_rotate =
{
	// remove self after a little while, to make sure that entities that
	// have targeted it have had a chance to spawn
	self.nextthink = time + 2;
	self.think = SUB_Remove;
}

//============================================================================

static void () rotate_entity_think =
{
	float t;

	t = time - self.ltime;
	self.ltime = time;

	if (self.state == STATE_SPEEDINGUP)
	{
		self.count = min (self.count + self.cnt * t, 1);
	}
	else if (self.state == STATE_SLOWINGDOWN)
	{
		self.count -= self.cnt * t;
		if (self.count < 0)
		{
			RotateTargetsFinal ();
			self.state = STATE_INACTIVE;
			self.think = SUB_Null;
			return;
		}
	}

	// get rate of rotation
	t *= self.count;

	self.angles += self.rotate * t;
	self.angles = anormalize (self.angles);
	RotateTargets ();
	self.nextthink = time + 0.02;
}

static void () rotate_entity_use =
{
	// change to alternate textures
	self.frame = 1 - self.frame;

	if (self.state == STATE_ACTIVE)
	{
		if (self.spawnflags & 1)
		{
			if (self.speed)
			{
				self.count = 1;
				self.state = STATE_SLOWINGDOWN;
			}
			else
			{
				self.state = STATE_INACTIVE;
				self.think = SUB_Null;
			}
		}
	}
	else if (self.state == STATE_INACTIVE)
	{
		self.think = rotate_entity_think;
		self.nextthink = time + 0.02;
		self.ltime = time;
		if (self.speed)
		{
			self.count = 0;
			self.state = STATE_SPEEDINGUP;
		}
		else
		{
			self.state = STATE_ACTIVE;
		}
	}
	else if (self.state == STATE_SPEEDINGUP)
	{
		if (self.spawnflags & 1)
			self.state = STATE_SLOWINGDOWN;
	}
	else
	{
		self.state = STATE_SPEEDINGUP;
	}
}

static void () rotate_entity_firstthink =
{
	LinkRotateTargets ();

	if (self.spawnflags & 2)
	{
		self.state = STATE_ACTIVE;
		self.think = rotate_entity_think;
		self.nextthink = time + 0.02;
		self.ltime = time;
	}
	else
	{
		self.state = STATE_INACTIVE;
		self.think = SUB_Null;
	}

	self.use = rotate_entity_use;
}

/*QUAKED func_rotate_entity (0 .5 .8) (-8 -8 -8) (8 8 8) TOGGLE START_ON
Creates an entity that continually rotates.  Can be toggled on and
off if targeted.

TOGGLE = allows the rotation to be toggled on/off

START_ON = wether the entity is spinning when spawned.  If TOGGLE is 0, entity can be turned on, but not off.

If "deathtype" is set with a string, this is the message that will appear when a player is killed by the train.

"rotate" is the rate to rotate.
"target" is the center of rotation.
"speed"  is how long the entity takes to go from standing still to full speed and vice-versa.
*/
void () func_rotate_entity =
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;

	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);

	if (self.speed != 0)
		self.cnt = 1 / self.speed;

	self.think = rotate_entity_firstthink;
	self.nextthink = time + 0.1;
	self.ltime = time;
}

//============================================================================

const float	SF_ROTATION		= 1;
const float	SF_ANGLES		= 2;
const float	SF_STOP			= 4;
const float	SF_NO_ROTATE	= 8;
const float	SF_DAMAGE		= 16;
const float	SF_MOVETIME		= 32;
const float	SF_SET_DAMAGE	= 64;

/*QUAKED path_rotate (0.5 0.3 0) (-8 -8 -8) (8 8 8) SF_ROTATION SF_ANGLES SF_STOP SF_NO_ROTATE SF_DAMAGE SF_MOVETIME SF_SET_DAMAGE
 Path for rotate_train.

 SF_ROTATION tells train to rotate at rate specified by "rotate".  Use VEC_ORIGIN to stop rotation.

 SF_ANGLES tells train to rotate to the angles specified by "angles" while traveling to this path_rotate.  Use values < 0 or > 360 to guarantee that it turns in a certain direction.  Having this flag set automatically clears any rotation.

 SF_STOP tells the train to stop and wait to be retriggered.

 SF_NO_ROTATE tells the train to stop rotating when waiting to be triggered.

 SF_DAMAGE tells the train to cause damage based on "dmg".

 SF_MOVETIME tells the train to interpret "speed" as the length of time to take moving from one corner to another.

 SF_SET_DAMAGE tells the train to set all targets damage to "dmg"

 "noise" contains the name of the sound to play when train stops.
 "noise1" contains the name of the sound to play when train moves.
 "event" is a target to trigger when train arrives at path_rotate.
*/
void () path_rotate =
{
	if (self.noise)
		precache_sound_safe (self.noise);
	if (self.noise1)
		precache_sound_safe (self.noise1);
}

//============================================================================

static void () rotate_train_think =
{
	float t, timeelapsed;

	t = time - self.ltime;
	self.ltime = time;

	if (self.endtime && time >= self.endtime)
	{
		self.endtime = 0;
		if (self.state == STATE_MOVE)
		{
			setorigin (self, self.finaldest);
			self.velocity = VEC_ORIGIN;
		}

		if (self.think1)
			self.think1 ();
	}
	else
	{
		timeelapsed = min ((time - self.cnt) * self.duration, 1);
		setorigin (self, self.dest1 + (self.dest2 * timeelapsed));
	}

	self.angles += self.rotate * t;
	self.angles = anormalize (self.angles);
	RotateTargets ();

	self.nextthink = time + 0.02;
}

static void () SetTargetOrigin =
{
	entity ent;

	ent = find (world, targetname, self.target);
	while (ent)
	{
		if (ent.rotate_type == OBJECT_MOVEWALL)
			setorigin (ent, self.origin - self.oldorigin + (ent.neworigin - ent.oldorigin));
		else
			setorigin (ent, ent.neworigin + self.origin);

		ent = find (ent, targetname, self.target);
	}
}

static void (entity ent, float amount) hurt_setdamage =
{
	ent.dmg = amount;

	if (amount <= 0)
		ent.solid = SOLID_NOT;
	else
		ent.solid = SOLID_TRIGGER;

	ent.nextthink = -1;
}

static void (float amount) SetDamageOnTargets =
{
	entity ent;

	ent = find (world, targetname, self.target);
	while (ent)
	{
		if (ent.classname == "trigger_hurt")
			hurt_setdamage (ent, amount);
		else if (ent.classname == "func_movewall")
			ent.dmg = amount;

		ent = find (ent, targetname, self.target);
	}
}

static void () rotate_train_next =
{
	entity targ, current;
	vector vdestdelta;
	float len, traveltime, div;
	string temp;

	self.state = STATE_NEXT;

	current = self.goalentity;
	targ = find (world, targetname, self.path);
	if (targ.classname != "path_rotate")
		objerror ("Next target is not path_rotate");

	if (self.goalentity.noise1)
		self.noise1 = self.goalentity.noise1;

	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);

	self.goalentity = targ;
	self.path = targ.target;

	if (!self.path)
		objerror ("rotate_train_next: no next target");

	if (targ.spawnflags & SF_STOP)
		self.think1 = rotate_train_stop;
	else if (targ.wait)
		self.think1 = rotate_train_wait;
	else
		self.think1 = rotate_train_next;

	if (current.event)
	{
		// Trigger any events that should happen at the corner.
		temp = self.target;
		self.target = current.event;
		self.message = current.message;
		SUB_UseTargets ();
		self.target = temp;
		self.message = string_null;
	}

	if (current.spawnflags & SF_ANGLES)
	{
		self.rotate = VEC_ORIGIN;
		self.angles = self.finalangle;
	}

	if (current.spawnflags & SF_ROTATION)
		self.rotate = current.rotate;

	if (current.spawnflags & SF_DAMAGE)
		self.dmg = current.dmg;

	if (current.spawnflags & SF_SET_DAMAGE)
		SetDamageOnTargets (current.dmg);

	if (current.speed == -1)
	{
		// Warp to the next path_corner
		setorigin (self, targ.origin);
		self.endtime = self.ltime + 0.01;
		SetTargetOrigin ();

		if (targ.spawnflags & SF_ANGLES)
			self.angles = targ.angles;

		self.duration = 1; // 1 / duration
		self.cnt = time; // start time
		self.dest2 = VEC_ORIGIN; // delta
		self.dest1 = self.origin; // original position
		self.finaldest = self.origin;
	}
	else
	{
		self.state = STATE_MOVE;

		self.finaldest = targ.origin;
		if (self.finaldest == self.origin)
		{
			self.velocity = VEC_ORIGIN;
			self.endtime = self.ltime + 0.1;

			self.duration = 1; // 1 / duration
			self.cnt = time; // start time
			self.dest2 = VEC_ORIGIN; // delta
			self.dest1 = self.origin; // original position
			self.finaldest = self.origin;
			return;
		}
		// set destdelta to the vector needed to move
		vdestdelta = self.finaldest - self.origin;

		// calculate length of vector
		len = vlen (vdestdelta);

		if (current.spawnflags & SF_MOVETIME)
		{
			traveltime = current.speed;
		}
		else
		{
			// check if there's a speed change
			if (current.speed > 0)
				self.speed = current.speed;

			if (!self.speed)
				objerror ("No speed is defined!");

			// divide by speed to get time to reach dest
			traveltime = len / self.speed;
		}

		if (traveltime < 0.1)
		{
			self.velocity = VEC_ORIGIN;
			self.endtime = self.ltime + 0.1;

			if (targ.spawnflags & SF_ANGLES)
				self.angles = targ.angles;

			return;
		}

		div = 1 / traveltime;

		if (targ.spawnflags & SF_ANGLES)
		{
			self.finalangle = anormalize (targ.angles);
			self.rotate = (targ.angles - self.angles) * div;
		}

		// set endtime to trigger a think when dest is reached
		self.endtime = self.ltime + traveltime;

		// scale the destdelta vector by the time spent traveling to get velocity
		self.velocity = vdestdelta * div;

		self.duration = div; // 1 / duration
		self.cnt = time; // start time
		self.dest2 = vdestdelta; // delta
		self.dest1 = self.origin; // original position
	}
}

static void () rotate_train_find =
{
	entity targ;

	self.state = STATE_FIND;

	LinkRotateTargets ();

	// the first target is the point of rotation.
	// the second target is the path.
	targ = find (world, targetname, self.path);
	if (targ.classname != "path_rotate")
		objerror ("Next target is not path_rotate");

	// Save the current entity
	self.goalentity = targ;

	if (targ.spawnflags & SF_ANGLES)
	{
		self.angles = targ.angles;
		self.finalangle = anormalize (targ.angles);
	}

	self.path = targ.target;
	setorigin (self, targ.origin);
	SetTargetOrigin ();
	RotateTargetsFinal ();
	self.think1 = rotate_train_next;

	if (!self.targetname)
		// not triggered, so start immediately
		self.endtime = self.ltime + 0.1;
	else
		self.endtime = 0;

	self.duration = 1; // 1 / duration
	self.cnt = time; // start time
	self.dest2 = VEC_ORIGIN; // delta
	self.dest1 = self.origin; // original position
}

static void () rotate_train_use =
{
	if (self.think1 != rotate_train_find)
	{
		if (self.velocity != VEC_ORIGIN)
			return;		// already activated

		if (self.think1)
			self.think1 ();
	}
}

static void () rotate_train_arrive =
{
	if (self.goalentity.noise)
		sound (self, CHAN_VOICE, self.goalentity.noise, 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	if (self.goalentity.spawnflags & SF_ANGLES)
	{
		self.rotate = VEC_ORIGIN;
		self.angles = self.finalangle;
	}
	if (self.goalentity.spawnflags & SF_NO_ROTATE)
	{
		self.rotate = VEC_ORIGIN;
	}

	self.think1 = rotate_train_next;
}

static void () rotate_train_wait =
{
	self.state = STATE_WAIT;
	rotate_train_arrive ();
	self.endtime = self.ltime + self.goalentity.wait;
}

static void () rotate_train_stop =
{
	self.state = STATE_STOP;
	rotate_train_arrive ();
	self.dmg = 0;
}

/*QUAKED func_rotate_train (0 .5 .8) (-8 -8 -8) (8 8 8)
In path_rotate, set speed to be the new speed of the train after it reaches
the path change.  If speed is -1, the train will warp directly to the next
path change after the specified wait time.  If SF_MOVETIME is set on the
path_rotate, the train to interprets "speed" as the length of time to
take moving from one corner to another.

"noise" contains the name of the sound to play when train stops.
"noise1" contains the name of the sound to play when train moves.
Both "noise" and "noise1" defaults depend upon "sounds" variable and
can be overridden by the "noise" and "noise1" variable in path_rotate.

Also in path_rotate, if SF_STOP is set, the train will wait until it is
retriggered before moving on to the next goal.

Trains are moving platforms that players can ride.
"path" specifies the first path_rotate and is the starting position.
If the train is the target of a button or trigger, it will not begin moving until activated.
The func_rotate_train entity is the center of rotation of all objects targeted by it.

If "deathtype" is set with a string, this is the message that will appear when a player is killed by the train.

speed	default 100
dmg      default  0
sounds
1) ratchet metal
*/
void () func_rotate_train =
{
	if (!self.target)
		objerror ("func_rotate_train without target");

	self.speed = zeroconvertdefault (self.speed, 100);

	if (!self.noise)
	{
		if (self.sounds == 0)
			self.noise = "misc/null.wav";
		else if (self.sounds == 1)
			self.noise = "plats/train2.wav";
	}

	if (!self.noise1)
	{
		if (self.sounds == 0)
			self.noise1 = "misc/null.wav";
		else if (self.sounds == 1)
			self.noise1 = "plats/train1.wav";
	}

	precache_sound_safe (self.noise);
	precache_sound_safe (self.noise1);

	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_STEP;
	self.use = rotate_train_use;

	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);
	setorigin (self, self.origin);

	// start trains on the second frame, to make sure their targets have had
	// a chance to spawn
	self.ltime = time;
	self.nextthink = self.ltime + 0.1;
	self.endtime = self.ltime + 0.1;
	self.think = rotate_train_think;
	self.think1 = rotate_train_find;
	self.state = STATE_FIND;

	self.duration = 1; // 1 / duration
	self.cnt = 0.1; // start time
	self.dest2 = VEC_ORIGIN; // delta
	self.dest1 = self.origin; // original position

	self.flags |= FL_ONGROUND;
}

//============================================================================

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
