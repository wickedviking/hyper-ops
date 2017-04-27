


#install scoop https://github.com/lukesampson/scoop
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

#Theme Powershell, cause it's better that way
scoop install 7zip git openssh concfg
concfg export ~/console-backup.json
concfg import solarized small
scoop install pshazz