/mob/living/carbon/alien/hitby(atom/movable/AM, skipcatch, hitpush)
	..(AM, skipcatch = 1, hitpush = 0)


/*Code for aliens attacking aliens. Because aliens act on a hivemind, I don't see them as very aggressive with each other.
As such, they can either help or harm other aliens. Help works like the human help command while harm is a simple nibble.
In all, this is a lot like the monkey code. /N
*/
/mob/living/carbon/alien/attack_alien(mob/living/carbon/alien/M)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)

		if ("help")
			sleeping = max(0,sleeping-5)
			resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)
			visible_message("<span class='notice'>[M.name] nuzzles [src] trying to wake it up!</span>")

		if ("grab")
			grabbedby(M)

		else
			if (health > 0)
				M.do_attack_animation(src)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				var/damage = 1
				var/harm_message = "bites"
				if(istype(M, /mob/living/carbon/alien/humanoid/queen) && x_stats.q_queen_canharm)
					var/mob/living/carbon/alien/humanoid/queen/Q = M
					damage = rand(Q.damagemin, Q.damagemax)
					harm_message = "punishes"
				visible_message("<span class='danger'>[M.name] [harm_message] [src]!</span>", \
						"<span class='userdanger'>[M.name] [harm_message] [src]!</span>")
				adjustBruteLoss(damage)
				add_logs(M, src, "attacked")
				updatehealth()
			else
				M << "<span class='warning'>[name] is too injured for that.</span>"
	return


/mob/living/carbon/alien/attack_larva(mob/living/carbon/alien/larva/L)
	return attack_alien(L)


/mob/living/carbon/alien/attack_hand(mob/living/carbon/human/M)
	if(..())	//to allow surgery to return properly.
		return 0

	switch(M.a_intent)
		if("help")
			help_shake_act(M)
		if("grab")
			grabbedby(M)
		if ("harm", "disarm")
			if(M.buckled)
				if(istype(M.buckled, /obj/structure/stool/bed/nest))
					return 0
			M.do_attack_animation(src)
			return 1
	return 0


/mob/living/carbon/alien/attack_paw(mob/living/carbon/monkey/M)
	if(..())
		if (stat != DEAD)
			adjustBruteLoss(rand(1, 3))
			updatehealth()
	return


/mob/living/carbon/alien/attack_animal(mob/living/simple_animal/M)
	if(..())
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/alien/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 35)
		if(M.is_adult)
			damage = rand(10, 40)
		adjustBruteLoss(damage)
		add_logs(M, src, "attacked")
		updatehealth()
