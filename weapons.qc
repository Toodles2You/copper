/*
===============================================================================

PLAYER WEAPONS

individual weapons moved to their own files, as this one was getting long

===============================================================================
*/


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");
	precache_sound ("weapons/rocket1i.wav");	// nailgun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");		// sg
	precache_sound ("weapons/ric1.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");		// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");		// super spikes
	precache_sound ("weapons/tink1.wav");		// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");		// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");		// ssg
	precache_model2 ("progs/k_spike.mdl");
	precache_model ("progs/lavaball.mdl");	
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
//	precache_sound ("items/damage3.wav");

// ax sounds	
	precache_sound ("weapons/ax1.wav");			// ax swoosh
	precache_sound2 ("weapons/axhit1.wav");		// ax hit meat
	precache_sound2 ("weapons/axhit2.wav");		// ax hit meat 2
	precache_sound ("player/axhit1.wav");		// ax hit me
	precache_sound ("player/axhit2.wav");		// ax hit world
	
	precache_sound ("zombie/z_hit.wav");
	
#ifdef HIPNOTIC
	precache_sound ("enforcer/enfstop.wav");	// laser cannon
	precache_sound ("hipweap/laserg.wav");		// laser cannon
	precache_sound ("hipweap/laserric.wav");	// laser cannon ricochet

	precache_sound ("hipweap/proxwarn.wav");	// proximity bomb
	precache_sound ("hipweap/proxbomb.wav");	// proximity bomb

	precache_sound ("knight/sword1.wav");		// mjolnir
	precache_sound ("hipweap/mjolhit.wav");		// mjolnir
	precache_sound ("hipweap/mjolslap.wav");	// mjolnir
	precache_sound ("hipweap/mjoltink.wav");	// mjolnir
#endif
	

	precache_model ("progs/v_axe2.mdl");
	precache_model ("progs/v_shot.mdl");
	precache_model ("progs/v_nail.mdl");
	precache_model ("progs/v_rock.mdl");
	precache_model ("progs/v_shot2.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2.mdl");
	precache_model ("progs/v_light.mdl");
#ifdef HIPNOTIC
	precache_model ("progs/v_laserg.mdl");
	precache_model ("progs/v_hammer.mdl");
	precache_model ("progs/v_prox.mdl");
#endif

}



/*
========
SuperDamageSound
========
*/
void() SuperDamageSound =
{
	if (!has_quad(self)) return;
	if (self.super_damage_finished < time + 3) return;
	if (self.super_sound < time)
	{
		self.super_sound = time + 0.9;
		sound (self, CHAN_POWERUP, "items/damage3.wav", 1, ATTN_NORM);
	}
}

// ==================================================================

/*
=============
W_ItemForWeapon

Returns the weapon's corresponding items and/or items2 flags stored in a vector
=============
*/
vector(float weap) W_ItemForWeapon =
{
	vector fl;

	fl_x = 0;
	fl_y = 0;
	fl_z = 0;

	switch (weap)
	{
		case WPN_AXE:
			fl_x = IT_AXE;
			break;
		case WPN_SHOTGUN:
			fl_x = IT_SHOTGUN;
			break;
		case WPN_SUPER_SHOTGUN:
			fl_x = IT_SUPER_SHOTGUN;
			break;
		case WPN_NAILGUN:
			fl_x = IT_NAILGUN;
			break;
		case WPN_SUPER_NAILGUN:
			fl_x = IT_SUPER_NAILGUN;
			break;
		case WPN_GRENADE_LAUNCHER:
			fl_x = IT_GRENADE_LAUNCHER;
			break;
		case WPN_ROCKET_LAUNCHER:
			fl_x = IT_ROCKET_LAUNCHER;
			break;
		case WPN_LIGHTNING:
			fl_x = IT_LIGHTNING;
			break;
#ifdef HIPNOTIC
		case WPN_LASER_CANNON:
			fl_y = IT2_LASER_CANNON;
			break;
		case WPN_MJOLNIR:
			fl_x = IT_MJOLNIR;
			break;
		case WPN_PROXIMITY_GUN:
			fl_x = IT_PROXIMITY_GUN;
			break;
#endif
		default:
			break;
	}

	return fl;
}

