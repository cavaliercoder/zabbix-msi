## Zabbix Agent MSI Installer

### Overview
This project contains the files required to build a functional Microsoft Windows MSI package for the deployment of the Zabbix Windows Agent on both x64 and x86 platforms.
Both platforms are built from the same project file and will only install on their target machine types as recommended by Zabbix.

The MSI package has been tested successfully on all Windows 2000+ platforms including Server 2003, 2008 and 2012 and may be deployed with services such as Active Directory Group Policy Package Deployment.

The package is defined in WiX XML document `Zabbix Agent MSI Installer.wxs`, and requires open source application WiX Toolset v3.8 and the Zabbix Windows agent binaries to be compiled successfully.

The `build.cmd` script was created for your convenience to build both the x86 and x64 MSI packages via WiX with the required command arguments. Alternatively, Visual Studio 2010 with Votive may be used to open and build from `Zabbix Agent MSI Installer.sln`.

See the links below to source the required components.

### What gets installed
The following components are installed by the MSI package on a target system.
* Zabbix agent binaries including `zabbix_agentd`, `zabbix_get` and `zabbix_sender`
* Agent configuration file `zabbix_agentd.win.conf`
* Environment variable `ZBX_AGENT_BASE` which may be used to reference script paths in agent configuration
* Agent binaries and scripts folders are added to the `PATH` environment variable
* The agent service is installed and started ready for responding to Zabbix server queries
* Additional files that you may define (scripts, conf.d files, etc.)

By default, all components are installed to `C:\Program Files\Zabbix Agent` but this is configurable both at build and run-time.

The uninstall process of the MSI successfully cleans up all of the above components.

You may test the success of an agent install by calling the following from a command prompt:

	zabbix_get -s 127.0.0.1 -k agent.version

### How to build the MSI
1. Install WiX Toolset
2. Extract the contents of `zabbix_agents_2.2.1.win.zip` to the `src/` subdirectory of this project
3. Modify `src/conf/zabbix_agentd.win.conf` to meet your requirements on the target systems
4. Add any custom scripts you wish to deploy with the agent to the `src/scripts` or `src/scripts/include` subdirectory
5. Add custom scripts and other required components as XML definitions in `Zabbix Agent MSI Installer.wxs`
6. Compile the MSI packages with `build.cmd` or from Visual Studio 2010 with `Zabbix Agent MSI Installer.sln`

To manually compile the package, see the contents of `build.cmd` for the required command arguments.

If you are building the agent binaries yourself or you wish to source them from an alternative path, modify the definition of `SrcPath` in `Zabbix Agent MSI Installer.wxs`.

### How it works
Let's take a look inside the wxs file to see how it all fits together. I'll assume you have a basic understanding of XML, Windows Installer technologies and the WiX Toolset. Most of the file will be self explanatory with some knowledge of these components, so I'll focus on the Zabbix specific components.

__Preprocessor Variables__

The following variables define the name of version of the agent to be install, as well as the relative path for the agent binaries.

```xml
	<?define AgentName = "Zabbix Agent" ?>
	<?define AgentVersion = "2.2.1.40801" ?>
	<?define SrcPath = "src" ?>
```

The next section sets required variables according to the machine architecture being built. These variables define the MSI product name, install destination folder and agent binaries source path (for the correct architecture).

```xml
	<?if $(var.Platform) = x64 ?>
		<!-- 64 Bit Platform -->
		<?define Win64 ?>
		<?define ProductName = "$(var.AgentName) (64bit)" ?>
		<?define PlatformProgramFilesFolder = "ProgramFiles64Folder" ?>
		<?define BinDir = "win64" ?>
	<?else ?>
		<!-- 32 Bit Platform -->
		<?define ProductName = "$(var.AgentName) (32bit)" ?>
		<?define PlatformProgramFilesFolder = "ProgramFilesFolder" ?>
		<?define BinDir = "win32" ?>
	<?endif ?>
```

__Prevent 32bit install on 64bit system__

