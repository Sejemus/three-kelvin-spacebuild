local addons = {	104694154,	106904944,	107155115,	104482086,	104771157,	104815552,	108176967,	173482196,	160250458,	161770512,	163806212,	106516163,	148070174,	249892967,}local maps = {	'sb_forlorn_sb3_r3'	= 131473300,	'sb_gooniverse'		= 104542705,	'sb_twinsuns_fixed'	= 175515708,}for _,addon in pairs(addons) do	resource.AddWorkshop(addon)endresource.AddWorkshop(maps[game.GetMap()])