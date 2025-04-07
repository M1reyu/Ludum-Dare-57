enum shopBuyables {
	Repair = 1,
	Refuel = 2,
	Shield = 3,
	Bomb = 4,
	Miner = 5,
	HealthUp = 6,
	SpeedUp = 7,
	StrengthUp = 8,
	TankUp = 9,
	CargoUp = 10,
	Scanner = 11,
	Flag = 12,
	RangeMine = 13
}

const itemNames = {
	shopBuyables.Repair : "Repair",
	shopBuyables.Refuel : "Refuel",	
	shopBuyables.Shield : "Shield",	
	shopBuyables.Bomb : "Dynamite",
	shopBuyables.Miner : "Remote Miner",
	shopBuyables.HealthUp : "Hull Upgrade",
	shopBuyables.SpeedUp : "Thruster Upgrade",
	shopBuyables.StrengthUp : "Drill Upgrade",
	shopBuyables.TankUp : "Tank Upgrade",
	shopBuyables.CargoUp : "Cargo Upgrade",
	shopBuyables.Scanner : "Scanner",
	shopBuyables.Flag : "Safety Protocol",
	shopBuyables.RangeMine : "Drill Spread"
}

const itemInfos = {
	shopBuyables.Repair : "Repairs all the Damage you suffered to your hull.",
	shopBuyables.Refuel : "Refill your gas tank to continue working.",	
	shopBuyables.Shield : "Protects you from the next Mine you hit.",	
	shopBuyables.Bomb : "Can be placed to blow up everything in the area.\nCAUTION: Vacate the are after use!",
	shopBuyables.Miner : "Can be used to safely dig a space without the worry of a mine blowing up in your face.",
	shopBuyables.HealthUp : "Increases the amount of damage you can take before dieing.",
	shopBuyables.SpeedUp : "Increases the strength of your thrusters so you can move faster.",
	shopBuyables.StrengthUp : "Increases the strength of your drill to mine faster.",
	shopBuyables.TankUp : "Increases the size of your fuel tank so you can mine longer.",
	shopBuyables.CargoUp : "Increaes the amount of ore you can collect.",
	shopBuyables.Scanner : "Can be used to scan the area to find loot or mines easier",
	shopBuyables.Flag : "Can be used to mark spots that hold mines so you don't dig them up on accident",
	shopBuyables.RangeMine : "Spreads some of you drill strength to adjacent tiles.\nCAUTION: Will trigger mines!"
}

class ShopCalc:
	func getCost(key : int, value1 : int = 0, value2 : int = 0) -> int:
		match key:
			shopBuyables.Repair:
				return getRepairCost(value1, value2)
			shopBuyables.Refuel:
				return getRefuelCost(value1, value2)
			shopBuyables.Shield:
				return getShieldCost()
			shopBuyables.Bomb:
				return getBombCost()
			shopBuyables.Miner:
				return getMinerConst()
			shopBuyables.HealthUp:
				return getHealUpCost(value1)
			shopBuyables.SpeedUp:
				return getSpeedUpCost(value1)
			shopBuyables.StrengthUp:
				return getStrengthUpCost(value1)
			shopBuyables.TankUp:
				return getTankUpCost(value1)
			shopBuyables.CargoUp:
				return getCargoUpCost(value1)
			shopBuyables.Scanner:
				return getScannerCost()
			shopBuyables.Flag:
				return getFlagCost()
			shopBuyables.RangeMine:
				return getRangeCost()
		return 0

	func getRepairCost(hp : int, maxHp : int) -> int:
		return (maxHp-hp) * 150
	func getRefuelCost(fuel : int, maxFuel : int) -> int:
		return maxFuel - fuel
	func getShieldCost() -> int:
		return 100
	func getBombCost() -> int:
		return 300
	func getMinerConst() -> int:
		return 1000
	func getHealUpCost(maxHp : int) -> int:
		return maxHp * 500
	func getSpeedUpCost(speed : int) -> int:
		return speed * 2
	func getStrengthUpCost(strength : int) -> int:
		return strength * 750
	func getTankUpCost(tank : int) -> int:
		return tank * 5
	func getCargoUpCost(cargo : int) -> int:
		return 200 + cargo * 50
	func getScannerCost() -> int:
		return 2500
	func getFlagCost() -> int:
		return 5000
	func getRangeCost() -> int:
		return 5000
