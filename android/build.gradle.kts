rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
    afterEvaluate { if (it.hasProperty("packageForR") && it.properties["packageForR"] == "androidx.compose.material3.demos") it.extensions.configure(com.android.build.gradle.BaseExtension::class.java) { namespace = "androidx.compose.material3.demos" } }
}
tasks.register("clean", Delete::class) { delete(rootProject.buildDir) }
