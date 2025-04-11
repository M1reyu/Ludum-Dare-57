extends Node

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

var playerFunds : int = 0

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
	shopBuyables.Repair : "Repairs all the damage you suffered to your hull.",
	shopBuyables.Refuel : "Refill your gas tank to continue digging and getting around quickly.",	
	shopBuyables.Shield : "Protects you from the next mine you hit.",	
	shopBuyables.Bomb : "Can be placed to blow up everything in the area.\nCAUTION: Vacate the area after use!",
	shopBuyables.Miner : "Can be used to safely dig a space without the worry of a mine blowing up in your face.",
	shopBuyables.HealthUp : "Increases the amount of damage you can take before dying.",
	shopBuyables.SpeedUp : "Increases the strength of your thrusters to move faster.",
	shopBuyables.StrengthUp : "Increases the strength of your drill to mine faster.",
	shopBuyables.TankUp : "Increases the size of your fuel tank to mine longer.",
	shopBuyables.CargoUp : "Increaes the amount of ore you can collect.",
	shopBuyables.Scanner : "Can be used to scan the area to find loot and mines easier",
	shopBuyables.Flag : "Can be used to mark spots that hold mines so you don't dig them up by accident",
	shopBuyables.RangeMine : "Spreads some of your drill damage to adjacent tiles.\nCAUTION: Can trigger mines!"
}

const cooldowns = {
	shopBuyables.Bomb : 3,
	shopBuyables.Scanner : 10
}

class ShopCalc:
	func getCost(key : int, value1 : int = 0, value2 : int = 0, funds : int = 0) -> int:
		match key:
			shopBuyables.Repair:
				return getRepairCost(value1, value2, funds)
			shopBuyables.Refuel:
				return getRefuelCost(value1, value2, funds)
			shopBuyables.Shield:
				return getShieldCost(true if value1 == 0 else false)
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
				return getScannerCost(true if value1 == 0 else false)
			shopBuyables.Flag:
				return getFlagCost(true if value1 == 0 else false)
			shopBuyables.RangeMine:
				return getRangeCost(true if value1 == 0 else false)
		return -1

	func getRepairCost(hp : int, maxHp : int, funds : int) -> int:
		if hp == maxHp: return -1
		var cost : int = (maxHp-hp) * 150
		return int(funds / 150) * 150 if funds < cost else cost
	func getRefuelCost(fuel : int, maxFuel : int, funds : int) -> int:
		if fuel >= maxFuel: return -1
		var cost : int = maxFuel - fuel
		return funds if (funds < cost) else cost
	func getShieldCost(canBuy : bool) -> int:
		return 100 if canBuy else -1
	func getBombCost() -> int:
		return 300
	func getMinerConst() -> int:
		return 1000
	func getHealUpCost(maxHp : int) -> int:
		return maxHp * 500
	func getSpeedUpCost(speed : int) -> int:
		return speed * 2 if speed < 1400 else -1
	func getStrengthUpCost(strength : int) -> int:
		return strength * 750
	func getTankUpCost(tank : int) -> int:
		return tank * 5
	func getCargoUpCost(cargo : int) -> int:
		return 200 + cargo * 50
	func getScannerCost(canBuy : bool) -> int:
		return 2500 if canBuy else -1
	func getFlagCost(canBuy : bool) -> int:
		return 5000 if canBuy else -1
	func getRangeCost(canBuy : bool) -> int:
		return 5000 if canBuy else -1
