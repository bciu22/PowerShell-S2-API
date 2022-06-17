# Neds testing to verify works
Function Get-S2PersonPhoto {
    param(
        [parameter(Mandatory=$true)][String] $PersonID,
        $OutFile,
        [Switch] $Display
    )
    $Person = Get-S2Person -PersonID $PersonID

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $cookie = New-Object System.Net.Cookie 
    $cookie.Name = ".sessionId"
    $cookie.Value = $NETBOXSessionID
    $cookie.Domain = $S2HOSTNAME
    $session.Cookies.Add($cookie);

    $S2URL = "$($S2PROTOCOL)$($S2HOSTNAME)/upload/pics/$($Person.PICTUREURL)"
    $Photo = Invoke-WebRequest -URI $S2URL -Method GET -WebSession $session

    if($Display)
    {
        $Stream =[System.IO.MemoryStream]::new($Photo.content)
        $img = [System.Drawing.Image]::FromStream($Stream)
        Add-Type -AssemblyName System.Windows.Forms
        $win = New-Object Windows.Forms.Form
        $box = New-Object Windows.Forms.PictureBox
        $box.Width = $img.Width
        $box.Height = $img.Height
        $box.Image = $img
        $win.Controls.Add($box)
        $win.AutoSize = $true
        $win.ShowDialog()
    }
    elseif($OutFile)
    {
        [System.IO.File]::WriteAllBytes($OutFile,$Photo.content)
    }
    else {
        $Photo.content
    }
}