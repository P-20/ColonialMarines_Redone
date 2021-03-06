/mob/living/carbon/alien/humanoid/corroder
	name = "alien corroder"
	caste = "Corroder"
	maxHealth = 100
	health = 100
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Corroder Walking"
	damagemin = 10
	damagemax = 15
	tacklemin = 3
	tacklemax = 6
	tackle_chance = 60 //Should not be above 100%
	ventcrawler = 0
	custom_pixel_x_offset = -16
	custom_pixel_y_offset = -7

/mob/living/carbon/alien/humanoid/corroder/New()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel/corroder
	AddAbility(new/obj/effect/proc_holder/alien/unweld_vent(null))

	var/matrix/M = matrix()
	M.Scale(0.85,0.85)
	src.transform = M
	..()

/obj/item/projectile/bullet/acid
	name = "acid"
	icon_state = "neurotoxin"
	damage = 0
	damage_type = TOX
	weaken = 0
	kill_count = 6

	muzzle_type = null

/obj/item/projectile/bullet/acid/on_hit(atom/target, blocked = 0)
	if(istype(target, /turf/indestructible))
		target.visible_message("<span class='alienskill'><B>[target]</B>  is hit by the acid, but nothing happens.</span>")
		qdel(src)
		return
	else if(isalien(target))
		weaken = 0
		nodamage = 1
	else
		var/fail = 0
		if(ishuman(target) && !x_stats.q_xeno_canharm)
			fail = 1

		if(fail)
			weaken = 7
		else
			var/atom/L = target
			new /obj/effect/alien/superacid2(get_turf(L), L)
			if(!ismob(target))
				target.visible_message("<span class='alienskill'><B>[target]</B> is hit by the acid and melting.</span>")
	. = ..() // Execute the rest of the code.

/obj/effect/alien/superacid2
	name = "super acid"
	desc = "Burbling corrossive stuff. I wouldn't want to touch it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "acid"

	density = 0
	opacity = 0
	anchored = 1
	unacidable = 1

	var/atom/target
	var/mob/living/carbon/human/attached
	var/ticks = 0
	var/target_strength = 6
	var/onskin = 0

/obj/effect/alien/superacid2/New(loc, target)
	..(loc)

	src.target = target

	//if(istype(target, /turf/unsimulated))
	//	qdel(src)
	//if(istype(target, /turf/simulated/shuttle))
	//	qdel(src)
	if(isturf(target)) // Turf take twice as long to take down.
		target_strength *= 2

	var/matrix/M = matrix()
	M.Scale(0.85,0.85)
	src.transform = M
	if(istype(target, /mob/living/carbon/human))
		attached = target
		attached.contents += src
		attached.overlays += src
		attached.update_icons()
		humantick()
	else
		tick()



/obj/effect/alien/superacid2/proc/tick()
	if(!target)
		qdel(src)
	if(istype(target, /obj/item/clothing))
		target_strength = 4
	ticks += 1

	if(!attached)
		var/matrix/M = matrix()
		M.Scale(1.2,1.2)
		src.transform = M

	if(ticks >= target_strength)

		for(var/mob/O in hearers(target.loc, null))
			O.show_message("<span class='alienskill'><B>[src.target] dissolves into a puddle of goop and sizzles!</B></span>", 1)

		if(istype(target, /turf/simulated/wall)) // I hate turf code.
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
			qdel(src)
			return

		if(attached && target.loc == attached)
			attached.remove_from_mob(target)
			qdel(target)
			src.target = attached
			ticks = 0
			spawn(0) humantick()
			return
		else
			if(target.loc == attached)
				attached.remove_from_mob(target)
			qdel(target)
			qdel(src)
		return

	switch(target_strength - ticks)
		if(5)
			visible_message("<span class='alienskill'><B>[src.target] is holding up against the acid!</B></span>")
		if(3)
			visible_message("<span class='alienskill'><B>[src.target]\s structure is being melted by the acid!</B></span>")
		if(2)
			visible_message("<span class='alienskill'><B>[src.target] is struggling to withstand the acid!</B></span>")
		if(0 to 1)
			visible_message("<span class='alienskill'><B>[src.target] begins to dissolve from the acid!</B></span>")
	spawn(rand(85,120)) tick()

/obj/effect/alien/superacid2/proc/humantick()
	if(!target || attached.stat == DEAD)
		qdel(src)
		return
	var/mob/living/carbon/human/H = attached
	if(!H)
		qdel(src)
		return


	if(src.onskin == 1)
		if(prob(70))
			H.visible_message("<span class='alienskill'><B>[H]'s flesh is being seared by the acid!</B></span>")

		if(prob(40))
			H.Stun(2)
			H.Weaken(2)
			H.emote("me", message="screams in agony!")
			if(prob(35))
				spawn(rand(10,25)) H.emote("scream")
		H.adjustFireLoss(rand(40,60))
		spawn(rand(30,50)) humantick()
		return

	if(H.wear_suit)
		attached = H
		target = H.wear_suit
		target.overlays += src
		H.visible_message("<span class='alienskill'><B>[target]</B> is melting from the acid.</span>")
		H << "<span class='userdanger'>Your [target] is melting from the acid!!</span>"
		spawn(0) tick()
		return
	if(H.w_uniform)
		target = H.w_uniform
		target.overlays += src
		H.visible_message("<span class='alienskill'><B>[target]</B> is melting from the acid.</span>")
		H << "<span class='userdanger'>Your [target] is melting from the acid!!</span>"
		spawn(0) tick()
		return
	else if(!H.wear_suit && !H.w_uniform)
		src.onskin = 1
		H.visible_message("<span class='alienskill'><B>[H] begins to be dissolved from the acid.</B></span>")
		if(prob(80))
			H.emote("scream")

	spawn(rand(85,120)) humantick()


/mob/living/carbon/alien/humanoid/corroder/ClickOn(var/atom/A, params)
	face_atom(A)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		spit_acid_aim(A)
		return
	..()

/mob/living/carbon/alien/humanoid/proc/spit_acid_aim(var/atom/T)
	if(!T) return
	if(src.getPlasma() > 100)
		if(usedspit <= world.time)
			usedspit = world.time + 200

			src.adjustPlasma(-100)
			var/turf/curloc = get_turf(get_step(src, dir))
			var/turf/targloc = get_turf(T)

			var/obj/item/projectile/bullet/acid/A = new /obj/item/projectile/bullet/acid(curloc)
			A.original = targloc
			A.current = curloc
			A.starting = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			A.fire()
		else
			src << "<span class='alertalien'>We need to wait before spitting!</span>"
	else
		src << "<span class='alertalien'>We need more plasma.</span>"
