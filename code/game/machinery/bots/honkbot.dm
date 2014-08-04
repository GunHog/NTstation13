/*The most annoying, evil, poorly coded bot ever concieved. If you are reading this with the intention of putting it on a live server, then you are truly
a monster. This bot is not intended for multiplayer. It is annoying. It will be hated. It is INTENDED to make people angry and want to kill it on sight.
If this monstrosity somehow does make it to a live server, expect any admins spawning it to be de-adminned. YOU HAVE BEEN WARNED.*/

/obj/machinery/bot/honkbot
	name = "\improper Honkbot"
	desc = "An annoying little clown robot! He looks ready to party!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "honkbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 40
	maxhealth = 40
	fire_dam_coeff = 0.5
	brute_dam_coeff = 0.2 //Clowns are natural punching bags!
//	weight = 1.0E7
	req_one_access = list(access_theatre)
	var/mob/living/carbon/victim //The poor sap we are going to HONK!
	var/oldvictim //So we do not honk the same guy twice!
	var/honklevel = 0 //To honk or not to honk
	var/victim_lastloc //Loc of victim when HONKED.
	var/last_found
	var/honk_cooldown = 0 //To keep honkbot from honk blasting too much!
	var/tells_jokes = 0 //Determines if the bot will tell jokes.
	var/chase_people = 0 //If enabled, the bot will attempt to hunt down and slip people!
	var/no_honks = 0 //Disables the honkbot's ability to make honk noises.
	var/honk_ammo = 10 //Units of "matter" stored in the honkbot's biogenerator.
	var/fired_banana = 0
	bot_type = HONK_BOT
	bot_filter = RADIO_HONKBOT

/obj/item/weapon/honkbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Honkbot" //HONK NAME



/obj/machinery/bot/honkbot/New()
	..()
	updateicon()
	set_custom_texts()
	spawn(3)

		var/datum/job/clown/J = new/datum/job/clown
		botcard.access = J.get_access()
		prev_access = botcard.access
		add_to_beacons(bot_filter)

/obj/machinery/bot/honkbot/proc/updateicon()
	if(!on)
		icon_state = "honkbuddy0"
		return

	icon_state = "[emagged == 2 ? "honkbuddyhack" : "honkbuddy1"]"


/obj/machinery/bot/honkbot/turn_on()
	..()
	updateicon()
	updateUsrDialog()

/obj/machinery/bot/honkbot/turn_off()
	..()
	updateicon()
	updateUsrDialog()

/obj/machinery/bot/honkbot/bot_reset()
	..()
	victim = null
	oldvictim = null
	fired_banana = 0
	anchored = 0
	walk_to(src,0)
	last_found = world.time
	frustration = 0

/obj/machinery/bot/honkbot/proc/set_custom_texts()

	text_hack = "[name] makes a pleased honk!"
	text_dehack = "[name] plays a sad tune."
	text_dehack_fail = "You cannot stop the HONKS!!!"

