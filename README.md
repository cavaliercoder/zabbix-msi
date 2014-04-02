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

By default, all components are installed to `C:\Program Files\Zabbix Agent` but this is configurable both at build and run-time.

The uninstall process of the MSI successfully cleans up all of the above components.

You may test the success of an agent install by calling the following from a command prompt:

	zabbix_get -s 127.0.0.1 -k agent.version

### How to build
1. Extract the contents of `zabbix_agents_2.2.1.win.zip` to the `src/` subdirectory of this project
2. Modify `src/conf/zabbix_agentd.win.conf` to meet your requirements
3. Add any custom scripts you wish to deploy with the agent to the `src/scripts` or `src/scripts/include` subdirectory
4. Add custom scripts and other required components as XML definitions in `Zabbix Agent MSI Installer.wxs`
5. Compile the MSI packages with `build.cmd` or from Visual Studio 2010 with `Zabbix Agent MSI Installer.sln`

To manually compile the package, see the contents of `build.cmd` for the required command arguments.

If you are building the agent binaries yourself or you wish to source them from an alternative path, modify the definition of `SrcPath` in `Zabbix Agent MSI Installer.wxs`.

### Links
- Download [WiX Toolset v3.8](http://wixtoolset.org/releases/v3.8/stable)
- Download [Zabbix Windows Agent](http://www.zabbix.com/downloads/2.2.1/zabbix_agents_2.2.1.win.zip)
- WiX Toolset [Manual](http://wixtoolset.org/documentation/manual/v3/)
- Working with Visual Studio 2010 and [Votive](http://wixtoolset.org/documentation/manual/v3/votive/)
- Windows Installer Reference on [MSDN](http://msdn.microsoft.com/en-us/library/aa372860(v=vs.85).aspx)
