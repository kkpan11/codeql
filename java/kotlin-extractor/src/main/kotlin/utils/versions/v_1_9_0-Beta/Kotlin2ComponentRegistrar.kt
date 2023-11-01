// For ComponentRegistrar
@file:Suppress("DEPRECATION")

package com.github.codeql

import org.jetbrains.kotlin.compiler.plugin.ExperimentalCompilerApi
import org.jetbrains.kotlin.compiler.plugin.ComponentRegistrar

@OptIn(ExperimentalCompilerApi::class)
abstract class Kotlin2ComponentRegistrar : ComponentRegistrar {
    override val supportsK2: Boolean
        get() = true
}