/*
=============
W_WeaponForItem

Returns the items and/or items2 flags' corresponding weapon
=============
*/
float(float item, float item2) W_WeaponForItem =
{
	float weap;

	weap = WPN_NONE;

	switch (item)
	{
		case IT_AXE:
			weap = WPN_AXE;
			break;
		case IT_SHOTGUN:
			weap = WPN_SHOTGUN;
			break;
		case IT_SUPER_SHOTGUN:
			weap = WPN_SUPER_SHOTGUN;
			break;
		case IT_NAILGUN:
			weap = WPN_NAILGUN;
			break;
		case IT_SUPER_NAILGUN:
			weap = WPN_SUPER_NAILGUN;
			break;
		case IT_GRENADE_LAUNCHER:
			weap = WPN_GRENADE_LAUNCHER;
			break;
		case IT_ROCKET_LAUNCHER:
			weap = WPN_ROCKET_LAUNCHER;
			break;
		case IT_LIGHTNING:
			weap = WPN_LIGHTNING;
			break;
#ifdef HIPNOTIC
		case IT_MJOLNIR:
			weap = WPN_MJOLNIR;
			break;
		case IT_PROXIMITY_GUN:
			weap = WPN_PROXIMITY_GUN;
			break;
#endif
		default:
			break;
	}

	switch (item2)
	{
#ifdef HIPNOTIC
		case IT2_LASER_CANNON:
			weap = WPN_LASER_CANNON;
			break;
#endif
		default:
			break;
	}

	return weap;
}

/*
=============
W_HasWeapon

Returns TRUE if the entity has the specified weapon
=============
*/
float(entity who, float weap) W_HasWeapon =
{
	vector fl;

	fl = W_ItemForWeapon (weap);

	if (fl_y != 0 && (who.items2 & fl_y) != fl_y)
	{
		return FALSE;
	}

	if (fl_x != 0 && (who.items & fl_x) != fl_x)
	{
		return FALSE;
	}

	return TRUE;
}

/*
=============
W_SetHasWeapon

Gives or takes a weapon from the entity, returning TRUE if the state was changed
=============
*/
float(entity who, float weap, float canihas) W_SetHasWeapon =
{
	vector fl;

	if (canihas == W_HasWeapon (who, weap))
	{
		return FALSE;
	}

	fl = W_ItemForWeapon (weap);

	if (canihas)
	{
		who.items |= fl_x;
		who.items2 |= fl_y;
	}
	else
	{
		who.items = not (who.items, fl_x);
		who.items2 = not (who.items2, fl_y);
	}

	return TRUE;
}

// this function is poop so i will treat it as such
float(float w) W_RankForWeapon =
{
	if (!w)
		return 666;
	if (w == WPN_LIGHTNING)
		return 1;
	if (w == WPN_ROCKET_LAUNCHER)
		return 2;
#ifdef HIPNOTIC
	if (w == WPN_LASER_CANNON)
		return 2.1;
#endif
	if (w == WPN_SUPER_NAILGUN)
		return 3;
#ifdef HIPNOTIC
	if (w == WPN_PROXIMITY_GUN)
		return 3.1;
#endif
	if (w == WPN_GRENADE_LAUNCHER)
		return 4;
	if (w == WPN_SUPER_SHOTGUN)
		return 5;
	if (w == WPN_NAILGUN)
		return 6;
#ifdef HIPNOTIC
	if (w == WPN_MJOLNIR)
		return 6.1;
#endif
	return 7;
}

