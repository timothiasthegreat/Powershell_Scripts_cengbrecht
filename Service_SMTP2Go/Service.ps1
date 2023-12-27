################################################
#Welcome to the Service Autostart Script with SMTP2Go API integration
################################################
#Configuration Section
################################################
#Service you wish to start, and the value of that service (Running or otherwise)
################################################
$Service_Name_Value = "Name of Service"

################################################
#Who you would like to send to, and from.
################################################
$From_Name = "<From Name>"
$From_email = "<From Email Address>"
#Single Email Recipient
$Recipient = "<To Email Address>"

################################################
#If you want to define a different Reply-To than
#the From address uncomment the below variables and adjust
################################################
#$ReplyTo_Name = "<Reply To Name>"
#$ReplyTo_email = "<Reply To Email>"

################################################
#SMTP2GO API Key & Template and other Data 
################################################
$api_key = "<API-KEY>"
$template_id = "<TEMPLATE-ID>"
$hostname = $env:COMPUTERNAME #Edit to override Computer's configured Hostname

################################################
#DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING
################################################
$Service_Status_Value #Empty to start
$service = Get-Service -Name $Service_Name_Value -ErrorAction SilentlyContinue

################################################
#The API Command to Post to SMTP2Go

function Send-APIEmail() {
    param
    (
        $counter,
        $error_output_value,
        $jsonBase,
        $api_key,
        $Recipient,
        $From_Name,
        $From_email,
        $ReplyTo_Name,
        $ReplyTo_email,
        $template_id,
        $Service_Name_Value,
        $Service_Status_Value,
        $Pre_Service_Status_Value,
        $hostname
    )

################################################
#Header Details, do not edit.
#
$headers = @{
    'Accept' = 'application/json'
    'Content-Type' = 'application/json'
}

################################################
#Format the payload.
#
    $jsonBase = [ordered]@{
      'api_key' = "$api_key"
      'to' = @(
        "$Recipient"
        )
      'sender' = "$From_Name <$From_email>"
      'template_id' = "$template_id"
      'template_data' = @{
        'Service_Name' = "$Service_Name_Value"
        'Service_Status' = "$Service_Status_Value"
        'Error_Output' = "$error_output_value"
        'Pre_Service_Status'= "$Pre_Service_Status_Value"
        'Hostname'= "$hostname"
      }
    }
    if ($ReplyTo_email -ne $null) {
        $jsonBase['custom_headers'] = @(
        @{
        'header' = "Reply-To"
        'value' = "$ReplyTo_Name <$ReplyTo_email>"
        }
      )
    }
    ################################################
    # Uncomment for testing variables Change the variable to see what it's printing out.
    #Write-Host $error_output_value
    ################################################
    #Post the API-Request
    Invoke-RestMethod "https://api.smtp2go.com/v3/email/send" -Method Post -Headers $headers -Body ($jsonBase|ConvertTo-Json) -ContentType "application/json"
}

################################################
#Tests if the service is running in Windows
#

function Start-Service_Status($service) {

if ($service.Status -eq "Running") {
    $global:Pre_Service_Status_Value = "Running"
    $global:Service_Status_Value = "Running"
    $global:error_output_value = "No Errors Reported"
} elseif ($service.Status -eq "Paused") {
    $global:Pre_Service_Status_Value = "Paused"
    $global:Service_Status_Value = "Paused"
    $global:error_output_value = $( $output = & Start-Service $service ) 2>&1
} elseif ($service.Status -eq "Starting") {
    $global:Pre_Service_Status_Value = "Starting"
    $global:Service_Status_Value = "Starting"
} elseif ($service.Status -eq "Stopped") {
    $global:Pre_Service_Status_Value = "Stopped"
    $global:Service_Status_Value = "Stopped"
    $global:error_output_value = $( $output = & Start-Service $service ) 2>&1
} else {
    $global:Pre_Service_Status_Value = "Other"
    $global:Service_Status_Value = "Failure"
    $global:error_output_value = $( $output = & Start-Service $service ) 2>&1
}
}

################################################
#Starts the Service Status Function
#
Start-Service_Status -service $service


################################################
#Ends if the service is running, or sends the email
#then restarts the service status Function
#

if ($Service_Status_Value -eq "Running") {
    exit 0
} else {
    Send-APIEmail -counter $counter -api_key $api_key -Recipient $Recipient -From_Name $From_Name -From_email $From_email -ReplyTo_Name $ReplyTo_Name -ReplyTo_email $ReplyTo_email -template_id $template_id -Service_Name_Value $Service_Name_Value -Service_Status_Value $Service_Status_Value -error_output_value $error_output_value -Pre_Service_Status_Value $Pre_Service_Status_Value -hostname $hostname
    Start-Service_Status -Service $service
}
