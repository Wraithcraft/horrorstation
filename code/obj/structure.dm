/mob/living/carbon/human/var/reinforcing_structure = 0

obj/structure
	icon = 'icons/obj/structures.dmi'

	girder
		icon_state = "girder"
		anchored = 1
		density = 1
		var/state = 0
		desc = "A metal support for an incomplete wall. Metal could be added to finish the wall, reinforced metal could make the girders stronger, or it could be pried to displace it."

		displaced
			name = "displaced girder"
			icon_state = "displaced"
			anchored = 0
			desc = "An unsecured support for an incomplete wall. A screwdriver would seperate the metal into sheets, or adding metal or reinforced metal could turn it into fake wall that could opened by hand."

		reinforced
			icon_state = "reinforced"
			state = 2
			desc = "A reinforced metal support for an incomplete wall. Reinforced metal could turn it into a reinforced wall, or it could be disassembled with various tools."

	blob_act(var/power)
		if (power < 30)
			return
		if (prob(power - 29))
			qdel(src)

	meteorhit(obj/O as obj)
		qdel(src)

obj/structure/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			return
	return

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/wrench) && state == 0 && anchored && !istype(src,/obj/structure/girder/displaced))
		playsound(src.loc, "sound/items/Ratchet.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span style=\"color:blue\">Now disassembling the girder</span>")
		sleep(40)
		if(get_turf(user) == T)
			boutput(user, "<span style=\"color:blue\">You dissasembled the girder!</span>")
			var/atom/A = new /obj/item/sheet(get_turf(src))
			if (src.material)
				A.setMaterial(src.material)
			else
				var/datum/material/M = getCachedMaterial("steel")
				A.setMaterial(M)
			qdel(src)

	else if(istype(W, /obj/item/screwdriver) && state == 2 && istype(src,/obj/structure/girder/reinforced))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span style=\"color:blue\">Now unsecuring support struts</span>")
		sleep(40)
		if(get_turf(user) == T)
			boutput(user, "<span style=\"color:blue\">You unsecured the support struts!</span>")
			state = 1

	else if(istype(W, /obj/item/wirecutters) && istype(src,/obj/structure/girder/reinforced) && state == 1)
		playsound(src.loc, "sound/items/Wirecutter.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span style=\"color:blue\">Now removing support struts</span>")
		sleep(40)
		if(get_turf(user) == T)
			boutput(user, "<span style=\"color:blue\">You removed the support struts!</span>")
			var/atom/A = new/obj/structure/girder( src.loc )
			if(src.material) A.setMaterial(src.material)
			qdel(src)

	else if(istype(W, /obj/item/crowbar) && state == 0 && anchored )
		playsound(src.loc, "sound/items/Crowbar.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span style=\"color:blue\">Now dislodging the girder</span>")
		sleep(40)
		if(get_turf(user) == T)
			boutput(user, "<span style=\"color:blue\">You dislodged the girder!</span>")
			var/atom/A = new/obj/structure/girder/displaced( src.loc )
			if(src.material) A.setMaterial(src.material)
			qdel(src)

	else if(istype(W, /obj/item/wrench) && state == 0 && !anchored )
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span style=\"color:red\">Not sure what this floor is made of but you can't seem to wrench a hole for a bolt in it.</span>")
			return
		playsound(src.loc, "sound/items/Ratchet.ogg", 100, 1)
		var/turf/T = get_turf(user)
		boutput(user, "<span style=\"color:blue\">Now securing the girder</span>")
		sleep(40)
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span style=\"color:red\">You feel like your body is being ripped apart from the inside. Maybe you shouldn't try that again. For your own safety, I mean.</span>")
			return
		if(get_turf(user) == T)
			boutput(user, "<span style=\"color:blue\">You secured the girder!</span>")
			var/atom/A = new/obj/structure/girder( src.loc )
			if(src.material) A.setMaterial(src.material)
			qdel(src)

	else if (istype(W, /obj/item/sheet))
		var/obj/item/sheet/S = W
		if (S.amount < 2)
			boutput(user, "<span style=\"color:red\">You need at least two sheets on the stack to do this.</span>")
			return

		var/turf/T = get_turf(user)

		if (src.icon_state != "reinforced" && S.reinforcement)
			user.visible_message("<b>[user]</b> begins reinforcing [src].")
			sleep(60)
			if (user.loc == T)
				boutput(user, "You finish reinforcing the girder.")
				var/atom/A = new/obj/structure/girder/reinforced( src.loc )
				if (W.material)
					A.setMaterial(src.material)
				else
					var/datum/material/M = getCachedMaterial("steel")
					A.setMaterial(M)
				qdel(src)
				return
			else
				boutput(user, "<span style=\"color:red\">You'll need to stand still while reinforcing the girder.</span>")
				return

		else
			user.visible_message("<b>[user]</b> begins adding plating to [src].")
			sleep(20)
			// it was a good run, finishing all those walls with a sheet of 2 metal, but this is now causing runtimes
			// so i'm going to be hitler yet again -- marquesas
			if (get_turf(user) == T && W && user.equipped() == W && S.amount >= 2 && istype(src.loc, /turf/simulated/floor/))
				boutput(user, "You finish building the wall.")
				logTheThing("station", user, null, "builds a Wall in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
				var/turf/Tsrc = get_turf(src)
				var/turf/simulated/wall/WALL
				if (S.reinforcement)
					WALL = Tsrc.ReplaceWithRWall()
				else
					WALL = Tsrc.ReplaceWithWall()
				if (src.material)
					WALL.setMaterial(src.material)
				else
					var/datum/material/M = getCachedMaterial("steel")
					WALL.setMaterial(M)
				// drsingh attempted fix for Cannot read null.amount
				if (S != null)
					S.amount -= 2
					if(S.amount <= 0)
						qdel(W)
				qdel(src)
		return

	else
		..()

/obj/structure/girder/displaced/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/sheet))
		if (!istype(src.loc, /turf/simulated/floor/))
			boutput(user, "<span style=\"color:red\">You can't build a false wall there.</span>")
			return

		var/obj/item/sheet/S = W
		var/turf/simulated/floor/T = src.loc

		var/FloorIcon = T.icon
		var/FloorState = T.icon_state
		var/FloorIntact = T.intact
		var/FloorBurnt = T.burnt
		var/FloorName = T.name
		var/oldmat = src.material

		var/atom/A = new /turf/simulated/wall/false_wall(src.loc)
		if(oldmat)
			A.setMaterial(oldmat)
		else
			var/datum/material/M = getCachedMaterial("steel")
			A.setMaterial(M)

		var/turf/simulated/wall/false_wall/FW = A

		FW.setFloorUnderlay(FloorIcon, FloorState, FloorIntact, 0, FloorBurnt, FloorName)
		FW.known_by += user
		if (S.reinforcement)
			FW.icon_state = "rdoor1"
		S.amount--
		if (S.amount < 1)
			qdel(S)
		boutput(user, "You finish building the false wall.")
		logTheThing("station", user, null, "builds a False Wall in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
		qdel(src)
		return

	else if (istype(W, /obj/item/screwdriver))
		var/obj/item/sheet/S = new /obj/item/sheet(src.loc)
		if(src.material)
			S.setMaterial(src.material)
		else
			var/datum/material/M = getCachedMaterial("steel")
			S.setMaterial(M)
		playsound(src.loc, "sound/items/Screwdriver.ogg", 75, 1)
		qdel(src)
		return
	else
		return ..()

/obj/structure/woodwall
	name = "wooden barricade"
	desc = "This was thrown up in a hurry."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodwall"
	anchored = 1
	density = 1
	opacity = 1
	var/being_reinforced = 0
	var/health = 100
	var/builtby = null

	var/list/sawbuilt = list()
	var/list/climbed = list()

	virtual
		icon = 'icons/effects/VR.dmi'

	New()
		..()
		health = rand(100,200)

	proc/beforeDel()
		if (prob(50))
			new/obj/item/woodstuff/plank(src.loc)
		else
			new/obj/item/woodstuff/woodclutter(src.loc)

	MouseDrop_T(var/mob/m, var/mob/user)
		var/user_climb_time = 100
		var/fail_chance = 50
		var/override_msg = ""
		var/span_style = "<span style = \"color:red\"><b>"
		var/span_end = "</span></b>"

		if (!isitem(m) && !ismob(m))
			return

		if (isitem(m))
			user_climb_time = 0
			fail_chance = 5
			override_msg = "[user] throws [m] over [src]."

		var/message_addendum = ""

		if (isAlien(user))
			boutput(user, "<span style = \"color:red\"><b>You have no idea of how to climb this. You would be better off breaking it down.</span>")
			return

		if (builtby == user.real_name)
			fail_chance = 0
			user_climb_time = 20
			message_addendum = "You find it very easy, since you made it."

		else if (sawbuilt && sawbuilt.len && sawbuilt.Find(user))
			fail_chance = 15
			user_climb_time = 75
			message_addendum = "You find it easy, since you saw it built."

			if (climbed && climbed.len && climbed.Find(user))
				fail_chance = 10
				user_climb_time = 35
				message_addendum = "You find it very easy to climb."

		else

			if (climbed && climbed.len && climbed.Find(user))
				fail_chance = 20
				user_climb_time = 50
				message_addendum = "You find it relatively easy to climb the [src]."
			else
				fail_chance = 40
				user_climb_time = 150
				message_addendum = "You have no idea of how to climb it. This may take a while."


		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.mutantrace && !istype(H.mutantrace, /datum/mutantrace/dwarf))
				if (m != user)
					return
				fail_chance = 60
				user_climb_time = rand(500,700)
				message_addendum = "You have no idea of how to climb it. It is very complex to your tiny brain."


		if (isitem(m))
			m.anchored = 1
			visible_message("<span style = \"color:red\">[override_msg]</span>")
			sleep(user_climb_time)
			if (prob(fail_chance))
				visible_message("<span style = \"color:red\">The [m] hits the wall and falls off.</span>")
				m.anchored = 0
				return
			else
				m.anchored = 0
				m.set_loc(src.loc)
				switch (m.dir)
					if (NORTH)
						m.y++
					if (SOUTH)
						m.y--
					if (EAST)
						m.x++
					if (WEST)
						m.x--
				return

		if (m == user)
			user.visible_message("<span style = \"color:red\"><b>[user] starts to climb [src].</span></b>", "<span style = \"color:blue\"><b>You start to climb the [src]. [message_addendum]</span></b>")
			user.anchored = 1
			sleep (user_climb_time)
			if (locate(user) in range(1, src))
				if (prob(fail_chance))
					user.visible_message("<span style = \"color:red\"><b>[user] falls off of the [src]!</span>", "<span style = \"color:red\">You fall off of the [src]!</span></b>")
					user.anchored = 0
					if (ishuman(user))
						var/mob/living/carbon/human/H = user
						H.TakeDamage("All", rand(1,3))
						H.weakened += 5
						H.stunned += 5
						return
				user.anchored = 0
				user.set_loc(src.loc)
				user.visible_message("<span style = \"color:red\"><b>[user] climbs [src].</span></b>", "<span style = \"color:blue\"><b>You climb [src].</b></span>")
				climbed |= user
			else
				user.anchored = 0
		else
			m.anchored = 1
			user.visible_message("<span style = \"color:red\"><b>[user] starts to push [m] over [src]!</span></b>", "<span style = \"color:blue\"><b>You start to push [m] over [src]!</span></b>")
			sleep (user_climb_time/rand(2,3))
			user.visible_message("<span style = \"color:red\"><b>[user] pushes [m] over [src]!</span></b>", "<span style = \"color:blue\"><b>You push [m] over [src]!</span></b>")
			m.set_loc(src.loc)
			climbed |= m
			m.anchored = 0

	proc/checkhealth()
		if(src.health <= 30)
			icon_state = "woodwall"
		if(src.health <= 20)
			icon_state = "woodwall2"
		if(src.health <= 10)
			icon_state = "woodwall3"
			opacity = 0
		if(src.health <= 5)
			icon_state = "woodwall4"
		if(src.health <= 0)
			src.visible_message("<span style=\"color:red\"><b>[src] collapses!</b></span>")
			playsound(src.loc, "sound/effects/wbreak.wav", 100, 1)
			beforeDel()
			qdel(src)

	attack_hand(mob/user as mob)
		if (istype(user, /mob/living/carbon/human))
			if (!isAlien(user))
				src.visible_message("<span style=\"color:red\"><b>[user]</b> bashes [src]!</span>")
				playsound(src.loc, "sound/effects/zhit.ogg", 100, 1)
				src.health -= rand(1,3)

				if (prob(1) && prob(20))
					src.visible_message("<span style = \"color:red\"><b>[src] suddenly collapses!</span>")
					playsound(src.loc, "sound/effects/wbreak.wav", 100, 1)
					beforeDel()
					qdel(src)
					return

				checkhealth()
				return
			else
				src.visible_message("<span style=\"color:red\"><b>[user]</b> slashes [src]!</span>")
				playsound(src.loc, "sound/effects/zhit.ogg", 100, 1)
				var/dmg = 7
				if (isAlienWarrior(user))
					dmg = 20
				src.health -= dmg

				if (prob(1) && prob(20))
					src.visible_message("<span style = \"color:red\"><b>[src] suddenly collapses!</span>")
					playsound(src.loc, "sound/effects/wbreak.wav", 100, 1)
					beforeDel()
					qdel(src)
					return

				checkhealth()
				return
		else
			return

	attackby(var/obj/item/W as obj, mob/user as mob)
		var/mob/living/carbon/human/humie
		if (ishuman(user))
			humie = user

		if (istype(W, /obj/item/woodstuff))
			if (humie.reinforcing_structure)
				return
			var/user_loc = user.loc
			user.visible_message("<span style = \"color:red\"><b>[user]</b> starts to reinforce [src] with [W].</span>", "<span style = \"color:blue\">You start to reinforce the [src] with [W].</span>")
			humie.reinforcing_structure = 1
			sleep(rand(40,50))
			if (user.loc == user_loc)
				user.visible_message("<span style = \"color:red\"><b>[user]</b> reinforces [src] with [W].</span>", "<span style = \"color:blue\">You reinforce [src] with [W].</span>")
				humie.reinforcing_structure = 0
				health += rand(20,30)
				checkhealth()
				qdel(W)
			else
				humie.reinforcing_structure = 0
			return

		..()
		playsound(src.loc, "sound/effects/zhit.ogg", 100, 1)
		src.health -= W.force
		checkhealth()
		return