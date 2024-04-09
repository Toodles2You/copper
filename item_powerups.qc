/*
===============================================================================

POWERUPS

===============================================================================
*/

/*
===============
powerup_envirosuit
===============
*/
void(entity h, float t) powerup_envirosuit =
{
	sprint (h, "It's stuffy in this thing ...\n");
	h.items |= IT_SUIT;
	h.rad_time = 1;
	h.radsuit_finished = time + t;
}

/*
===============
powerup_invulnerability
===============
*/
void(entity h, float t) powerup_invulnerability =
{
	sprint (h, "An unholy ward surrounds you ...\n");
	h.items |= IT_INVULNERABILITY;
	h.invincible_time = 1;
	h.invincible_finished = time + t;
}

/*
===============
powerup_invisibility
===============
*/
void(entity h, float t) powerup_invisibility =
{
	sprint (h, "Others' eyes deceive them, but yours give you away ...\n");
	h.items |= IT_INVISIBILITY;
	//h.notrace = 1;
	h.invisible_time = 1;
	h.invisible_finished = time + t;
	h.invisible_sound = time + 1.5;
}

/*
===============
powerup_super_damage
===============
*/
void(entity h, float t) powerup_super_damage =
{
	sprint (h, "You begin to channel unstoppable power ...\n");
	h.items |= IT_QUAD;
	h.super_damage_finished = time + t;
	h.super_time = 1;
}

#ifdef HIPNOTIC

/*
===============
powerup_wetsuit
===============
*/
void(entity h, float t) powerup_wetsuit =
{
	sprint (h, "This thing is chafing ...\n");
	h.items2 |= IT2_WETSUIT;
	h.wetsuit_finished = time + t;
	h.wetsuit_time = 1;
}

/*
===============
powerup_empathy_shields
===============
*/
void(entity h, float t) powerup_empathy_shields =
{
	sprint (h, "A vicarious energy whirls around you ...\n");
	h.items2 |= IT2_EMPATHY_SHIELDS;
	h.empathy_finished = time + t;
	h.empathy_time = 1;
}

#endif /* HIPNOTIC */

