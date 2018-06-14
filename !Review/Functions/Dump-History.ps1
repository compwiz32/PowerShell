 function Dump-History ()
 {
 $shortdate = (get-date -Format yyyy-dd-MM).ToString()
 history |  out-file c:\scripts\History\"Powershell-history-"$shortdate".txt" -Append 
 }
 
 