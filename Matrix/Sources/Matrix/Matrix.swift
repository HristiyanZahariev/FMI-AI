private struct Default {
	static let matrixSize: Int = 6
	static let accessiblePointSymbol = 1
    static let unaccessiblePointSymbol = 0
    static let startPoint = Point()
    static let endPoint = Point(x: 2, y: 5)
    static let teleportEndPoint = Point(x: 2, y: 4)
    static let teleportStartPoint = Point(x: 1, y: 1)
}

struct Queue<T> {
    var items:[T] = []
    
    mutating func push(_ element: T) {
        items.append(element)
    }
    
    mutating func pop() -> T? {
        if items.isEmpty {
            return nil
        }
        else {
            let tempElement = items.first
            items.remove(at: 0)
            return tempElement
        }
    }

    func isEmpty() -> Bool {
    	return items.isEmpty
    }
    
}

struct Point: Equatable {
	let x: Int
	let y: Int

	init(x: Int, y: Int) {
		self.x = x
		self.y = y
	}

	init(startPoint: Int) {
		x = startPoint
		y = startPoint
	}

	init() {
		x = 0
		y = 0
	}

	static func ==(lhs: Point, rhs: Point) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}

extension Point {
	var inBounds: Bool {
		return (0...Default.matrixSize).contains(x) && (0...Default.matrixSize).contains(y)
	}
}

typealias Path = [Point]
typealias Node = (path: Path, point: Point)

class Matrix {
	private let field: [[Int]] = [[1, 1, 0, 1, 1, 1], 
								  [1, 2, 0, 0, 1, 1],
								  [1, 1, 1, 1, 2, 1],
								  [1, 1, 1, 1, 1, 1], 
								  [1, 0, 0, 1, 1, 1], 
								  [1, 1, 1, 1, 1, 1]]

	enum Direction: CaseIterable {
		case left
		case right
		case up
		case down
	}

	private var visitedPoints = [Point]()

	private func isPointAccessible(x: Int, y: Int) -> Bool {
        return field[x][y] != Default.unaccessiblePointSymbol
    }

    private func isVisited(point: Point) -> Bool {
    	return visitedPoints.contains(point)
    }

    private func add(node: Node) {
    	visitedPoints.append(node.point)
    }

    private func nextPosition(point: Point, visited: [Point], direction: Direction) -> Point {
		if (point == Default.teleportStartPoint) && (!visited.contains(Default.teleportEndPoint)) {
			return Default.teleportEndPoint
		}
		else if (point == Default.teleportEndPoint) && (!visited.contains(Default.teleportStartPoint)) {
			return Default.teleportStartPoint
		}
		else {
			var x = 0;
			var y = 0;
			switch direction {
				case .left:
					x = point.x
					y = point.y - 1
				case .right:
					x = point.x
					y = point.y + 1
				case .up:
					x = point.x - 1
					y = point.y
				case .down:
					x = point.x + 1
					y = point.y
			}
			return Point(x: x, y: y)
		}
    }

    func findShortestPath() -> (Int, Path) {
    	var queue = Queue<Node>()
    	let startNode = Node(path: [Default.startPoint], point: Default.startPoint)
		queue.push(startNode)
		add(node: startNode)
		while (!queue.isEmpty()) {
			let element = queue.items.first! // Forcein here. Not a good idea tbh
			if (element.point == Default.endPoint) {
				return (element.path.count - 1, element.path)
			}
			queue.pop()
			Direction.allCases.forEach {
				let nextPosition = self.nextPosition(point: element.point, visited: visitedPoints, direction: $0)
                if (nextPosition.inBounds && isPointAccessible(x: nextPosition.x, y: nextPosition.y) && !isVisited(point: nextPosition)) {
                    var path = element.path
                    path.append(nextPosition)
					queue.push(Node(path, nextPosition))
					add(node: Node(path, nextPosition))
                }
			}
		}
		return (0, [])
    }
}