/*
=============
W_BetterWeapon

Deathmatch weapon change rules for picking up a weapon
=============
*/
void(entity e, float new) W_BetterWeapon =
{
	entity oself = self;
	if (!deathmatch)
	{
		// don't switch to explosive weapons with quad
		// 1.12: don't switch to explosives when invisible either, since you can't see the stupid viewmodel
		if ( (has_quad(e) || has_invis(e)) &&
			(new == WPN_ROCKET_LAUNCHER || new == WPN_GRENADE_LAUNCHER))
			return;
		// don't switch to a lightning gun when standing in water
		if (e.waterlevel >= 2 && new == WPN_LIGHTNING)
			return;
	}	
	self = e;
	if (!deathmatch || W_RankForWeapon (new) < W_RankForWeapon (self.weapon) )
		W_Select(new);
	self = oself;
}

float(float weap) W_HasAmmo =
{
	if (weap == WPN_NONE || weap == WPN_AXE) return TRUE;
#ifdef HIPNOTIC
	if (weap == WPN_MJOLNIR) return TRUE;
#endif
	
	if (weap == WPN_SUPER_SHOTGUN)	return (self.ammo_shells >= 2);
	if (weap == WPN_SHOTGUN)		return (self.ammo_shells >= 1);
	if (weap == WPN_NAILGUN)		return (self.ammo_nails >= 1);
	if (weap == WPN_SUPER_NAILGUN)	return (self.ammo_nails >= 2);
	if (weap == WPN_LIGHTNING)		return (self.ammo_cells >= 1);
#ifdef HIPNOTIC
	if (weap == WPN_LASER_CANNON)	return (self.ammo_cells >= 1);
	if (weap == WPN_PROXIMITY_GUN)	return (self.ammo_rockets >= 1);
#endif
	if (weap == WPN_GRENADE_LAUNCHER || weap == WPN_ROCKET_LAUNCHER)
		return (self.ammo_rockets >= 1);
		
	return FALSE;
}

float() W_BestWeapon =
{
#ifdef HIPNOTIC
	if (W_HasWeapon (self, WPN_LASER_CANNON) && W_HasAmmo (WPN_LASER_CANNON))
		return WPN_LASER_CANNON;
#endif
	if(W_HasWeapon (self, WPN_SUPER_NAILGUN) && W_HasAmmo(WPN_SUPER_NAILGUN))
		return WPN_SUPER_NAILGUN;
	if(W_HasWeapon (self, WPN_SUPER_SHOTGUN) && W_HasAmmo (WPN_SUPER_SHOTGUN))
		return WPN_SUPER_SHOTGUN;

	if (W_HasWeapon (self, WPN_LIGHTNING) && self.waterlevel <= 1 && W_HasAmmo(WPN_LIGHTNING))
		return WPN_LIGHTNING;
	if(W_HasWeapon (self, WPN_NAILGUN) && W_HasAmmo(WPN_NAILGUN))
		return WPN_NAILGUN;
	if(W_HasWeapon (self, WPN_SHOTGUN) && W_HasAmmo(WPN_SHOTGUN))
		return WPN_SHOTGUN;
#ifdef HIPNOTIC
	if (W_HasWeapon (self, WPN_MJOLNIR))
		return WPN_MJOLNIR;
#endif
	if (W_HasWeapon (self, WPN_AXE))
		return WPN_AXE;
		
	if(W_HasWeapon (self, WPN_ROCKET_LAUNCHER) && W_HasAmmo(WPN_ROCKET_LAUNCHER))
		return WPN_ROCKET_LAUNCHER;
	if(W_HasWeapon (self, WPN_GRENADE_LAUNCHER) && W_HasAmmo (WPN_GRENADE_LAUNCHER))
		return WPN_GRENADE_LAUNCHER;
		
	return WPN_NONE;
}

void() W_SelectBestWeapon =
{
	W_Select(W_BestWeapon());
}

