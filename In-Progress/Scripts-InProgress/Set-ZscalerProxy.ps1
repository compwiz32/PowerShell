$ProxyUrl = 'http://pac.zscalertwo.net/lord.com/proxy.pac'

Set-ItemProperty -path HKCU:"Software\Microsoft\Windows\CurrentVersion\Internet Settings" -name autoconfigurl $ProxyUrl