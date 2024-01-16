# SMTP2Go PowerShell Monitor

# Files Included
index.html - A basic css template for the e-mail template in SMTP2Go   
Should look similar to this:

<img src="https://raw.githubusercontent.com/cengbrecht/Powershell_Scripts/main/Service_SMTP2Go/Script_Email_Preview.jpg" alt="Simple HTML Email" width="500">

vars.txt - The variables used in the template and formatted for SMTP2Go  
service.ps1 - The Powershell document to notify about, and automatically restart the service with notification

# Setup
- Create an SMTP2Go account and fulfil setup with verified Sender domain. [Get Started - SMTP2GO Documentation](https://support.smtp2go.com/hc/en-gb/articles/12747932085145-Getting-Started-with-SMTP2GO)  
- Add Template to SMTP2Go using HTML from `index.html` in this repo.  Note the "Template ID" [API Templates](https://support.smtp2go.com/hc/en-gb/articles/4402929434777-API-Templates)
- Set up an API Key [API Keys](https://support.smtp2go.com/hc/en-gb/articles/20733554340249-API-Keys)
- Clone this Repo or download `Service.ps1` and edit the script whith the appropriate information
    - Monitored Service Name
    - From Name and Email
    - Recipient Email
    - Reply-To Name eand Email (If applicable)
    - API Key
    - Template ID
Set script to run on a schedule using your preferred method

# Original E-mail Template is from:
https://github.com/leemunroe/responsive-html-email-template