void() W_SelectBestShotgun =
{
	if (W_HasWeapon (self, WPN_SHOTGUN) || W_HasWeapon (self, WPN_SUPER_SHOTGUN))
	{
		if (!W_Select(WPN_SHOTGUN) && !W_Select(WPN_SUPER_SHOTGUN))
			sprint (self, "not enough ammo.\n");
	}
	else
	{
		sprint(self, "no weapon.\n");
	}
}

void() W_SelectBestNailgun =
{
	if (W_HasWeapon (self, WPN_NAILGUN) || W_HasWeapon (self, WPN_SUPER_NAILGUN))
	{
		if (!W_Select(WPN_NAILGUN) && !W_Select(WPN_SUPER_NAILGUN))
			sprint (self, "not enough ammo.\n");
	}
	else
	{
		sprint(self, "no weapon.\n");
	}
}


/*
============
W_ChangeWeapon
============
*/
void(float weap) W_ChangeWeapon =
{	
	if (self.customflags & CFL_PLUNGE)
		return;

	if (!W_HasWeapon (self, weap))
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}
	
	if (!W_HasAmmo (weap))
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}

	W_Select(weap);
}

/*
============
Weapon Cycling

for players who insist on shuffling through their inventory the slow way
============
*/
float W_Next(float w) =
{
	if (w == WPN_CYCLE_END) return WPN_CYCLE_START;
#ifdef HIPNOTIC
	if (w == WPN_GRENADE_LAUNCHER) return WPN_PROXIMITY_GUN;
	if (w == WPN_PROXIMITY_GUN) return WPN_GRENADE_LAUNCHER + 1;
#endif
	return w + 1;
}

float W_Prev(float w) =
{
#ifdef HIPNOTIC
	if (w == WPN_GRENADE_LAUNCHER + 1) return WPN_PROXIMITY_GUN;
	if (w == WPN_PROXIMITY_GUN) return WPN_GRENADE_LAUNCHER;
#endif
	if (w == WPN_CYCLE_START) return WPN_CYCLE_END;
	return w - 1;
}

// cycle weapon up
void() CycleWeaponCommand =
{
	float weap = self.weapon;
	if (!weap)
		weap = W_BestWeapon();
	else do {
		weap = W_Next(weap);
		if (W_HasWeapon (self, weap) && W_HasAmmo(weap))
			break;
	} while (weap != self.weapon);
	W_Select (weap);
}

// cycle weapon down
void() CycleWeaponReverseCommand =
{
	float weap = self.weapon;
	if (!weap)
		weap = W_BestWeapon();
	else do {
		weap = W_Prev(weap);
		if (W_HasWeapon (self, weap) && W_HasAmmo(weap))
			break;
	} while (weap != self.weapon);
	W_Select (weap);
}

// ==================================================================

void() W_SetIdleWeaponFrame =
{
	self.weaponframe = 0;
}

void() W_SetCurrentAmmo =
{
	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	if (self.weapon == WPN_SHOTGUN || self.weapon == WPN_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == WPN_NAILGUN || self.weapon == WPN_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == WPN_GRENADE_LAUNCHER || self.weapon == WPN_ROCKET_LAUNCHER
#ifdef HIPNOTIC
		|| self.weapon == WPN_PROXIMITY_GUN
#endif
		)
	{
		self.currentammo = self.ammo_rockets;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == WPN_LIGHTNING
#ifdef HIPNOTIC
		|| self.weapon == WPN_LASER_CANNON
		|| self.weapon == WPN_MJOLNIR
#endif
		)
	{
		self.currentammo = self.ammo_cells;
		self.items = self.items | IT_CELLS;
	}
	else	// axes, etc
	{
		self.currentammo = 0;
	}
}

