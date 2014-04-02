:: Zabbix Agent MSI Installer Build Script
:: Author: Ryan Armstrong <ryan@cavaliercoder.com>
::
:: This script will build the x86 and x64 MSI packages for the
:: custom Zabbix agent defined in "Zabbix Agent MSI Installer.wxs"
::
:: Requires WiX Toolset v3.8
set WIXBIN=C:\Program Files (x86)\WiX Toolset v3.8\bin

:: Build x64 package
"%WIXBIN%\candle.exe" -dPlatform=x64 -arch x64 -ext "%WIXBIN%\WixUtilExtension.dll" -ext "%WIXBIN%\WixUIExtension.dll" -out "Zabbix Agent MSI Installer.wixobj" "Zabbix Agent MSI Installer.wxs" 
"%WIXBIN%\light.exe" -ext "%WIXBIN%\WixUtilExtension.dll" -ext "%WIXBIN%\WixUIExtension.dll" -spdb -out "zabbix-agent.x64.msi" "Zabbix Agent MSI Installer.wixobj"
erase "Zabbix Agent MSI Installer.wixobj"

:: Build x86 package
"%WIXBIN%\candle.exe" -dPlatform=x86 -arch x86 -ext "%WIXBIN%\WixUtilExtension.dll" -ext "%WIXBIN%\WixUIExtension.dll" -out "Zabbix Agent MSI Installer.wixobj" "Zabbix Agent MSI Installer.wxs" 
"%WIXBIN%\light.exe" -ext "%WIXBIN%\WixUtilExtension.dll" -ext "%WIXBIN%\WixUIExtension.dll" -spdb -out "zabbix-agent.x86.msi" "Zabbix Agent MSI Installer.wixobj"
erase "Zabbix Agent MSI Installer.wixobj"