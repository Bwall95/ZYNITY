# Use the official Windows Server Core 2022 image as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set PowerShell as the default shell
SHELL ["powershell.exe", "-Command"]

#Set Hostname
RUN Rename-Computer -NewName "ZYNITY" -Force -PassThru

# Install RSAT-AD-Tools (includes AD PowerShell modules)
RUN Install-WindowsFeature -Name "RSAT-AD-Tools"

# Install NuGet and PowerShell Modules
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; \
    Install-Module -Name PowerShellGet -Force -AllowClobber; \
    Install-Module -Name PSReadLine -Force; \
    Remove-Item -Force -Recurse C:\Windows\Temp\*
    Invoke-WebRequest -Uri https://awscli.amazonaws.com/AWSCLIV2.msi -OutFile AWSCLIV2.msi; \
    Start-Process msiexec.exe -ArgumentList '/i AWSCLIV2.msi /quiet' -Wait; \
    Remove-Item AWSCLIV2.msi
   
    # Configure the local user
RUN net user /add ZYNITY "Password1!"; \
    net localgroup administrators ZYNITY /add

    # Set the working directory inside the container
WORKDIR /app

# Copy the PowerShell script and config.json into the container
COPY config.ps1 /app/config.ps1
COPY ZYNITY-Core.ps1 /app/ZYNITY-Core.ps1

# Enable PowerShell Remoting (to allow PSSession)
RUN Enable-PSRemoting -Force; \
    Set-Item WSMan:\localhost\Client\TrustedHosts * -Force; \
    winrm quickconfig -force; 

# Expose the default port for PowerShell Remoting (5985 for HTTP, 5986 for HTTPS)
EXPOSE 5985 5986

# Set PowerShell as the default shell for the container, and run the config script.
CMD ["powershell.exe", "-Command", "Start-Sleep -Seconds 300"]

