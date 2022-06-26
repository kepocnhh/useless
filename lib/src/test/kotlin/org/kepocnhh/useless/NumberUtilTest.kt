package org.kepocnhh.useless

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

internal class NumberUtilTest {
    @Test
    fun getZeroTest() {
        assertEquals(0, NumberUtil.getZero())
    }

    @Test
    fun getOneTest() {
        assertEquals(1, NumberUtil.getOne())
    }

    @Test
    fun getTwoTest() {
        assertEquals(2, NumberUtil.getTwo())
    }

    @Test
    fun isZeroTest() {
        assertTrue(NumberUtil.isZero(0))
        assertFalse(NumberUtil.isZero(1))
    }

    @Test
    fun isOneTest() {
    }
}
