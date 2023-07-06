################################################
#Welcome to the Service Autostart Script with SMTP2Go API integration
################################################

################################################
#Service you wish to start, and the value of that service (Running or otherwise)
################################################
$Service_Name_Value = "<ServiceName>"
$Service_Status_Value #Empty to start

################################################
#Poll Service Status and information
#
$service = Get-Service -Name $Service_Name_Value -ErrorAction SilentlyContinue

################################################
#Who you would like to send to, and from.
################################################
$From = "<Email Here>"
$Recipients = "<Email Here>"
$ReplyTo = "<Email Here>"

################################################
#API Key & Template and other Data
#
$api_key = "<Your API Key Here>"
$template_id = "<Template ID>"
$hostname = Hostname


################################################
#The API Command to Post to SMTP2Go

function Send-APIEmail() {
    param
    (
        $counter,
        $error_output_value,
        $jsonBase,
        $api_key,
        $Recipients,
        $From,
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
        "$Recipients"
        )
      'sender' = "$From"
      'template_id' = "$template_id"
      'template_data' = @{
        'Service_Name' = "$Service_Name_Value"
        'Service_Status' = "$Service_Status_Value"
        'Error_Output' = "$error_output_value"
        'Pre_Service_Status'= "$Pre_Service_Status_Value"
        'Hostname'= "$hostname"
      }
      #'custom_headers' = @{
      #  'header' = "Reply-To"
      #  'Reply-To' = "$ReplyTo"
      #}
    }
    ################################################
    # Uncomment for testing variables Change the variable to see what it's printing out.
    #Write-Host $error_output_value
    ################################################
    #Post the API-Request
    #
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
    Send-APIEmail -counter $counter -api_key $api_key -Recipients $Recipients -From $From -template_id $template_id -Service_Name_Value $Service_Name_Value -Service_Status_Value $Service_Status_Value -error_output_value $error_output_value -Pre_Service_Status_Value $Pre_Service_Status_Value -hostname $hostname
    Start-Service_Status -Service $service
}