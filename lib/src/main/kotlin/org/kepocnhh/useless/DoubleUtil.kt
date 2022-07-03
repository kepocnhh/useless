package org.kepocnhh.useless

/**
 * If epsilon `0.0001` then `0.11113` equal `0.11111`.
 * If epsilon `0.00001` then `0.11113` more than `0.11111`.
 */
fun Double.isMoreThen(that: Double, epsilon: Double): Boolean {
    check(epsilon < 1)
    return this - that > epsilon
}

/**
 * If epsilon `0.0001` then `0.11111` equal `0.11113`.
 * If epsilon `0.00001` then `0.11111` less than `0.11113`.
 */
fun Double.isLessThen(that: Double, epsilon: Double): Boolean {
    check(epsilon < 1)
    return that - this > epsilon
}
