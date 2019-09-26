Param(
    # Set DockerHub Username, Password & Repo Details
    [string] $API_URL_DEFAULT = 'https://hub.docker.com/v2',
    [string] [Parameter(Mandatory=$true)] $USERNAME,
    [string] [Parameter(Mandatory=$true)] $PASSWORD,
    [string] [Parameter(Mandatory=$true)] $REPO,
    [string] [Parameter(Mandatory=$true)] $README,
    [string] $API_URL = $API_URL_DEFAULT    
)

# Get DockerHub Token 
Write-Host "GET DOCKERHUB TOKEN"
$tokenresponse = invoke-RestMethod -Uri "$API_URL_DEFAULT/users/login" `
                    -Body "{`"username`": `"$USERNAME`",`"password`":`"$PASSWORD`"}"`
                    -ContentType "application/json"`
                    -Method Post

$token = $tokenresponse.token
# duplicate curl --data-urlencode
$encode = ([System.Net.WebUtility]::UrlEncode("$README"))

Write-host "UPDATE DOCKERHUB"
$response = Invoke-RestMethod -Headers @{Authorization = "JWT $token"} `
            -Uri "$API_URL/repositories/$REPO/?full_description=$encode" `
            -Method Patch `
            -ErrorAction Stop

if ($response -and $response.user) {
    Write-Host "Docker Hub Updated"
    exit 0
}  
else {
    Write-Host " Failed to update DockerHub "
    Write-Host "$USERNAME"
    Write-Host "$PASSWORD"
    Write-Host "$README"
    Write-Host "$API_URL"
    exit 1
}

