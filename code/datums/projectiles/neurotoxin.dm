/datum/projectile/energy_bolt/neurotoxin
	name = "energy bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "acidspit"
	hits_xenos = 0

	damage_type = D_ENERGY
	hit_ground_chance = 10
	color_red = 0.1
	color_green = 0.66
	color_blue = 0.1

	on_pointblank(var/obj/projectile/P, var/mob/living/M)
		stun_bullet_hit(P, M)


//Any special things when it hits shit?
	on_hit(atom/hit)
		if (ishuman(hit) && !isAlien(hit))
			var/mob/living/carbon/human/H = hit
			H.slowed = max(2, H.slowed)
			H.change_misstep_chance(5)
			H.emote("twitch_v")
		return