The Zabbix agent documentation recommends using the 64bit binaries on 64bit Windows systems. From experience I can tell you this is good because 32bit applications cannot access some system resources on 64bit Windows systems such as 64bit registry hives, the `C:\Program Files` folder, etc.

```xml
	<!-- Prevent 32bit MSI installing on 64bit systems -->
	<?ifndef Win64 ?>
	<Condition Message="Please install the 64bit version of $(var.AgentName)">Installed OR (NOT VersionNT64)</Condition>
	<?endif ?>
```

__Prevent 'Files in Use' dialogue__

Because the Zabbix agent runs as a service, when you attempt to upgrade or uninstall the MSI, Windows Installer will by default complain that the agent service is running. I manually handle the starting and stopping of the service later, so I prevent this dialogue from showing.

```xml
	<!-- Prevent files-in-use dialog -->
	<Property Id="MSIRESTARTMANAGERCONTROL" Value="Disable"/>
```

__Environment Variables__

One of the nice things the Zabbix agent configuration offers is variable substitution in the `UserParameter` directives. In the case of an MSI installer, we can't always be certain where the agent scripts will be installed to so it doesn't make sense to add a full path to the scripts defined as User Parameters. I've solved this problem in the MSI build by setting an environment variable `ZBX_AGENT_BASE` to the path Windows Installer ultimately installs the MSI to.

Effectively you can now define scripts paths for User Parameters that will always resolve; no matter where the MSI is installed. Example:
	UserParameter=my.key,cscript %ZBX_AGENT_BASE%\scripts\myscript.vbs

In addition, the `bin` and `scripts` path of the installed files is added to the `PATH` environment variable so tools like `zabbix_get`, `zabbix_sender` and your custom tools can be called from any location on the command line.

The Environment Variable components have their GUIDs predefined in the XML as Windows Installer can't seem to generate GUIDs for components not installed to a predefined list of folders (including `C:\Program files`, etc.)

```xml
	<!-- Environment Variables -->
    <ComponentGroup Id="EnvVars" Directory="ConfigurationFolder">
      <!-- ZBX_AGENT_BASE Environment Variable -->
      <Component Id="BaseEnvVar" Guid="{9583C630-9C59-4C37-BF07-C04B91032B15}" KeyPath="yes">
        <Environment Id="BaseEnvVarDef" Name="ZBX_AGENT_BASE" Action="set" Part="all" Permanent="no" Value="[INSTALLFOLDER]" System="yes" />
      </Component>

      <!-- PATH Environment Variable-->
      <Component Id="PathEnvVar" Guid="{C873B777-091F-4445-910C-A6A77EF55AB0}" KeyPath="yes">
        <Environment Id="PathEnvVarDef" Name="PATH" Action="set" Part="last" Permanent="no" Value="[INSTALLFOLDER]bin\$(var.BinDir);[INSTALLFOLDER]scripts" System="yes" />
      </Component>
    </ComponentGroup>
```

__Platform Binaries__

Earlier in the document we defined the `BinDir` preprocessor variable to be either `win32` or `win64`. This correlates to a subdirectory of `bin` in which the platform specific binaries for the Zabbix agent reside. I know use this variable to source the correct binaries for the MSI build.

```xml
    <!-- Platform binary files -->
    <ComponentGroup Id="Binaries" Directory="ArchBinariesFolder">
      <Component Id="ZabbixAgent" Guid="*">
        <File Id="ZabbixAgentBin" Name="zabbix_agentd.exe" Source="$(var.SrcPath)\bin\$(var.BinDir)\zabbix_agentd.exe" />
      </Component>
      <Component Id="ZabbixSender" Guid="*">
        <File Id="ZabbixSenderBin" Name="zabbix_sender.exe" Source="$(var.SrcPath)\bin\$(var.BinDir)\zabbix_sender.exe"/>
      </Component>
      <Component Id="ZabbixGet" Guid="*">
        <File Id="ZabbixGetBin" Name="zabbix_get.exe" Source="$(var.SrcPath)\bin\$(var.BinDir)\zabbix_get.exe"/>
      </Component>
    </ComponentGroup>
```

