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

	func peek() -> T? {
		return items.first
	}

	func isEmpty() -> Bool {
		return items.isEmpty
	}
}

class TableNode {

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
    	var wtf = newBoard[blankSpace.x][blankSpace.y]
    	newBoard[blankSpace.x][blankSpace.y] = newBoard[newTile.x][newTile.y]
    	newBoard[newTile.x][newTile.y] = wtf
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

    //   private fun MutableList<Board>.isNewState(element: Board): Boolean {
    //     return !this.map { it.contentDeepEquals(element) }.contains(true)
    // }

    func isBoardNewState(usedBoards: [Board], board: Board) -> Bool {
    	return !usedBoards.contains(board)
    }

    //     fun solveWithAStar(): Pair<Int, Path> {
    //     usedTables.clear()
    //     val priorityQueue = PriorityQueue<TableNode>()
    //     priorityQueue.addAndMarkAsPassed(TableNode(0, listOf<Board>(startMatrix), startMatrix, START_POINT))
    //     while (priorityQueue.isNotEmpty()) {
    //         val currentNode = priorityQueue.peek()
    //         if (currentNode.currentState.manhattanDistance() == 0)
    //             return Pair(currentNode.moves, currentNode.path)
    //         priorityQueue.remove()
    //         Direction.values().forEach { dir ->
    //             val newTile = dir.nextTile(currentNode.blankTile)
    //             if (newTile.isInBounds()) {
    //                 val newBoard = currentNode.currentState.newState(currentNode.blankTile, newTile)
    //                 if (usedTables.isNewState(newBoard)) {
    //                     val path = currentNode.path.toMutableList()
    //                     path.add(newBoard)
    //                     priorityQueue.addAndMarkAsPassed(TableNode((currentNode.moves + 1), path, newBoard, newTile))
    //                 }
    //             }
    //         }
    //     }
    //     return Pair(0, mutableListOf())
    // }

    func solveWithAStar() -> (Int, Path) {
    	usedTables.removeAll()
		var queue = Queue<TableNode>()
		var startTableNode = TableNode()
		usedTables.append(startTableNode.currentState)
		queue.push(startTableNode)
        while (!queue.isEmpty()) {
        	let currentNode = queue.peek()! // Not good unwrapping tho
        	if currentNode.manhattanDistance() == 0 {
        		return (currentNode.moveCount, currentNode.path)
        	}
        	queue.pop()
        	Direction.allCases.forEach {
        		let newBlankSpace = nextBlackSpcae(point: currentNode.blankSpace, direction: $0)
        		if newBlankSpace.inBounds {
        			let newBoard = newState(blankSpace: currentNode.blankSpace, newTile: newBlankSpace, board: currentNode.currentState)
        			if (!usedTables.contains(newBoard)) {
        				var path = currentNode.path
        				path.append(newBoard)
        				let newTableNode = TableNode(moveCount: currentNode.moveCount + 1, path: path, board: newBoard, blankSpace: newBlankSpace)
						usedTables.append(newTableNode.currentState)
						queue.push(newTableNode)
					}
        		}
        	}
        }
        return (0, [])
    }

    //     fun printSolution(solution: Pair<Int, Path>) {
    //     println("Number of steps: ${solution.first}")
    //     solution.second.forEach {
    //         println(Arrays.deepToString(it).replace("],", "],\n"))
    //         println("-----------")
    //         Thread.sleep(2_000)
    //     }
    // }

    func printSolution(_ solution: (steps: Int, path: Path)) {
    	print("Steps: \(solution.steps)\n")
    	solution.path.forEach {
    		print($0)
    	}
    }
}

let puzzle = Puzzle()
puzzle.printSolution(puzzle.solveWithAStar())