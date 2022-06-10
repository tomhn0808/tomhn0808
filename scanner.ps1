function Scan-Port{
    param( [string] $ip)
    
    #fct to scan port on a computer
    $port_range=444..1024 #will use a range of int (1,2,3,4,...,1024)
    #$port=445
    if (Test-Connection -Count 1 -ComputerName $ip)
    {
        foreach ($elem in $port_range) {
            try {
                $sock= new-object System.Net.Sockets.TcpClient($ip,$elem)
                $co= $sock.Connected($ip,$elem) | Out-Null
                if ($sock.Connected){
                    Write-Host "$ip port $elem open"
                    $sock.Close()
                }
                }
            catch {
                Write-Host "$ip port $elem closed"
            }
        }
    }
}
#Scan-Port -ip localhost
foreach($line in [System.IO.File]::ReadLines("C:\Users\tomhn0808\rep.txt")) {
    Scan-Port -ip $line
}

#another way to scan

$port_range1=444..1024 #use a range from 1 to 1024
foreach ($elem in $port_range1) {
    echo $elem
    If (($a=Test-NetConnection "localhost" -Port $elem -WarningAction SilentlyContinue).tcpTestSucceeded -eq $true) {
        Write-Host $a.Computername $a.RemotePort -ForegroundColor Green -Separator " ==> "
        } 
    else {
    Write-Host $a.Computername $a.RemotePort -Separator " ==> " -ForegroundColor Red
    }
}
