package org.kepocnhh.useless

import org.junit.Test
import org.junit.Assert.assertEquals

class NumberUtilTest {
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
}
