$myIp = (Invoke-RestMethod -Uri "https://api.seeip.org/jsonip?").ip
$fullIPList = Get-Content "auth.log" | Select-String -Pattern "\b(?:\d{1,3}\.){3}\d{1,3}\b" -AllMatches | Select-String -Pattern "\b(?:\d{1,3}\.){3}\d{1,3}\b" -AllMatches | ForEach-Object { $_.Matches.Value } | Where-Object { $_ -ne $myIpAddress }

$ipList = @{}
foreach($ip in $fullIPList) {
    if($null -eq $ipList[$ip]) {
        $ipList.$ip = 0
    }
    $ipList.$ip++
}

if(!(Test-Path "copy.json")) {
    $geoData = New-Object System.Collections.ArrayList
    foreach($ip in $ipList.Keys) {
        $geoData.Add((Invoke-RestMethod -Uri "https://api.ipgeolocation.io/ipgeo?apiKey=<YOUR_API_KEY_HERE>&ip=$ip"))
    }
} else {
    $geoData = (Get-Content "copy.json") | ConvertFrom-Json
}

$listLength = 0
foreach($element in $GeoData) {
    $listLength++
}

for($i=0; $i -lt $listLength; $i++) {
    $GeoData[$i] = [PSCUstomObject]@{
        ip = $GeoData[$i].ip
        country_name = $GeoData[$i].country_name
        state_prov = $GeoData[$i].state_prov
        city = $GeoData[$i].city
        latitude = $GeoData[$i].latitude
        longitude = $GeoData[$i].longitude
        isp = $GeoData[$i].isp
        connection_attempts = $ipList[$GeoData[$i].ip]
    }
}

($geoData | ConvertTo-Json) > processed.json
./map.ipynb