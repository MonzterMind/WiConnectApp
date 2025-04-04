param (
    
    [string] $smtpServer,
    [string] $from,
    [string] $to,
    [string] $subject,
	[string] $body

)

if (-not $smtpServer) {
    $smtpServer = "10.155.109.1"
}

if (-not $from) {
    $from = "WiConnectAppCalgary@Sobeys.com"
}
if (-not $to) {
    $to = "mikelangelotriplex@yahoo.com"
}
if (-not $subject) {
    $subject = "Node.js WiConnectApp Server Started"
}

 

$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
if (-not $body) {
$body = "This report was generated by  WIOSS Document Support Script at " +$dateTime + ". Witron Service Canada Corp."
}


$mailParams = @{
    SmtpServer = $smtpServer
    #Port = $smtpPort    
    From = $from
    To = $to
    Subject = $subject
    Body = $body
    
}

#send email
$mailMessage = New-Object System.Net.Mail.MailMessage
$mailMessage.From = $mailParams.From
$mailMessage.To.Add($mailParams.To)
$mailMessage.Subject = $mailParams.Subject
$mailMessage.Body = $mailParams.Body

$smtpClient = New-Object System.Net.Mail.SmtpClient($mailParams.SmtpServer)


#



$smtpClient.Send($mailMessage)
