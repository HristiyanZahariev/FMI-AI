package dataminning.myPackage

import java.io.File
import kotlin.math.pow
import kotlin.math.sqrt

// MARK: - Extensions

fun MutableList<DataMinning.Iris>.sepalLengthColumn(): List<Double> {
    return this.map { it.sepalLength }
}

fun MutableList<DataMinning.Iris>.sepalWidthColumn(): List<Double> {
    return this.map { it.sepalWidth }
}

fun MutableList<DataMinning.Iris>.petalWidthColumn(): List<Double> {
    return this.map { it.petalWidth }
}

fun MutableList<DataMinning.Iris>.petalLengthColumn(): List<Double> {
    return this.map { it.petalLength }
}

class DataMinning {
    companion object {
        const val TEST_PROPORTION = 0.2
        const val K = 3
    }

    data class Iris(
        var sepalLength: Double,
        var sepalWidth: Double,
        var petalLength: Double,
        var petalWidth: Double,
        val classType: String
    )

    class Point(val x: Double, val y: Double, var type: String? = null) {
        fun distanceFrom(point: Point): Double {
            return sqrt((x - point.x).pow(2) + (y - point.y).pow(2))
        }

        override fun toString(): String {
            return "Point(x=$x, y=$y, type=$type)"
        }

        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as Point

            if (x != other.x) return false
            if (y != other.y) return false
            if (type != other.type) return false

            return true
        }

        override fun hashCode(): Int {
            var result = x.hashCode()
            result = 31 * result + y.hashCode()
            result = 31 * result + (type?.hashCode() ?: 0)
            return result
        }
    }

    val irises = mutableListOf<Iris>()

    // MARK: - Init

    init {
        File("iris.txt")
            .forEachLine {
                irises.add(parseIris(it))
            }
        var currentCol = irises.sepalLengthColumn()
        currentCol.forEachIndexed { index, value -> irises[index].sepalLength = value.nomalize(currentCol) }

        currentCol = irises.sepalWidthColumn()
        currentCol.forEachIndexed { index, value -> irises[index].sepalWidth = value.nomalize(currentCol) }

        currentCol = irises.petalLengthColumn()
        currentCol.forEachIndexed { index, value -> irises[index].petalLength = value.nomalize(currentCol) }

        currentCol = irises.petalWidthColumn()
        currentCol.forEachIndexed { index, value -> irises[index].petalWidth = value.nomalize(currentCol) }
    }

    // MARK: - Private

    private fun parseIris(line: String): Iris {
        val parts = line.split(",")
        return Iris(parts[0].toDouble(), parts[1].toDouble(), parts[2].toDouble(), parts[3].toDouble(), parts[4])
    }

    private fun Double.nomalize(list: List<Double>): Double {
        return (this - list.min()!!) / (list.max()!! - list.min()!!) // FORCE UNWRAPP REMOVE
    }

    // MARK: - Public

    fun classify(point: Point, trainingData: List<Iris>): String {
        val k = sqrt(trainingData.size.toDouble()).toInt()
        val points =
            trainingData.map { Point(it.petalWidth, it.petalLength, it.classType) }.sortedBy { it.distanceFrom(point) }
                .subList(0, k)

        return points.groupBy { it.type }.maxBy { it.value.size }?.key ?: "Nil"
    }

    fun test() {
        val classTypes = irises.groupBy { it.classType }.map { it.key }
        val trainingData =
            irises.groupBy { it.classType }.map { it.value.drop((it.value.size * TEST_PROPORTION).toInt()) }.flatten()
        println("Training data : ${trainingData.size}")

        val testingData = irises.filter { !trainingData.contains(it) }
        println("Testing data: ${testingData.size}")

        val classSize = testingData.groupBy { it.classType }.map { it.value.size }
        var correctTests1 = 0
        var correctTests2 = 0
        var correctTests3 = 0

        testingData.forEach {
            if (classify(
                    Point(it.petalWidth, it.petalLength, it.classType),
                    trainingData
                ) == it.classType
            ) when {
                it.classType == classTypes[0] -> correctTests1++
                it.classType == classTypes[1] -> correctTests2++
                it.classType == classTypes[2] -> correctTests3++
            }
        }
        println("${classTypes[0]} : $correctTests1 / ${classSize[0]}")
        println("${classTypes[1]} : $correctTests2 / ${classSize[1]}")
        println("${classTypes[2]} : $correctTests3 / ${classSize[2]}")
        println((correctTests1 + correctTests2 + correctTests3).toDouble() / testingData.size * 100)
    }

    fun printIrises() {
        irises.forEach { println(it) }
    }

    fun printRanges() {
        irises.groupBy { it.classType }.forEach {
            println("${it.key} [${it.value.minBy { it.petalWidth }} - ${it.value.maxBy { it.petalWidth }}]")
            println("${it.key} [${it.value.minBy { it.petalLength }} - ${it.value.maxBy { it.petalLength }}]")
            println()
        }
    }

    fun nearestMeanIndexFor(point: Point, means: List<Point>): Int {
        return means.indices.minBy { index -> point.distanceFrom(means[index]) } ?: -1
    }

    fun findMean(points: List<Point>): Point {
        return Point(points.map { it.x }.average(), points.map { it.y }.average())
    }

    fun kMeans() {
        val data = irises.map { Point(it.petalWidth, it.petalLength) }.distinct().shuffled()
        var means = data.subList(0, K).toList()

        repeat(200) {
            data.forEach { it.type = nearestMeanIndexFor(it, means).toString() }
            means = data.asSequence()
                .groupBy { it.type }
                .map { group ->
                    Point(group.value.map { it.x }.average(), group.value.map { it.y }.average())
                }
        }


        data.groupBy { it.type }.forEach {
            println(it.key)
            println("[${it.value.minBy { it.x }} - ${it.value.maxBy { it.x }}]")
            println("[${it.value.minBy { it.y }} - ${it.value.maxBy { it.y }}]")
            it.value.forEach { println(it) }
            println()
        }
    }
}

fun main() {
    val dataminning = DataMinning()
    val s = listOf(
        DataMinning.Point(2.0, 4.0),
        DataMinning.Point(4.0, 4.0),
        DataMinning.Point(4.0, 2.0),
        DataMinning.Point(2.0, 2.0)
    )
    println(dataminning.findMean(s))
    dataminning.printIrises()
    dataminning.printRanges()
    dataminning.kMeans()
    dataminning.test()
}