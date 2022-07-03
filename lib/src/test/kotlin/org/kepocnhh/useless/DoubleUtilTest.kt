package org.kepocnhh.useless

import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

internal class DoubleUtilTest {
    @Test
    fun isMoreThenTest() {
        val a = 0.11113
        val b = 0.11111
        assertFalse("equals", a.isMoreThen(b, epsilon = 0.0001))
        assertTrue("more", a.isMoreThen(b, epsilon = 0.00001))
        assertThrows(IllegalStateException::class.java) {
            a.isMoreThen(b, epsilon = 1.0)
        }
    }

    @Test
    fun isLessThenTest() {
        val a = 0.11111
        val b = 0.11113
        assertFalse("equals", a.isLessThen(b, epsilon = 0.0001))
        assertTrue("less", a.isLessThen(b, epsilon = 0.00001))
        assertThrows(IllegalStateException::class.java) {
            a.isLessThen(b, epsilon = 1.0)
        }
    }
}