__Custom Scripts__

If you have custom scripts you would like to bundle with the MSI install for custom User Parameters, this is where they are defined.
These will be installed to `%ZBX_AGENT_BASE%\scripts\` to be referenced in your agent configuration file.

```xml
    <!-- Custom Script Components -->
    <ComponentGroup Id="Scripts" Directory="ScriptsFolder">
      <ComponentGroupRef Id="SharedScripts" />
      
      <!-- Sample Custom Script -->
      <!--
      <Component Id="CustomScript" Guid="*">
        <File Id="CustomScriptFile" Name="CustomScript.ps1" Source="$(var.SrcPath)\scripts\CustomScript.ps1" />
      </Component>
      -->
    </ComponentGroup>
```

A place-holder is also created for shared libraries (Perl modules, PowerShell modules, etc.) into which you can define share file components.

```xml
    <!-- Shared Script (Includes) Components -->
    <ComponentGroup Id="SharedScripts" Directory="ScriptsIncludeFolder" />
```

__Installation Actions__

Once the Zabbix agent is installed on a target system, it makes sense to configure and start the agent service. The following directives make this light work and have been tested on Windows Server 2000 through 2012 in various install locations.

```xml
    <!-- Install Service Actions -->
    <CustomAction Id="InstallService" Directory="ArchBinariesFolder" ExeCommand="&quot;[#ZabbixAgentBin]&quot; --install --config &quot;[#AgentConfigurationFile]&quot;" Execute="deferred" Return="check" Impersonate="no" />
    <CustomAction Id="StartService" Directory="ArchBinariesFolder" ExeCommand="&quot;[#ZabbixAgentBin]&quot; --start --config &quot;[#AgentConfigurationFile]&quot;" Execute="deferred" Return="check" Impersonate="no"/>

    <!-- Uninstall Service Actions -->
    <CustomAction Id="StopService" Directory="ArchBinariesFolder" ExeCommand="&quot;[#ZabbixAgentBin]&quot; --stop --config &quot;[#AgentConfigurationFile]&quot;" Execute="deferred" Return="ignore" Impersonate="no" />
    <CustomAction Id="RemoveService" Directory="ArchBinariesFolder" ExeCommand="&quot;[#ZabbixAgentBin]&quot; --uninstall --config &quot;[#AgentConfigurationFile]&quot;" Execute="deferred" Return="ignore" Impersonate="no" />
```

The custom actions are scheduled for execution as follows:

```xml
    <InstallExecuteSequence>      
      <!-- Install Service Sequence -->
      <Custom Action="InstallService" After="InstallFiles">NOT Installed</Custom>
      <Custom Action="StartService" After="InstallService">NOT Installed</Custom>

      <!-- Uninstall Service Sequence -->
      <Custom Action="StopService" Before="RemoveFiles">Installed</Custom>
      <Custom Action="RemoveService" Before="StopService">Installed</Custom>
    </InstallExecuteSequence>
```

__UI Definition__

The final `<UI Id="WixUI_InstallDirMod">` section is copied from the `WixUI_InstallDir` dialogue set defined in WiX sources, with the EULA dialogue removed so end users are not required to accept a generic EULA.

### Links
- Download [WiX Toolset v3.8](http://wixtoolset.org/releases/v3.8/stable)
- Download [Zabbix Windows Agent](http://www.zabbix.com/downloads/2.2.1/zabbix_agents_2.2.1.win.zip)
- WiX Toolset [Manual](http://wixtoolset.org/documentation/manual/v3/)
- Working with Visual Studio 2010 and [Votive](http://wixtoolset.org/documentation/manual/v3/votive/)
- Windows Installer Reference on [MSDN](http://msdn.microsoft.com/en-us/library/aa372860(v=vs.85).aspx)