# utils-build
An Ant build script for recursively downloading, building, and installing `Maven` dependencies.

It *cannot* parse the dependencies directly from your `pom.xml`, instead you need to specify them again as specified below. 

## Requirements

* Ant 1.9.4 or later

## Invocation
You can put a `build.xml` file like the one in the next section below into the base dir of your Maven project. Invoke it as specified in order to recursively download, build, and install the dependencies of a Maven project from GitHub repositories.

* `ant`
* `ant -Djdk=PATH/TO/JDK`
* `ant -Dmaven=PATH/TO/MAVEN`
* `ant -Djdk=PATH/TO/JDK -Dmaven=PATH/TO/MAVEN`

## Example Script
			
If started as indicated above, the target `build` will be executed, which first downloads a help script (`dependencyBuilder.xml`). In the `build` target, you specify the main project (in this example, `utils-graphics`) which you want to build, i.e., the project in whose root folder you put the `build.xml` script, as `githubProject` attribute of the `buildWithDependencies` macro.

This macro takes another element, `dependencies`, where can specify nested `dependency` tags defining GitHub projects which need to be installed in order to compile the root project. In this example, there is one such required project, `utils-base`.

Both the `buildWithDependencies` as well as the `dependency` tag accept two attributes `githubProject` and `githubGroup`. Together, they allow you to select and project on GitHub. If `githubGroup` is not specified, it defaults to `optimizationBenchmarking`.
	
The `buildWithDependencies` macro is intended to work recursively, i.e., if the required project, too,
defines a `build.xml` file, this file will be executed with Ant. It may then download and build additional dependencies. A dependency required by multiple projects is only built and installed once. If no
`build.xml` file is specified, the project will be built with Maven.

```
<project basedir="." default="build">
	<import>
		<url url="https://raw.githubusercontent.com/optimizationBenchmarking/utils-build/master/dependencyBuilder.xml" />
	</import>

	<target name="build">
		<sequential>
			<buildWithDependencies githubProject="utils-graphics">
				<dependencies>
					<dependency githubProject="utils-base" />
				</dependencies>
			</buildWithDependencies>
		</sequential>
	</target>
</project>
```