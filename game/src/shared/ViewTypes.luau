--!strict
export type Seat = {
	id: number,
	userId: number,
	team: number,
	name: string,
	kitId: string?,
	appearance: string?,
	angle: number?,
	pickLocked: boolean,
	aimLocked: boolean,
	x: number,
	z: number,
}
export type State = {
	id: string,
	phase: string,
	generation: number,
	roundId: number,
	roundNumber: number,
	deadline: number,
	tick: number,
	points2: { number },
	winner: number,
	reason: string,
	practice: boolean,
	seats: { Seat },
	offer: { string },
	wildcardUsed: boolean,
	localKit: string,
	localAngle: number,
	hold: number,
	holdLeader: number,
	persistence: string,
	rematchRequested: boolean?,
}
local ViewTypes = {}
return table.freeze(ViewTypes)