/obj/machinery/bot/honkbot/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/honkbot/interact(mob/user as mob)
	var/dat
	dat += hack(user)
	dat += text({"
<TT><B>Automated Clown v.1.0.1 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel is [open ? "opened" : "closed"]<BR>"},

"<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user))
		dat += "<BR>Biogenerator charges remaining: [honk_ammo ? "<span class='good'>[honk_ammo]</span>" : "<span class='bad'>EMPTY!</span>"]"
		dat += "<BR>Tells Jokes: <A href='?src=\ref[src];operation=jokemode'>[tells_jokes ? "<span class='good'>YES!!</span>" : "<span class='average'>No</span>"]</A>"
		dat += "<BR>Hunter Mode: <A href='?src=\ref[src];operation=chasemode'>[chase_people ? "<span class='good'>YES!!</span>" : "<span class='average'>No</span>"]</A>"
		dat += "<BR>Honk generator: <A href='?src=\ref[src];operation=horn'>[no_honks ? "<span class='average'>Off :(</span>" : "<span class='good'>Active!</span>"]</A>"
		dat += "<BR>Honk Patrol: <A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "<span class='good'>YES!!</span>" : "<span class='average'>No</span>"]</A>"
		dat += "<BR><I><B>PARTY BUTTONS!</B></I>"
		dat += "<BR>Humor Dispenser: <A href='?src=\ref[src];operation=joke'>Activate!</A>"
		dat += "<BR>Test Honk: <A href='?src=\ref[src];operation=honk'>Honk!</A>"

		if(emagged == 2)
			dat += "<BR>SUPER HONK: [honk_cooldown ? "<span class='bad'><B>Recharging!</B></span>" : "<A href='?src=\ref[src];operation=honkblast'>HOOOONK!</A>"]"

	var/datum/browser/popup = new(user, "autoclown", "Automated Clown v.1.0.1")
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/bot/honkbot/Topic(href, href_list)

	..()

	if(emagged == 2) //An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		if(!hacked) //Manually emagged by a human - access denied to all.
			usr << "<span class='warning'>[src]'s interface is not responding!</span>"
			return
		else if(!issilicon(usr)) //Bot is hacked, so only silicons are allowed access.
			usr << "<span class='warning'>[src]'s interface is not responding!</span>"
			return

	switch(href_list["operation"])
		if("honk")
			honk()
			Crossed(usr)
		if("honkblast")
			honk_blast()
		if("jokemode")
			tells_jokes = !tells_jokes
		if("joke")
			tell_joke()
		if("chasemode")
			chase_people = !chase_people
		if("horn")
			no_honks = !no_honks

	updateUsrDialog()


/obj/machinery/bot/honkbot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(user) && !open && !emagged)
			locked = !locked
			user << "Controls are now [locked ? "locked." : "unlocked."]"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='danger'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='danger'> Access denied.</span>"
	else
		..()
		if(!istype(W, /obj/item/weapon/screwdriver) && !istype(W, /obj/item/weapon/weldingtool) && W.force && !victim )
			var/cry_for_help = pick("[user] is killing me! HELP!", "Quit griffin me!","Ow! That hurts!!", "Was it something I said!?")
			speak(cry_for_help) //If attacked, the honkbot will cry for help! This helps it to be even more annoying!
	return

/obj/machinery/bot/honkbot/Emag(mob/user as mob)
	..()
	if(emagged == 2)
		if(user) user << "<span class='danger'> You short-circuit [src]'s HONK restraining module!</span>"
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='danger'><B>[src] makes a garbled noise!</B></span>", 1)
			playsound(loc, 'sound/AI/aimalf.ogg', 40, 1)
		//if(user) oldvictim_name = user.name
	tells_jokes = 1
	chase_people = 1
	no_honks = 0
	auto_patrol = 1

/obj/machinery/bot/honkbot/process()
	set background = BACKGROUND_ENABLED

	if(!on)
		return
	if(call_path)
		if(!pathset)
			set_path()
			victim = null
			anchored = 0
			walk_to(src,0)
		else
			move_to_call()
			sleep(5)
			move_to_call()
		return



	if(emagged == 2)
		if(prob(5)) //MAKE SOME NOOOISE!
			honk_blast()
			return
		else if(prob(6))
			spark() //Hey, if we are lucky, we might just start a plasma fire!
			return

	if(prob(10) && !no_honks) //Honk!
		honk()

	if(prob(10) && tells_jokes)
		tell_joke()

	if(chase_people && mode != BOT_CHASE)
		find_victim()	// Attempt to find someone to chase around!
	switch(mode)

		if(BOT_IDLE)		// idle

			walk_to(src,0)
			if(auto_patrol)	// Time to patrol if we have nothing to Honk!
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_CHASE)		//Chase people!

			// If the Honkbot cannot reach his victim, he must give up!
			if(frustration >= 8 || honk_ammo < 1) //There is no point in chasing a target if you are out of ammo!
				visible_message("[src] makes a sad buzz.")
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 60, 0)
				bot_reset()
				return

			if(victim)		// make sure victim exists
				if(isturf(loc) && isturf(victim.loc) && loc == victim.loc)	//Bot must be on bottom of victim!
					//playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
					victim.slip(4, 3, src) //Slip him! HONK!
					var/obj/item/weapon/reagent_containers/food/snacks/pie/P = new /obj/item/weapon/reagent_containers/food/snacks/pie(loc)
					P.throw_at(victim,2,4) //Yep, it chases you down so it can pie you in the face. HONK!
					mode = BOT_IDLE
					oldvictim = victim
					victim = null
					visible_message("[src] pings with great joy!")
					playsound(loc, 'sound/machines/ping.ogg', 60, 0) //Laughing at your victory is the trademark of a clown!
					walk_to(src,0)
					fired_banana = 0
					return

				else if(honk_ammo > 1)		// not next to victim, and still have ammo left! CHASE HIM!!
					var/turf/victim_distance = get_dist(src, victim)
					walk_to(src, victim,0, 3) //Can you outrun the HONKS!?
					if((get_dist(src, victim)) >= (victim_distance))
						frustration++ //He is getting away!
					else
						frustration = 0

					if(victim_distance < 6 && !fired_banana) //In HONK range!
						var/obj/item/weapon/grown/bananapeel/BP = new /obj/item/weapon/grown/bananapeel(loc)
						BP.throw_at(victim,7,10) //Fire banana to slow down our victim!
						if(BP.loc == victim.loc)
							BP.Crossed(victim) //Make SURE the victim slips! HAHA!
						fired_banana = 1 //Only fire one banana per victim.
						honk_ammo--
						honk() //This honk() is here just to make it that much more annoying!
					return

		if(BOT_START_PATROL)
			start_patrol()

		if(BOT_PATROL)
			bot_patrol()
			playsound(loc, "clownstep", 50, 1)

		if(BOT_SUMMON)
			bot_summon()
	return



