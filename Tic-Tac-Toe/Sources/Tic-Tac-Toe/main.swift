struct Default {
    static let emptySpot: Character = "."
    static let playerOneSymbol: Character = "X"
    static let playerTwoSymbol: Character = "0"
    static let loseValue = -777
    static let winValue = 777
    static let noWinValue = 0
    static let matrixSize = 3
}

struct Point {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init() {
        self.x = 0
        self.y = 0
    }
}
typealias Matrix = [[Character]]

class Game {
    var board: Matrix = Array(repeating: Array(repeating: Default.emptySpot, count: 3), count: 3)
    var steps = 0

    func movesLeft() -> Bool {
        var movesLeft = false
        for row in board {
            if row.contains(Default.emptySpot) {
                movesLeft = true
            }
        }
        return movesLeft
    }
    
    func evaluateState(matrix: Matrix) -> Int {
        let playerOneWinningStreak = [Default.playerOneSymbol,
                                      Default.playerOneSymbol,
                                      Default.playerOneSymbol]
        
        let playerTwoWinningStreak = [Default.playerTwoSymbol,
                                      Default.playerTwoSymbol,
                                      Default.playerTwoSymbol]
        
        for row in matrix {
            if row.elementsEqual(playerOneWinningStreak) {
                return Default.loseValue
            }
            if row.elementsEqual(playerTwoWinningStreak) {
                return Default.winValue
            }
        }

        var cols = [Character]()
        for col in 0..<matrix.count {
            matrix.forEach {
                cols.append($0[col])
            }
            if cols.elementsEqual(playerOneWinningStreak) {
                return Default.loseValue
            }
            if cols.elementsEqual(playerTwoWinningStreak) {
                return Default.winValue
            }
        }

        var primaryDiagonal = [Character]()
        for row in 0..<matrix.count {
        	primaryDiagonal.append(matrix[row][row])
        }
		if primaryDiagonal.elementsEqual(playerOneWinningStreak) {
			return Default.loseValue
		}
		if primaryDiagonal.elementsEqual(playerTwoWinningStreak) {
			return Default.winValue
		}

		var secondaryDiagonal = [Character]()
        for row in 0..<matrix.count {
        	secondaryDiagonal.append(matrix[row][matrix.count - row - 1])
        }
		if secondaryDiagonal.elementsEqual(playerOneWinningStreak) {
			return Default.loseValue
		}
		if secondaryDiagonal.elementsEqual(playerTwoWinningStreak) {
			return Default.winValue
		}

        return Default.noWinValue
    }
    
    func move(index: Int) -> Bool {
    	var index = index - 1
        if index >= 0 && index < Default.matrixSize * 3 {
            let col = index % Default.matrixSize
            let row = Int(index / Default.matrixSize)
            
            if (board[row][col] == Default.emptySpot) {
                board[row][col] = Default.playerOneSymbol
                return true
            }
            return false
        } else {
            return false
        }
    }
    
    func minimax(board: Matrix, depth: Int, isMax: Bool, alpha: Int, beta: Int) -> Int {
        let score = evaluateState(matrix: board)
		print("SCORE: \(score)")
        var alpha = alpha
        var beta = beta
        var board = board
        
        steps += 1
        
        if (score == Default.winValue) {
            return score - depth
        }
        if (score == Default.loseValue) {
            return score + depth
        }
        if (!movesLeft()) {
            return Default.noWinValue
        }
        
        if (isMax) {
            var best = Int.min
            for row in 0..<board.count {
                for col in 0..<board.count {
                    if (board[row][col] == Default.emptySpot) {
                        board[row][col] = Default.playerTwoSymbol
                        
                        best = max(best, minimax(board: board, depth: depth + 1, isMax: !isMax, alpha: alpha, beta: beta))
                        alpha = max(best, alpha)
                        
                        board[row][col] = Default.emptySpot
                        
                        if (beta <= alpha) {
                            return best
                        }
                    }
                }
            }
            return best
        } else {
            var best = Int.max
            for row in 0..<board.count {
                for col in 0..<board.count {
                    if (board[row][col] == Default.emptySpot) {
                        board[row][col] = Default.playerOneSymbol
                        best = min(best, minimax(board: board, depth: depth + 1, isMax: !isMax, alpha: alpha, beta: beta))
                        beta = min(best, beta)
                        board[row][col] = Default.emptySpot
                        
                        if (beta <= alpha) {
                            return best
                        }
                    }
                }
            }
            return best
        }
    }
    
    func bestMove(board: Matrix) -> Point {
        var bestVal = Int.min
        var bestMove = Point(x: -1, y: -1)
        var board = board
        
        for row in 0..<board.count {
            for col in 0..<board.count {
                if (board[row][col] == Default.emptySpot) {
                    board[row][col] = Default.playerTwoSymbol
                    
                    let moveVal = minimax(board: board,
                                          depth: 0,
                                          isMax: false,
                                          alpha: Int.min,
                                          beta: Int.max)
                    print("MOVE VAL: \(moveVal)")
                    board[row][col] = Default.emptySpot
                    
                    if (moveVal > bestVal) {
                        bestVal = moveVal
                        bestMove = Point(x: row, y: col)
                        print("BESTMOVE X: \(bestMove.x) AND BESTMOVE Y: \(bestMove.y)")
                    }
                    
                }
            }
        }
        return bestMove
    }
    
    func play() {
        while (true) {
            guard let input = readLine(), let number = Int(input) else {
            	print("INVALID INPUT")
            	break
            }
            while (!move(index: number)) {
            	print("INVALID INPUT")
            	return
            }
            printResult()
            if (evaluateState(matrix: board) != Default.noWinValue) {
                print("You win! \n")
                print(steps)
                break
            } else if (!movesLeft()) {
                print("Draw \n")
                print(steps)
                break
            }
            
            let pcMove = bestMove(board: board)
            board[pcMove.x][pcMove.y] = Default.playerTwoSymbol
            printResult()
            if (evaluateState(matrix: board) != Default.noWinValue) {
                print("You lose! \n")
                print(steps)
                break
            } else if (!movesLeft()) {
                print("Draw \n")
                print(steps)
                break
            }
        }
    }
    
	func printResult() {
		for row in 0..<Default.matrixSize {
			print("\(board[row])\n")
		}
	}
}

let game = Game()
game.printResult()
game.play()