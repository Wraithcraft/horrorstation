
/datum/targetable/xenomorph/build_with_resin
	name = "Resin Build"
	desc = "Build various resin objects. You must have resin in your hands to do this. Drones and Queens build faster than other castes."
	icon_state = "bresin"
	cooldown = 0
	targeted = 0
	target_anything = 0
	restricted_area_check = 2

	cast(atom/target)
		if (..())
			return 1


		var/mob/living/carbon/human/C = holder.owner

		if (!C.loc || !istype(C.loc, /turf/simulated/floor))
			return 0

		if (!istype(C.equipped(), /obj/item/xeno/resin))
			boutput(C, "<span style = \"color:red\"><B>You require resin in your active hand to build.</span></B>")
			return 0

		if (locate(/obj/xeno/hive) in C.loc)
			for (var/obj/xeno/hive/h in C.loc)
				if (h.density || istype(h, /obj/xeno/hive/resin_pile) || istype(h, /obj/xeno/hive/nest))
					boutput(C, "<span style = \"color:red\"><B>There is already a resin object here.</span></B>")
					return 0

		var/obj/xeno/hive/toBuild

		var/buildlist = list("Wall", "Membrane", "Nest")

		if (C:xcreate_plasma_node())
			buildlist += "Plasma Pool"

		var/buildwhat

		if (!C:xcreate_plasma_node())
			buildwhat = alert(C, "What do you want to build?", "", "Wall", "Membrane", "Nest")
		else
			buildwhat = input(C, "What do you want to build?", "") in list ("Wall", "Membrane", "Nest"/*, "Plasma Pool"*/)

		switch (buildwhat)
			if ("Wall")
				toBuild = /obj/xeno/hive/wall
			if ("Membrane")
				toBuild = /obj/xeno/hive/membrane
			if ("Nest")
				toBuild = /obj/xeno/hive/nest
			if ("Plasma Pool")
				toBuild = /obj/xeno/hive/plasma_pool

	//	if (!C.is_in_hands(/obj/item/xeno/resin))
		if (!istype(C.equipped(), /obj/item/xeno/resin))
			if (buildwhat != "Plasma Pool")
				boutput(C, "<span style = \"color:red\"><B>You require resin in your active hand to build.</span></B>")
				return 0

		else

			var/obj/item/xeno/resin/r = C.equipped()
			r.stacked--
			if (r.stacked < 1)
				C.drop_item()
				qdel(r)


		var/cloc = C.loc

		boutput(C, "<span style=\"color:blue\"><B>You start building the [buildwhat]...</B></span>")

		sleep(40 - (istype(C.mutantrace, /datum/mutantrace/xenomorph/drone) ? 25 : 0))

		if (cloc == C.loc)
			new toBuild(C.loc)

			boutput(C, "<span style=\"color:blue\"><B>You finish building the [buildwhat].</B></span>")

	//	playsound(C.loc, 'vomitsound.ogg', 100, 1)
		return 0
