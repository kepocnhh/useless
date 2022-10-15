package org.kepocnhh.useless

/**
 * Test documentation class.
 */
object NumberUtil {
    private const val ZERO = 0
    private const val ONE = 1
    private const val TWO = 2

    /**
     * Test documentation method.
     */
    fun getZero (): Int {
        return ZERO
    }

    /**
     * If you suddenly need the number one.
     */
    fun getOne(): Int {
        return ONE
    }

    /**
     * Number 2.
     */
    fun getTwo(): Int {
        return TWO
    }

    /**
     * Check is zero.
     */
    fun isZero(value: Int): Boolean {
        return value == ZERO
    }

    /**
     * one?
     */
    fun isOne(value: Int): Boolean {
        return value == ONE
    }
}
