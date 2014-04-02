## Zabbix Agent MSI Installer

### Overview
This project contains the files required to build a functional Microsoft Windows MSI package for the deployment of the Zabbix Windows Agent.

The package is defined in WiX XML document, `Zabbix Agent MSI Installer.wxs`, and requires open source application [WiX Toolset v3.8](http://wixtoolset.org/releases/v3.8/stable) to be compiled.

The `build.cmd` script was created for your convenience to build both the x86 and x64 MSI packages via WiX with the required command arguments. Alternatively, Visual Studio 2010 with Votive may be used to open and build from `Zabbix Agent MSI Installer.sln`.

### Links
- Download [WiX Toolset v3.8](http://wixtoolset.org/releases/v3.8/stable)
- Download [Zabbix Windows Agent](http://www.zabbix.com/downloads/2.2.1/zabbix_agents_2.2.1.win.zip)
- WiX Toolset [Manual](http://wixtoolset.org/documentation/manual/v3/)
- Working with Visual Studio 2010 and [Votive](http://wixtoolset.org/documentation/manual/v3/votive/)
- Windows Installer Reference on [MSDN](http://msdn.microsoft.com/en-us/library/aa372860(v=vs.85).aspx)
