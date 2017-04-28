Hyper-OPs
=========

My DevOps toolkit for dealing with Hyper-V.

Install Options
---------------
**Remote PowerShell Option A** Install-CorePackages.ps1

Installs the following package managers
* [scoop](http://scoop.sh/) - Seems to have most current stable more
often than chocolatey. Also install under user scope so no admin needed.
Trying it out.
* [chocolatey](https://chocolatey.org/) - Better install parameter
support, wider selection, popping up in more and more places.



This is the configuration for you main system. To set this up, open a PowerShell prompt in Admin mode.
```
#Set Execution Policy to allow remote scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

#Run this script
iex (new-object net.webclient).downloadstring('https://goo.gl/8DLa4x')


```

* [scoop](https://github.com/lukesampson/scoop)
* [PowerShell Theme](https://github.com/lukesampson/scoop/wiki/Theming-Powershell)
    * 7zip
    * git
    * openssh
    * concfg
    * pshazz
