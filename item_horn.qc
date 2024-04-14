/*
===============================================================================

HORN OF CONJURING

===============================================================================
*/

#ifdef HIPNOTIC

entity horn_charmer;

float (entity e) is_charmed =
{
    return e.charmer != world;
}

float (entity e) ai_check_charmed =
{
	// Not charmed!
	if (!is_charmed (self))
		return TRUE;
	
	if (e.flags & FL_CLIENT)
	{
		// Not our charmer.
		if (e != self.charmer)
			return TRUE;
	}
	else
	{
		// Not another guy charmed by our charmer.
		if (e.charmer != self.charmer)
			return TRUE;
	}

	return FALSE;
}

static void () UpdateCharmerGoal =
{
	local entity targ;
	local vector d;

	d = normalize (self.origin - self.charmer.origin);

	if (self.huntingcharmer == 1)
	{
		targ = spawn();
		self.trigger_field = targ;
		setorigin (targ, self.charmer.origin);
		self.huntingcharmer = 2;
		self.goalentity = targ;
	}
	if (self.huntingcharmer == 2)
	{
		targ = self.trigger_field;
		traceline2 (self.origin, self.charmer.origin, self, TRACE_NOMONSTERS);
		if (trace_fraction == 1.0)
		{
			setorigin (targ, self.charmer.origin);
		}
	}
	else
	{
		targ = self.trigger_field;
		setorigin (targ, self.charmer.origin + (d * 300));
	}
}

void () HuntCharmer =
{
   self.huntingcharmer = 1;
   UpdateCharmerGoal ();
   self.think = self.th_walk;
   self.ideal_yaw = vectoyaw (self.goalentity.origin - self.origin);
   self.nextthink = time + 0.1;
}

static void () FleeCharmer =
{
   self.huntingcharmer = 1;
   UpdateCharmerGoal ();
   self.huntingcharmer = 3;
   self.think = self.th_walk;
   self.nextthink = time + 0.1;
}

static void () StopHuntingCharmer =
{
	self.goalentity = world;
	if (self.huntingcharmer > 1)
		remove (self.trigger_field);
	self.huntingcharmer = 0;
	self.think = self.th_stand;
	self.nextthink = time + 0.1;
}

const float	CHARMED_RADIUS				= 1500;
const float	MAX_CHARMER_DISTANCE		= 200;
const float	MIN_CHARMER_DISTANCE		= 150;
const float	TOOCLOSE_CHARMER_DISTANCE	= 120;

float () FindCharmer =
{
	float r;

	self.effects |= EF_DIMLIGHT;

	if (self.huntingcharmer > 0)
	{
		UpdateCharmerGoal ();
		r = vlen (self.origin - self.goalentity.origin);
		if (r < MIN_CHARMER_DISTANCE)
		{
			if ((self.huntingcharmer == 3) && (r > TOOCLOSE_CHARMER_DISTANCE))
				return FALSE;
			StopHuntingCharmer ();
			return TRUE;
		}
	}
	else
	{
		r = vlen (self.origin - self.charmer.origin);

		if (r > MAX_CHARMER_DISTANCE)
		{
			HuntCharmer ();
			return FALSE;
		}
		else if (r < TOOCLOSE_CHARMER_DISTANCE)
		{
			FleeCharmer ();
			return FALSE;
		}
	}

	return TRUE;
}

entity () FindTargetCharmed =
{
	entity e, selected;
	float dist, head_dist;

	selected = world;
	dist = CHARMED_RADIUS;
	for (e = findradius (self.origin, CHARMED_RADIUS); e != world; e = e.chain)
	{
		if(!(e.flags & FL_MONSTER))
			continue;
		if (e == self.enemy)
			continue;
		if (!FilterTarget (e))
			continue;
		if (!visible (e))
			continue;

		head_dist = vlen ((self.origin + self.view_ofs) - (e.origin + e.view_ofs));

		if (head_dist < dist)
		{
			selected = e;
			dist = head_dist;
		}
	}

	return selected;
}

//============================================================================

static void () horn_touch =
{
	if (!CheckValidTouch ()) return;

	sound (other, CHAN_POWERUP, "hipitems/horn.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	sprint (other, "You got the Horn of Conjuring\n");

	horn_charmer = other;
	ItemTouched ();
	horn_charmer = world;
}

/*QUAKED item_hornofconjuring (0 .5 .5) (-16 -16 -24) (16 16 32) ? ? SUSPENDED
Horn of Conjuring. Summon a charmed creature to help the player.

Keys:
"target/2/3/4/k" - entity to trigger when picked up
"targetname" - will not spawn until triggered
"wait" - will respawn after 'wait' seconds. fires targets every time.
"count" - limit number of times to respawn
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(255 0 0) base(Item) model({ "path": ":progs/horn.mdl" }) = item_hornofconjuring : 
	"Horn of Conjuring. Summon a charmed creature to help the player." []
*/
void () item_hornofconjuring =
{
	if (!SUB_ShouldSpawn ()) return;
	self.touch = horn_touch;

	precache_model_safe ("progs/horn.mdl");
	precache_sound_safe ("hipitems/horn.wav");
	setmodel (self, "progs/horn.mdl");
	self.netname = "Horn of Conjuring";
	setsize (self, '-16 -16 0', '16 16 32');
	if (deathmatch)
		self.wait = 60;
	StartItem ();
}

#endif /* HIPNOTIC */
