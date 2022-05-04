$expression = "1%2B2"
$url = 'https://zz-calculator-api-dev-dr.azurewebsites.net/api/Operation/execute'
$data = @{ expression = $expression }
$contentType = 'application/json'
$method = 'POST'
$body = $data | ConvertTo-Json
$result = Invoke-WebRequest -Uri $url -Body $body -Method $method -ContentType $contentType
$result