/obj/machinery/bot/honkbot/proc/honk() //Plays sounds, usually bike horn honks, but sometimes others.
	if(emagged != 2) //Regular honk noise!
		playsound(loc, 'sound/items/bikehorn.ogg', 55, 1)
	else //Random annoying noises
		var/noise = noise_picker()
		playsound(loc, noise, 100, 1)

/obj/machinery/bot/honkbot/proc/noise_picker()
	var/chosen_noise
	var/list/noise_list = list()
	noise_list = list("explosion","bodyfall","punch","gunshot",'sound/machines/Alarm.ogg','sound/hallucinations/veryfar_noise.ogg')
	noise_list = scarySounds + noise_list

	chosen_noise = pick(noise_list)
	return chosen_noise

/obj/machinery/bot/honkbot/proc/honk_blast() //Even in space, you will hear me HONK!
	if(honk_cooldown)
		return

	playsound(loc, 'sound/items/AirHorn.ogg', 100, 1)
	visible_message("<font color='red' size='7'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, src))
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
				continue
		M.sleeping = 0
		M.stuttering += 20
		M.ear_deaf += 30
		M.Weaken(3)
		if(prob(30))
			M.Stun(10)
			M.Paralyse(4)
		else
			M.Jitter(500)
	honk_cooldown = 1
	spawn(600) //One minute.
	honk_cooldown = 0

/obj/machinery/bot/honkbot/proc/find_victim()
	if(!chase_people || !honk_ammo)
		return

	for (var/mob/living/carbon/human/H in view(7, src)) //BEGIN THE HUNT!
		if ( H.stat|| H.lying || allowed(H) || H == oldvictim ) //We do not honk a man while he is down, has access to us, or was already honked!
			continue

//		if (world.time < last_found + 200) //We recently honked someone, we need time to rest!
//			continue

		speak(pick("TIME TO PARTY!!","Party time!","Prepare for HONKING!","Freeze, honkbag!"))
		honk()
		visible_message("<b>[src]</b> points at [H.name]!")
		victim = H
		mode = BOT_CHASE
		spawn(0)
			process()	//The HONKING begins NOW!
		return

/obj/machinery/bot/honkbot/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		M.slip(3, 2, src)
		honk_ammo = min(honk_ammo+1,10) //No more than 10 charges!
		if(prob(15))
			speak("Honk!")

/obj/machinery/bot/honkbot/proc/tell_joke() //Because clowns are supposed to be funny!
	var/joke
	var/list/JL //The list of jokes.
	if(emagged != 2) //"Clean" joke list!
		JL = list( "What did the wall say to the other wall? MEET YOU AT THE CORNER!",
		"Why are AIs so calm? BECAUSE NOTHING GETS UNDER THEIR SKIN!",
		"I heard that being a vampire really SUCKS!",
		"Slime-people can't lie to me. I CAN SEE RIGHT THROUGH THEM!",
		"Why do cyborgs hate pie? BECAUSE THEY DON'T HAVE THE STOMACH FOR IT!",
		"Who as the mose famous skeleton detective? SHERLOCK BONES!",
		"The other day I held an airlock open for a clown. I THOUGHT IT WAS A NICE JESTER!",
		"Why did the capacitor kiss the diode? HE JUST COULDN'T RESISTOR!",
		"What do you call a lizard-man detective? An investiGATOR!",
		"Did you here about the guy who lost his whole left side? He’s all-right now!",
		"What do you call a cow with no legs? GROUND BEEF!",
		"What do you call cheese that isn't yours? NACHO CHEESE!",
		"OH GOD ITS FREE CALL THE SHUTTLE!")

	else //Dirty or inapproprate jokes here. Keep it IC and legal please!
		JL = list("Yo mama so hairy, When you were born, You got carpet burn!",
		"What goes in dry and comes out wet? A tea bag!",
		"Did you hear about the kidnapping at the Dorms? It’s ok, she woke up!",
		"Why does the CMO keep Runtime around? She's the only pussy he'll ever get!",
		"Why did Sally drop her ice cream? She got hit by the shuttle!",
		"Why did the Engineer's wife bring the Captain to bed? She needed a Comdom!",)

	joke = pick(JL)
	speak(joke)

/obj/machinery/bot/honkbot/proc/spark()
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

/obj/machinery/bot/honkbot/explode()

	walk_to(src,0)
	if(emagged == 2) //As a final middle finger to the killer, the bot will HONK you one last time!
		speak("SEE HOW YOU LIKE THIS!")
		honk_cooldown = 0
		honk_blast()
	else
		speak("Nobody likes me...")

	visible_message("<span class='danger'> <B>[src] blows apart!</B></span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/weapon/bikehorn(Tsec)

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	spark()

	new /obj/effect/decal/cleanable/oil(loc)
	qdel(src)

/obj/machinery/bot/honkbot/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(victim))
		victim = user
		mode = BOT_HUNT

//Honk Construction - ADMIN ONLY BECAUSE HONK
