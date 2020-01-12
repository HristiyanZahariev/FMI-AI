import Foundation

typealias Board = [[Int]]
typealias Path = [Board]

private struct Default {
	static let matrixSize: Int = 3
	static let startPoint = BlankSpace(x: 2, y: 1)
	static let startMatrix: Board = [[6, 5, 3], 
									 [2, 4, 8], 
									 [7, 0, 1]]
	static let goalMatrix: Board = [[1, 2, 3], [4, 5, 6], [7, 8, 0]]
}

struct BlankSpace: Equatable {
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

	static func ==(lhs: BlankSpace, rhs: BlankSpace) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}

extension BlankSpace {
	var inBounds: Bool {
		return (0..<Default.matrixSize).contains(x) && (0..<Default.matrixSize).contains(y)
	}
}

class TableNode: Equatable, Comparable {

	let moveCount: Int
	let path: Path
	let currentState: Board
	let blankSpace: BlankSpace

	var sum: Int {
		return moveCount + manhattanDistance()
	}

	init() {
		moveCount = 0
		path = [Default.startMatrix]
		currentState = Default.startMatrix
		blankSpace = Default.startPoint
	}

	init(moveCount: Int, path: Path, board: Board, blankSpace: BlankSpace) {
		self.moveCount = moveCount
		self.path = path
		self.currentState = board
		self.blankSpace = blankSpace
	}

	func manhattanDistance() -> Int {
		var distanceSum = 0
		for row in 0..<3 {
			for col in 0..<3 {
				let value = currentState[row][col]
				if value != 0 {
					let dx = row - ((value - 1) / 3) 
					let dy = col - ((value - 1) % 3)
					distanceSum += abs(dx) + abs(dy)
				}
			}
		}
		return distanceSum
	}
    
    static func ==(lhs: TableNode, rhs: TableNode) -> Bool {
        return lhs.sum == rhs.sum
    }
    
    static func < (lhs: TableNode, rhs: TableNode) -> Bool {
        return lhs.sum < rhs.sum
    }
}

class Puzzle {
	enum Direction: CaseIterable {
		case left
		case right
		case up
		case down
	}
	private var usedTables = [Board]()

    private func newState(blankSpace: BlankSpace, newTile: BlankSpace, board: Board) -> Board {
    	var newBoard = board
    	let blankSpaceFromBoard = newBoard[blankSpace.x][blankSpace.y]
    	newBoard[blankSpace.x][blankSpace.y] = newBoard[newTile.x][newTile.y]
    	newBoard[newTile.x][newTile.y] = blankSpaceFromBoard
    	return newBoard 
    }

    private func misplacedTiles(board: Board) -> Int {
    	var result = 0
    	for row in 0...Default.matrixSize {
    		for col in 0...Default.matrixSize {
    			if board[row][col] != Default.goalMatrix[row][col] {
    				result += 1
    			}
    		}
    	}
    	return result - 1
    }

	private func nextBlackSpcae(point: BlankSpace, direction: Direction) -> BlankSpace {
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
		return BlankSpace(x: x, y: y)
    }

    func isBoardNewState(usedBoards: [Board], board: Board) -> Bool {
    	return !usedBoards.contains(board)
    }

    func solveWithAStar() -> (Int, Path) {
    	usedTables.removeAll()
        var queue = PriorityQueue<TableNode>(sort: <)
        let startTableNode = TableNode()
		usedTables.append(startTableNode.currentState)
		queue.enqueue(startTableNode)
        while (!queue.isEmpty) {
        	let currentNode = queue.peek()! // Not good unwrapping tho
        	if currentNode.manhattanDistance() == 0 {
        		return (currentNode.moveCount, currentNode.path)
        	}
        	queue.dequeue()
        	Direction.allCases.forEach {
        		let newBlankSpace = nextBlackSpcae(point: currentNode.blankSpace, direction: $0)
        		if newBlankSpace.inBounds {
        			let newBoard = newState(blankSpace: currentNode.blankSpace, newTile: newBlankSpace, board: currentNode.currentState)
        			if (!usedTables.contains(newBoard)) {
        				var path = currentNode.path
        				path.append(newBoard)
                        print("Move Count: \(currentNode.moveCount)")
        				let newTableNode = TableNode(moveCount: currentNode.moveCount + 1, path: path, board: newBoard, blankSpace: newBlankSpace)
						usedTables.append(newTableNode.currentState)
						queue.enqueue(newTableNode)
					}
        		}
        	}
        }
        return (0, [])
    }
    
    func printSolution(_ solution: (steps: Int, path: Path)) {
    	print("Steps: \(solution.steps)\n")
    	solution.path.forEach {
            $0.forEach { tripple in
                print(tripple)
            }
            print("\n")
            Thread.sleep(forTimeInterval: 2)
    	}
    }
}

let puzzle = Puzzle()
puzzle.printSolution(puzzle.solveWithAStar())
