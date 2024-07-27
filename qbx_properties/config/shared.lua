ShellUndergroundOffset = 50.0

function CalculateOffsetCoords(propertyCoords, offset)
    return vec3(propertyCoords.x + offset.x, propertyCoords.y + offset.y, (propertyCoords.z - ShellUndergroundOffset) + offset.z)
end

function CreateBlip(apartmentCoords, label)
	local blip = AddBlipForCoord(apartmentCoords.x, apartmentCoords.y, apartmentCoords.z)
	SetBlipSprite(blip, 40)
	SetBlipAsShortRange(blip, true)
	SetBlipScale(blip, 0.8)
	SetBlipColour(blip, 2)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(label)
	EndTextCommandSetBlipName(blip)
	return blip
end

ApartmentOptions = {
    {
        interior = 'DellPerroHeightsApt4',
        label = 'Del Perro Heights Apt',
        description = 'Enjoy ocean views far away from tourists and bums on Del Perro Beach.',
        enter = vec3(-1447.35, -537.84, 34.74)
    },
    {
        interior = 'DellPerroHeightsApt7',
        label = 'Del Perro Heights Apt',
        description = 'Luxury Del Perro Heights apartment complex! For all you voyeurs out there!',
        enter = vec3(-1447.35, -537.84, 34.74)
    },
    {
        interior = '4IntegrityWayApt28',
        label = '4 Integrity Way Apt',
        description = 'This is such an promosing neighborhood, you can literally see the construction from your window!',
        enter = vec3(-59.4, -616.29, 37.36)
    },
    {
        interior = '4IntegrityWayApt30',
        label = '4 Integrity Way Apt',
        description = 'An apartment so expansive, all your friends will immediately know how much you paid for it.',
        enter = vec3(-47.52, -585.86, 37.95)
    },
    {
        interior = 'RichardMajesticApt2',
        label = 'Richard Majestic Apt',
        description = 'This breathtaking luxury condo is a stone\'s throw from AKAN Records and a Sperm Donor Clinic.',
        enter = vec3(-936.15, -378.91, 38.96)
    },
    {
        interior = 'TinselTowersApt42',
        label = 'Tinsel Towers Apt',
        description = 'A picture-perfect lateral living experience in one of Los Santos most sought-after tower blocks.',
        enter = vec3(-614.58, 46.52, 43.59)
    },
}

Interiors = {
	[`furnitured_midapart`] = {
		exit = vec3(1.46, -10.33, 0.0),
		clothing = vec3(6.03, 9.3, 0.0),
		stash = vec3(6.91, 3.94, 0.0),
		logout = vec3(4.07, 7.89, 0.0)
	},
	['4IntegrityWayApt28'] = {
		exit = vec3(-31.56, -595.06, 80.03),
		clothing = vec3(-39.27, -589.39, 78.83),
		stash = vec3(-11.77, -599.31, 79.43),
		logout = vec3(-37.19, -583.69, 78.83)
	},
	['4IntegrityWayApt30'] = {
		exit = vec3(-16.89, -589.85, 90.11),
		clothing = vec3(-37.75, -582.12, 83.91),
		stash = vec3(-28.19, -588.47, 90.12),
		logout = vec3(-37.34, -578.04, 83.91)
	},
    ['DellPerroHeightsApt4'] = {
        exit = vec3(-1452.17, -540.72, 74.04),
        clothing = vec3(-1449.3, -550.01, 72.84),
        stash = vec3(-1465.87, -525.91, 73.44),
        logout = vec3(-1453.99, -553.24, 72.84)
    },
	['DellPerroHeightsApt7'] = {
		exit = vec3(-1450.44, -523.58, 56.93),
		clothing = vec3(-1466.72, -538.45, 50.72),
		stash = vec3(-1458.15, -532.07, 56.94),
		logout = vec3(-1471.85, -533.62, 50.72)
	},
	['RichardMajesticApt2'] = {
		exit = vec3(-912.44, -365.01, 114.27),
		clothing = vec3(-902.92, -363.37, 113.07),
		stash = vec3(-928.93, -376.51, 113.67),
		logout = vec3(-900.29, -368.46, 113.07)
	},
	['TinselTowersApt42'] = {
		exit = vec3(-602.89, 58.99, 98.2),
		clothing = vec3(-593.71, 56.08, 97.0),
		stash = vec3(-622.84, 56.16, 97.6),
		logout = vec3(-593.71, 50.32, 97.0)
	},
	['GTAOHouseMid1'] = {
		exit = vec3(346.51, -1013.14, -99.2),
		clothing = vec3(351.23, -993.54, -99.2),
		stash = vec3(351.93, -998.75, -99.2),
		logout = vec3(349.24, -994.81, -99.2)
	},
	['GTAOHouseLow1'] = {
		exit = vec3(266.11, -1007.6, -101.01),
		clothing = vec3(259.8, -1003.94, -99.01),
		stash = vec3(265.93, -999.43, -99.01),
		logout = vec3(262.99, -1003.02, -99.01)
	},
}