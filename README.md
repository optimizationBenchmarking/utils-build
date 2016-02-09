# utils-build

An `Ant` build script for recursively downloading, building, and installing `Maven` dependencies. This is mainly useful for building projects with online CI tools if there are dependencies.

Say you have two projects, `A` and `B`, where `B` depends on `A`. `Maven` allows you to manage this dependency, so that the build process of `B` will download the latest published `jar` of project `A` when needed. However, when working at both `A` and `B`, we maybe do not want to publish an artifact for each commit. In this case, it might be useful if the latest *commit* of project `A` was used during the building process of project `B`. `Maven` cannot do that, it looks always for published *artifacts*. However, for continuous integration tools, especially for those tools which do the builds for us automatically whenever we commit, *artifacts* might be to coarse grained and we would sometimes use the latest sources instead.
  
This small utility project provides an `Ant` script which closes this gap: You can specify an `Ant` `build.xml` next to your `Maven` `pom.xml`. In this `build.xml`, you specify the projects which should be downloaded (from GitHub), built, and installed into the local `Maven` repository prior to building the actual project. We would thus put such a file into the root folder of project `B` and specify there that (the latest commit of the source code of) project `A` should first be downloaded, built, and installed before `B` is built.

By using `Ant`, we get somewhat platform independent: The same scripts work under Linux and Windows. However, we may need to install `Ant` first or update an existing installation (see below). For this, under Linux, I provide a BASH script as well (`antWebInstallerLinux.sh`).

It *cannot* parse the dependencies directly from your `pom.xml`, instead you need to specify them again as specified below. 

## 1. Requirements

* [Apache `Ant`](http://ant.apache.org/bindownload.cgi) 1.9.4 or later
* [Maven](http://maven.apache.org/) version 3.0 and above

### 1.1. Under Linux

Some of the available CI systems (well, basically all) and Linux configuration ship with an older version of `Ant` and using their `sudo apt-get install` won't install the required version either. Therefore, we provide the script [antWebInstallerLinux.sh](https://raw.githubusercontent.com/optimizationBenchmarking/utils-build/master/antWebInstallerLinux.sh) which can download and install the required version of `Ant`. You can use it as follows in your builds:

```
wget "https://raw.githubusercontent.com/optimizationBenchmarking/utils-build/master/antWebInstallerLinux.sh"
chmod 755 antWebInstallerLinux.sh
sudo ./antWebInstallerLinux.sh
```

Some CI systems (such as [CodeShip](https://codeship.com/)) do not grant you `sudo`. In that case, you can run `./antWebInstallerLinux.sh --haveSudo=false`. The script will then simply install `Ant` into the current folder and create a symbolic link to the executable.

Sometimes ([shippable](https://app.shippable.com), [snap-ci](https://snap-ci.com), [drone io](https://drone.io)) it may cause problems to uninstall an existing `Ant` installation. In this case, you can run `./antWebInstallerLinux.sh --purgeAnt=false`. A best attempt will be made to redirect all `Ant` action to the new installation.

### 1.2. Under Windows

Under Windows, you can use [chocolately](https://chocolatey.org/) to install all required software. Once you have `chocolately` on your system, you can install both `Maven` and `Ant`, update `PATH` and then simply run `ant` in the build folder.

```
cinst maven -Version 3.2.5
cinst ant -i -Version 1.9.6
SET PATH=C:\ProgramData\chocolatey\lib\ant\apache-ant-1.9.6\bin;C:\bin\apache-maven-3.2.5\bin;%JAVA_HOME%\bin;%PATH%
```

Under [AppVeyor(https://ci.appveyor.com/), you can add the following lines to the `install` section of your `appveyor.yml`.

```
ps: if(!(Test-Path -Path 'C:\bin\apache-maven-3.2.5\' )){ cinst maven -Version 3.2.5 }
ps: if(!(Test-Path -Path 'C:\ProgramData\chocolatey\lib\ant\apache-ant-1.9.6\' )){ cinst ant -i -Version 1.9.6 }
cmd: SET PATH=C:\ProgramData\chocolatey\lib\ant\apache-ant-1.9.6\bin;C:\bin\apache-maven-3.2.5\bin;%JAVA_HOME%\bin;%PATH%
```
  
### 1.3. Examples

You can check the build settings of our project [utils-graphics](https://github.com/optimizationBenchmarking/utils-graphics) as an example of how to use this with different CI systems. You can find the config files of the CI systems in the project root folder and/or click the build badges to get to systems which require manual configurations.

## 2. Invocation
You can put a `build.xml` file like the one in the next section below into the base directory of your `Maven` project. Invoke it as specified in order to recursively download, build, and install the dependencies of a `Maven` project from GitHub repositories.

* `ant` (auto-detect JDK and Maven, run tests for root project)
* `ant -Djdk=PATH/TO/JDK` (to specify the path to the JDK)
* `ant -Dmaven=PATH/TO/MAVEN` (to specify the path to `Maven`)
* `ant -DskipTests=true` (to skip the tests also of the root project)
* `ant -DpassToMaven=XXXX` (pass `XXX` as "`-DXXX`" to `Maven` (including recursive builds))
* any combination of the above, such as `ant -Djdk=PATH/TO/JDK -Dmaven=PATH/TO/MAVEN`

## 3. Example Script
			
If started as indicated above, the target `build` will be executed, which first downloads a help script (`dependencyBuilder.xml`). In the `build` target, you specify the main project (in this example, `utils-graphics`) which you want to build, i.e., the project in whose root folder you put the `build.xml` script, as `githubProject` attribute of the `buildWithDependencies` macro.

This macro takes another element, `dependencies`, where can specify nested `dependency` tags defining GitHub projects which need to be installed in order to compile the root project. In this example, there is one such required project, `utils-base`.

Both the `buildWithDependencies` as well as the `dependency` tag accept two attributes `githubProject` and `githubGroup`. Together, they allow you to select and project on GitHub. If `githubGroup` is not specified, it defaults to `optimizationBenchmarking`.
	
The `buildWithDependencies` macro is intended to work recursively, i.e., if the required project, too,
defines a `build.xml` file, this file will be executed with `Ant`. It may then download and build additional dependencies. A dependency required by multiple projects is only built and installed once. If no
`build.xml` file is specified, the project will be built with `Maven`.

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