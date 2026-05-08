$url = "https://wpad4de6lcroi5o7uaimbvokuu0glhhv.lambda-url.us-east-1.on.aws/"

$payload = @{
    item  = "Industrial Robot Arm"
    price = "4500.00"
    user  = "Inaki Medina"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $payload -ContentType "application/json"
    Write-Output "Status: Success"
    Write-Output ($response | ConvertTo-Json -Depth 5)
}
catch {
    Write-Error "Request failed: $_"
}