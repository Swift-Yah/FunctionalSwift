//: Playground - noun: a place where people can play

import Foundation

typealias Distance = Double

struct Position {
    let x: Double
    let y: Double

    // MARK: Computed variables

    var length: Double {
        return sqrt(x * x + y * y)
    }

    // MARK: Functions

    func within(range: Distance) -> Bool {
        return sqrt(x * x + y * y) <= range
    }

    func minus(_ position: Position) -> Position {
        return Position(x: x - position.x, y: y - position.y)
    }
}

struct Ship {
    let position: Position
    let firingRange: Distance
    let unsafeRange: Distance

    // MARK: Functions

    func canEngage(ship target: Ship) -> Bool {
        let dx = target.position.x - position.x
        let dy = target.position.y - position.y
        let targetDistance = sqrt(dx * dx + dy * dy)

        return targetDistance <= firingRange
    }

    func canSafelyEngage(ship target: Ship) -> Bool {
        let dx = target.position.x - position.x
        let dy = target.position.y - position.y
        let targetDistance = sqrt(dx * dx + dy * dy)

        return targetDistance <= firingRange && targetDistance > unsafeRange
    }

    func canSafelyEngage(ship target: Ship, friendly: Ship) -> Bool {
        let dx = target.position.x - position.x
        let dy = target.position.y - position.y
        let targetDistance = sqrt(dx * dx + dy * dy)
        let friendlyDx = friendly.position.x - target.position.x
        let friendlyDy = friendly.position.y - target.position.y
        let friendlyDistance = sqrt(friendlyDx * friendlyDx + friendlyDy * friendlyDy)

        return targetDistance <= firingRange && targetDistance > unsafeRange && friendlyDistance > unsafeRange
    }

    func canSafelyEngageImproved(ship target: Ship, friendly: Ship) -> Bool {
        let targetDistance = target.position.minus(position).length
        let friendlyDistance = friendly.position.minus(target.position).length

        return targetDistance <= firingRange && targetDistance > unsafeRange && friendlyDistance > unsafeRange
    }
}

typealias Region = (Position) -> Bool

func circle(radius: Distance) -> Region {
    return { point in point.length <= radius }
}

func circle(radius: Distance, center: Position) -> Region {
    return { point in point.minus(center).length <= radius }
}

func shift(_ region: @escaping Region, by offset: Position) -> Region {
    return { point in region(point.minus(offset)) }
}

func invert(_ region: @escaping Region) -> Region {
    return { point in !region(point) }
}

func intersect(_ region: @escaping Region, with other: @escaping Region) -> Region {
    return { point in region(point) && other(point) }
}

func union(_ region: @escaping Region, with other: @escaping Region) -> Region {
    return { point in region(point) || other(point) }
}

func subtract(_ region: @escaping Region, from original: @escaping Region) -> Region {
    return intersect(original, with: invert(region))
}

let shifted = shift(circle(radius: 10), by: Position(x: 5, y: 5))
