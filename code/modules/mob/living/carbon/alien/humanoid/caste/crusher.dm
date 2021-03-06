/mob/living/carbon/var/in_defense = 0

/mob/living/carbon/alien/humanoid/crusher
	name = "alien crusher"
	caste = "Crusher"
	maxHealth = 450
	health = 450
	icon_state = "Crusher Walking"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	damagemin = 25
	damagemax = 35
	tacklemin = 4
	tacklemax = 7
	tackle_chance = 90 //Should not be above 100%
	ventcrawler = 0
	mob_size = MOB_SIZE_LARGE
	custom_pixel_x_offset = -18
	var/cooldown = 0

/mob/living/carbon/alien/humanoid/crusher/New()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel/crusher
	internal_organs += new /obj/item/organ/internal/alien/carapace/crusher
	internal_organs += new /obj/item/organ/internal/alien/crusher
	..()

/obj/effect/proc_holder/alien/crusher_def
	name = "Defense Pose"
	desc = "Charge forward."
	plasma_cost = 0
	action_icon_state = "crusher_def"

/obj/effect/proc_holder/alien/crusher_def/fire(mob/living/carbon/user)
	if(!isalien(user))
		return 0
	user.in_defense = !user.in_defense
	user.update_icons()
	return 1

/mob/living/carbon/alien/humanoid/crusher/bullet_act(var/obj/item/projectile/Proj, def_zone)
	if(in_defense)
		if(dir == 1)
			if(Proj.dir == 2 || Proj.dir == 6 || Proj.dir == 10)
				Proj.damage = round(Proj.damage * 0.2)
		else if(dir == 2)
			if(Proj.dir == 1 || Proj.dir == 5 || Proj.dir == 9)
				Proj.damage = round(Proj.damage * 0.2)
		else if(dir == 4)
			if(Proj.dir == 8 || Proj.dir == 9 || Proj.dir == 10)
				Proj.damage = round(Proj.damage * 0.2)
		else if(dir == 8)
			if(Proj.dir == 4 || Proj.dir == 5 || Proj.dir == 6)
				Proj.damage = round(Proj.damage * 0.2)
	..()

/obj/effect/proc_holder/alien/crush
	name = "Charge and Crush"
	desc = "Charge forward."
	plasma_cost = 0
	action_icon_state = "crusher_charge"

/obj/effect/proc_holder/alien/crush/fire(mob/living/carbon/alien/humanoid/crusher/user)
	if(!isalien(user))
		return 0
	if(user.cooldown > world.time)
		user << "\red Ability is cooling down!"
		return 0
	var/turf/T = get_turf(get_step(user,user.dir))
	for(var/mob/living/M in T.contents)
		user << "\red Something right in front of you!"
		return 0
	T = get_turf(get_step(T,user.dir))
	for(var/mob/living/M in T.contents)
		user << "\red Something right in front of you!"
		return 0

	if(istype(user.loc,/mob) || user.lying || user.stunned || user.buckled || user.stat)
		user << "\red You can't charge right now!"
		return 0

	if (istype(user.loc,/turf) && !(istype(user.loc,/turf/space)))
		for(var/mob/M in range(user, 1))
			if(M.pulling == user)
				M.stop_pulling()

		user.visible_message("<span class='userdanger'>[user] charges forward!</span>")
		playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)

		var/cur_dir = user.dir
		//var/turf/simulated/floor/tile = user.loc
		//if(tile)
		//	tile.break_tile()
		var/speed = 3
		var/hit = 0
		user.cooldown = world.time + 100
		for(var/i=0, i<30, i++)
			user.canmove = 0
			T = get_turf(get_step(user,user.dir))
			if(istype(T, /turf/indestructible))
				hit = 1
				break

			if(T.density)
				if(istype(T, /turf/simulated/wall))
					var/turf/simulated/wall/W = T
					W.dismantle_wall(1)
					hit = 1
					break
			else
				//if(istype(T, /turf/simulated/floor))
				//	var/turf/simulated/floor/F = T
				//	F.break_tile()
				for(var/atom/A in T.contents)
					if(isliving(A))
						var/mob/living/L = A
						if(L.lying)
							if(!isalien(L))
								L.adjustBruteLoss(rand(45,55))
							playsound(L, 'sound/misc/slip.ogg', 50, 1)
						else
							if(!isalien(L))
								L.adjustBruteLoss(rand(55,75))
							else
								L.Weaken(1) //For fun
							var/turf/target = get_turf(get_step(user,cur_dir))
							for(var/o=0, o<10, o++)
								target = get_turf(get_step(target,cur_dir))
							L.throw_at(target, 200, 100)
							hit = 1
							break
					else if(isobj(A))
						var/obj/O = A
						if(O.density)
							if(istype(O, /obj/machinery/computer))
								var/obj/machinery/computer/Comp = O
								if(!istype(Comp, /obj/machinery/computer/shuttle))
									Comp.set_broken()
								hit = 1
								break
							else if(istype(O, /obj/structure/closet))
								var/obj/structure/closet/Clos = O
								Clos.dump_contents()
								qdel(Clos)
							else if(istype(O,/obj/structure/window))
								O.ex_act(2)
							else if(istype(O,/obj/structure/grille))
								qdel(O)
							else if(istype(O,/obj/machinery/door))
								qdel(O)
							else if(istype(O,/obj/structure/table))
								qdel(O)
							else if(istype(O,/obj/machinery/vending))
								qdel(O)
							else if(istype(O,/obj/structure/girder))
								qdel(O)
							else if(istype(O,/obj/structure/machinegun))
								qdel(O)
							else
								hit = 1
								break
				if(hit)
					break

			if(user.lying)
				break
			if(hit)
				break
			if(i < 7)
				speed++
				if(speed > 2)
					speed = 0
					step(user, cur_dir)
			else if(i < 14)
				speed++
				if(speed > 1)
					speed = 0
					step(user, cur_dir)
			else if(i < 21)
				speed++
				if(speed > 0)
					speed = 0
					step(user, cur_dir)
			else if(i < 30)
				step(user, cur_dir)
			sleep(1)

		if(hit)
			playsound(user.loc, 'sound/weapons/tablehit1.ogg', 50, 1)

		user.canmove = 1
		return 1
	else
		user << "\red You need a ground to do this!"
		return 0

	if(istype(user.loc,/obj/structure/closet))
		var/obj/structure/closet/Clos = user.loc
		Clos.dump_contents()
		qdel(Clos)
	return 1
