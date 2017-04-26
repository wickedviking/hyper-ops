Local-Main
==========

This is the configuration for you main system. To set this up, open a PowerShell prompt in Admin mode.
```
#Set Execution Policy to allow remote scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

#Run this script
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')


```

* [scoop](https://github.com/lukesampson/scoop)
* [PowerShell Theme](https://github.com/lukesampson/scoop/wiki/Theming-Powershell)
    * 7zip
    * git
    * openssh
    * concfg
    * pshazz