void() W_ResetWeaponState =
{
	player_run ();		// get out of any weapon firing states
	self.lip = 0;	// reset nailgun barrel cycle
	self.weaponframe = 0;
	//self.attack_finished = 0;	// don't lose attack debounce time from last attack,
		// if any, or picking up/switching weapons can cause double attacks
	
	if (self.weapon == WPN_AXE )
		self.weaponmodel = "progs/v_axe2.mdl";
	else if (self.weapon == WPN_SHOTGUN)
		self.weaponmodel = "progs/v_shot.mdl";
	else if (self.weapon == WPN_SUPER_SHOTGUN)
		self.weaponmodel = "progs/v_shot2.mdl";
	else if (self.weapon == WPN_NAILGUN)
		self.weaponmodel = "progs/v_nail.mdl";
	else if (self.weapon == WPN_SUPER_NAILGUN)
		self.weaponmodel = "progs/v_nail2.mdl";
	else if (self.weapon == WPN_GRENADE_LAUNCHER)
		self.weaponmodel = "progs/v_rock.mdl";
	else if (self.weapon == WPN_ROCKET_LAUNCHER)
		self.weaponmodel = "progs/v_rock2.mdl";
	else if (self.weapon == WPN_LIGHTNING)
		self.weaponmodel = "progs/v_light.mdl";
#ifdef HIPNOTIC
	else if (self.weapon == WPN_LASER_CANNON)
		self.weaponmodel = "progs/v_laserg.mdl";
	else if (self.weapon == WPN_MJOLNIR)
		self.weaponmodel = "progs/v_hammer.mdl";
	else if (self.weapon == WPN_PROXIMITY_GUN)
		self.weaponmodel = "progs/v_prox.mdl";
#endif
	else
		self.weaponmodel = string_null;

	W_SetCurrentAmmo();
}

void() W_SelectLastWeapon =
{
	if (self.attack_state)
		W_Select(self.attack_state);
}

/*
============
W_Select
This should be the only function that changes .weapon
============
*/
float(float weap) W_Select =
{
	if (weap != WPN_NONE)
	{
		if (self.weapon == weap) return TRUE;
		if (!W_HasWeapon(self, weap)) return FALSE;
		if (!W_HasAmmo(weap)) return FALSE;
		self.attack_state = self.weapon;
	}

	self.weapon = weap;
	W_ResetWeaponState();
	return TRUE;
}

// ==================================================================


/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void() W_Attack =
{
	if (self.weapon != WPN_NONE && !W_HasAmmo(self.weapon))
	{
		W_SelectBestWeapon();
		if (self.weapon == WPN_NONE || self.weapon == WPN_AXE)
		{
			sprint (self, "not enough ammo.\n");
			return;
		}
	}
	if (self.customflags & (CFL_PLUNGE|CFL_LIMBO))
		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity

	if (self.weapon == WPN_AXE)
	{
		player_axe();
		W_AxeSwing();
		return;
	}
#ifdef HIPNOTIC
	else if (self.weapon == WPN_MJOLNIR)
	{
		// this didn't match up with the ammo needed to perform the lightning attack for some reason
		if (self.ammo_cells < 15)
			player_hammer1 ();
		else
			player_mjolnir1 ();
		W_MjolnirSwing ();
		return;
	}
#endif
	
	// moved after axe so that silent swings don't wake monsters
	self.show_hostile = time + 1;
	
	if (self.weapon == WPN_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
	}
	else if (self.weapon == WPN_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
	}
	else if (self.weapon == WPN_NAILGUN || self.weapon == WPN_SUPER_NAILGUN)
	{
		player_nail();
		W_FireSpikes ();
	}
	else if (self.weapon == WPN_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
	}
	else if (self.weapon == WPN_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
	}
	else if (self.weapon == WPN_LIGHTNING)
	{
		player_light1();
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
#ifdef HIPNOTIC
	else if (self.weapon == WPN_LASER_CANNON)
	{
		player_laser ();
		W_FireLaser ();
	}
	else if (self.weapon == WPN_PROXIMITY_GUN)
	{
		player_rocket1 ();
		W_FireProximityGrenade ();
	}
#endif
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (self.impulse)
		ImpulseCommands();
	if (time < self.attack_finished)
		return;

	// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
}

// impulses also moved to their own file
