# utils-build

An `Ant` build script for recursively downloading, building, and installing `Maven` dependencies. This is an attempt to be somewhat platform-independent, i.e., to allow builds with dependencies to happen both under Windows and Linux.

It *cannot* parse the dependencies directly from your `pom.xml`, instead you need to specify them again as specified below. 

## Requirements

* [Apache `Ant`](http://ant.apache.org/bindownload.cgi) 1.9.4 or later
* Maven version 3.0 and above

### Under Linux

Some of the available CI systems (well, basically all) and Linux configuration ship with an older version of `Ant` and using their `sudo apt-get install` won't install the required version either. Therefore, we provide the script [antWebInstallerLinux.sh](https://raw.githubusercontent.com/optimizationBenchmarking/utils-build/master/antWebInstallerLinux.sh) which can download and install the required version of `Ant`. You can use it as follows in your builds:

```
wget "https://raw.githubusercontent.com/optimizationBenchmarking/utils-build/master/antWebInstallerLinux.sh"
chmod 755 antWebInstallerLinux.sh
sudo ./antWebInstallerLinux.sh
```

Some CI systems (such as [CodeShip](https://codeship.com/)) do not grant you `sudo`. In that case, you can run `./antWebInstallerLinux.sh --haveSudo=false`. The script will then simply install `Ant` into the current folder and create a symbolic link to the executable.

Sometimes ([shippable](https://app.shippable.com), [snap-ci](https://snap-ci.com)) it may cause problems to uninstall an existing `Ant` installation. In this case, you can run `./antWebInstallerLinux.sh --purgeAnt=false`. A best attempt will be made to redirect all `Ant` action to the new installation.

### Under Windows

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
  
### Examples

You can check the build settings of our project [utils-graphics](https://github.com/optimizationBenchmarking/utils-graphics) as an example of how to use this with different CI systems. You can find the config files of the CI systems in the project root folder and/or click the build badges to get to systems which require manual configurations.

## Invocation
You can put a `build.xml` file like the one in the next section below into the base directory of your `Maven` project. Invoke it as specified in order to recursively download, build, and install the dependencies of a `Maven` project from GitHub repositories.

* `ant`
* `ant -Djdk=PATH/TO/JDK`
* `ant -Dmaven=PATH/TO/MAVEN`
* `ant -Djdk=PATH/TO/JDK -Dmaven=PATH/TO/MAVEN`

## Example Script
			
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