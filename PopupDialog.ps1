[Reflection.Assembly]::LoadFrom("C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.dll") 
[System.Windows.MessageBox]::Show("Record already exists. Do you want to overwrite?", "Confirmation", "YesNo", "Question")