/*
===============
powerup_touch
===============
*/
void() powerup_touch =
{
	if ( !CheckValidTouch() ) return;

	sound (other, CHAN_POWERUP, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;
	other.items2 = other.items2 | self.items2;

	if (self.classname == "item_artifact_envirosuit")
		powerup_envirosuit(other, 30);
	
	else if (self.classname == "item_artifact_invulnerability")
		powerup_invulnerability(other, 30);
	
	else if (self.classname == "item_artifact_invisibility")
		powerup_invisibility(other, 30);

	else if (self.classname == "item_artifact_super_damage")
		powerup_super_damage(other, 30);

#ifdef HIPNOTIC
	else if (self.classname == "item_artifact_wetsuit")
		powerup_wetsuit(other, 30);
	
	else if (self.classname == "item_artifact_empathy_shields")
		powerup_empathy_shields(other, 30);
#endif

	ItemTouched();
}


/*
===============================================================================

PENTAGRAM

===============================================================================
*/
void() precache_invulnerability =
{
	precache_model_safe ("progs/invul.mdl");
	precache_sound_safe ("items/protect.wav");
	precache_sound_safe ("items/protect2.wav");
	precache_sound_safe ("items/protect3.wav");
}
/*QUAKED item_artifact_invulnerability (0 .5 .5) (-16 -16 -24) (16 16 32) ? ? SUSPENDED
Pentagram of Protection. Player is invulnerable for 30 seconds (both health and armor).

Keys:
"target/2/3/4/k" - entity to trigger when picked up
"targetname" - will not spawn until triggered
"wait" - will respawn after 'wait' seconds. fires targets every time.
"count" - limit number of times to respawn
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(255 0 0) base(Item) model({ "path": ":progs/invul.mdl" }) =
	item_artifact_invulnerability : "Pentagram of Protection. Player is invulnerable for 30 seconds (both health and armor)." []
*/
void() item_artifact_invulnerability =
{
	if (!SUB_ShouldSpawn()) return;
	self.touch = powerup_touch;
	precache_invulnerability();
	
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invul.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	if (deathmatch)
		self.wait = 300;
	StartItem ();
}


/*
===============================================================================

BIOSUIT

===============================================================================
*/
void() precache_envirosuit =
{
	precache_model_safe ("progs/suit.mdl");
	precache_sound_safe ("items/suit.wav");
	precache_sound_safe ("items/suit2.wav");
}
/*QUAKED item_artifact_envirosuit (0 .5 .5) (-16 -16 -8) (16 16 48) ? ? SUSPENDED
Envirosuit. Player takes no damage from water or slime for 30 seconds. Lava damage is reduced by one height step, enabling wading in foot-deep lava.

Keys:
"target/2/3/4/k" - entity to trigger when picked up
"targetname" - will not spawn until triggered
"wait" - will respawn after 'wait' seconds. fires targets every time.
"count" - limit number of times to respawn
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(255 0 0) base(Item) model({ "path": ":progs/suit.mdl" }) =
	item_artifact_envirosuit : "Envirosuit. Player takes no damage from water or slime for 30 seconds. Lava damage is reduced by one height step, enabling wading in foot-deep lava." []
*/
void() item_artifact_envirosuit =
{
	if (!SUB_ShouldSpawn()) return;
	self.touch = powerup_touch;

	precache_envirosuit();
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize (self, '-16 -16 -8', '16 16 48');
	if (deathmatch)
		self.wait = 60;
	StartItem ();
}


/*
===============================================================================

RING OF SHADOWS

===============================================================================
*/
void() precache_invisibility =
{
	precache_model_safe ("progs/invis.mdl");
	precache_sound_safe ("items/inv1.wav");
	precache_sound_safe ("items/inv2.wav");
	precache_sound_safe ("items/inv3.wav");
}

/*QUAKED item_artifact_invisibility (0 .5 .5) (-16 -16 -24) (16 16 32) ? ? SUSPENDED
Ring of Shadows. Player is invisible for 30 seconds. Monsters will not awaken on sight, but they will on hearing sound (like gunfire). Awakened monsters will try to attack an invisible player and do an inaccurate job, possibly starting infights. 
monster_dog can still smell an invisible player, but monster_tarbaby can't find the player at all.

Keys:
"target/2/3/4/k" - entity to trigger when picked up
"targetname" - will not spawn until triggered
"wait" - will respawn after 'wait' seconds. fires targets every time.
"count" - limit number of times to respawn
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(255 0 0) base(Item) model({ "path": ":progs/invis.mdl" }) = 
	item_artifact_invisibility : "Ring of Shadows. Player is invisible for 30 seconds. Monsters will not awaken on sight, but they will on hearing sound (like gunfire). Awakened monsters will try to attack an invisible player and do an inaccurate job, possibly starting infights. 
monster_dog can still smell an invisible player, but monster_tarbaby can't find the player at all." []
*/
void() item_artifact_invisibility =
{
	if (!SUB_ShouldSpawn()) return;
	self.touch = powerup_touch;
	precache_invisibility();
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invis.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	if (deathmatch)
		self.wait = 300;
	StartItem ();
}


/*
===============================================================================

QUAD

===============================================================================
*/
void() precache_super_damage =
{
	precache_model_safe ("progs/quaddama.mdl");
	precache_sound_safe ("items/damage.wav");
	precache_sound_safe ("items/damage2.wav");
	precache_sound_safe ("items/damage3.wav");
}

/*QUAKED item_artifact_super_damage (0 .5 .5) (-16 -16 -24) (16 16 32) ? ? SUSPENDED
Quad Damage. Player's attacks do 4x damage and they stop paying attention to anything else.

Keys:
"target/2/3/4/k" - entity to trigger when picked up
"targetname" - will not spawn until triggered
"wait" - will respawn after 'wait' seconds. fires targets every time.
"count" - limit number of times to respawn
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(255 0 0) base(Item) model({ "path": ":progs/quaddama.mdl" }) = item_artifact_super_damage : 
	"Quad Damage. Player's attacks do 4x damage and they stop paying attention to anything else." []
*/
void() item_artifact_super_damage =
{
	if (!SUB_ShouldSpawn()) return;
	self.touch = powerup_touch;

	precache_super_damage();
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.noise = "items/damage.wav";
	self.items = IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	if (deathmatch)
		self.wait = 60;
	StartItem ();
}


#ifdef HIPNOTIC

/*
===============================================================================

WETSUIT

===============================================================================
*/
void() precache_wetsuit =
{
	precache_model_safe ("progs/wetsuit.mdl");
	precache_sound_safe ("misc/wetsuit.wav");
	precache_sound_safe ("misc/weton.wav");
	precache_sound_safe ("items/suit2.wav");
}

/*QUAKED item_artifact_wetsuit (0 .5 .5) (-16 -16 -24) (16 16 32) ? ? SUSPENDED
Wetsuit. Player takes no damage from electrical attacks and swims faster for 30 seconds.

Keys:
"target/2/3/4/k" - entity to trigger when picked up
"targetname" - will not spawn until triggered
"wait" - will respawn after 'wait' seconds. fires targets every time.
"count" - limit number of times to respawn
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(255 0 0) base(Item) model({ "path": ":progs/wetsuit.mdl" }) = item_artifact_wetsuit : 
	"Wetsuit. Player takes no damage from electrical attacks and swims faster for 30 seconds." []
*/
void() item_artifact_wetsuit =
{
	if (!SUB_ShouldSpawn()) return;
	self.touch = powerup_touch;

	precache_wetsuit();
	setmodel (self, "progs/wetsuit.mdl");
	self.netname = "Wetsuit";
	self.noise = "misc/weton.wav";
	self.items2 = IT2_WETSUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	if (deathmatch)
		self.wait = 60;
	StartItem ();
}


/*
===============================================================================

EMPATHY SHIELDS

===============================================================================
*/
void() precache_empathy_shields =
{
	precache_model_safe ("progs/empathy.mdl");
	precache_sound_safe ("hipitems/empathy.wav");
	precache_sound_safe ("hipitems/empathy2.wav");
	precache_sound_safe ("items/suit2.wav");
}

/*QUAKED item_artifact_empathy_shields (0 .5 .5) (-16 -16 -24) (16 16 32) ? ? SUSPENDED
Empathy Shields.

Keys:
"target/2/3/4/k" - entity to trigger when picked up
"targetname" - will not spawn until triggered
"wait" - will respawn after 'wait' seconds. fires targets every time.
"count" - limit number of times to respawn
*/
/*FGD
@PointClass size(-16 -16 -24, 16 16 32) color(255 0 0) base(Item) model({ "path": ":progs/empathy.mdl" }) = item_artifact_empathy_shields : 
	"Empathy Shields." []
*/
void() item_artifact_empathy_shields =
{
	if (!SUB_ShouldSpawn()) return;
	self.touch = powerup_touch;

	precache_empathy_shields();
	setmodel (self, "progs/empathy.mdl");
	self.netname = "Empathy Shields";
	self.noise = "hipitems/empathy.wav";
	self.items2 = IT2_EMPATHY_SHIELDS;
	setsize (self, '-16 -16 0', '16 16 32');
	if (deathmatch)
		self.wait = 60;
	StartItem ();
}

#endif /* HIPNOTIC */






