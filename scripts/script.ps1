$url = 'https://localhost:7057/api/Operation/execute'
$data = @{
    expression = "7*3"
} | ConvertTo-Json
$response = Invoke-WebRequest -Uri $url -Method Post -Body $data -ContentType "application/json"
$response.Content
