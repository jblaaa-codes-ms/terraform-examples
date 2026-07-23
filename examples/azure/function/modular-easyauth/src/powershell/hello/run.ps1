using namespace System.Net

param($Request, $TriggerMetadata)

$body = '{"message":"hello-world"}'

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $body
    Headers    = @{ 'Content-Type' = 'application/json' }
})
