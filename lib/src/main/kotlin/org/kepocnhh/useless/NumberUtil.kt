package org.kepocnhh.useless

object NumberUtil {
    private const val ZERO = 0
    private const val ONE = 1
    private const val TWO = 2

    fun getZero(): Int {
        return ZERO
    }

    fun getOne(): Int {
        return ONE
    }

    fun getTwo(): Int {
        return TWO
    }

    fun isZero(value: Int): Boolean {
        return value == ZERO
    }

    fun isOne(value: Int): Boolean {
        return value == ONE
    }
}
