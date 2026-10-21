--!strict
export type Point = { x: number, z: number }
export type Segment = {
	ax: number,
	az: number,
	bx: number,
	bz: number,
	team: number,
	radius: number,
	ballId: number?,
	t0: number?,
	t1: number?,
}
export type WeaponState = {
	spin: number,
	hp: number,
	angle: number,
	omega: number,
	poweredUntil: number,
	slowUntil: number,
	guardReadyTick: number,
	castTick: number,
	castX: number,
	castZ: number,
	castAngle: number,
	castCancelled: boolean,
}
export type Shape = {
	ax: number,
	az: number,
	bx: number,
	bz: number,
	radius: number,
	team: number,
	strength: number,
	drain: boolean?,
}
export type Ball = {
	id: number,
	userId: number,
	team: number,
	kitId: string,
	x: number,
	z: number,
	vx: number,
	vz: number,
	speed: number,
	brush: number,
	nextAbilityTick: number,
	effectEndTick: number,
	lastDx: number,
	lastDz: number,
	weapon: WeaponState?,
	hitAt: { [number]: number }?,
	touchAt: { [number]: number }?,
	healReadyTick: number?,
}
export type Board = { q: buffer, counts: { number }, version: number }
export type Change = { index: number, q: number }
export type Command = {
	id: number,
	kind: string,
	matchId: string,
	roundId: number,
	generation: number,
	kitId: string?,
	appearance: string?,
	angle: number?,
	wildcard: boolean?,
}
local Types = {}
return table.freeze(Types)
