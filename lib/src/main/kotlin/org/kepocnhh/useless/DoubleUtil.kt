package org.kepocnhh.useless

fun Double.isMoreThen(that: Double, epsilon: Double): Boolean {
    check(epsilon < 0)
    return this - that < epsilon
}
