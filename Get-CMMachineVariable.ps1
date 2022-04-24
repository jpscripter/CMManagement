Function Get-CMMachineVariable {
    param(
    [String] $VariableName
    )
    
        $CurrentVariablesClasses = Get-WMIObject -Namespace root/ccm/policy -list -Recurse -ClassName CCM_CollectionVariable -ErrorAction Ignore
        $Vars = @{}
        :Policy Foreach ($Class in $CurrentVariablesClasses){
            [array]$VariableInstances = $class.GetInstances()
            if ($VariableInstances.count -ne 0){
                :Var foreach ($Variable in $VariableInstances){
                    $Name = $Variable.name
                    if ($name -NE $VariableName -and -not [string]::IsNullOrWhiteSpace($VariableName)){Continue :var}
                    [xml]$PolicySecret = $Secret.value
                    $innerValue = $PolicySecret.PolicySecret.InnerText
    
                    $VariableByteArray =@()
                    for ($I = 0; $I -lt ($innerValue.Length/2-4);$I++){
                        $VariableByteArray += [convert]::ToByte($innerValue.Substring(($I + 4)*2,2),16)
                    }
                    Try{
                        $DecryptedSecret = [Security.Cryptography.ProtectedData]::Unprotect($VariableByteArray,$Null,[System.Security.Cryptography.DataProtectionScope]::CurrentUser)
                    }
                    Catch{
                        Write-Warning -Message "Could not decrypt $name. Ensure you are running as system."
                    }
                    $DecryptedString = [System.Text.Encoding]::Unicode.GetString($DecryptedSecret)
                    
                    if ($Null -eq $vars[$Name] -and -not [string]::IsNullOrEmpty($DecryptedString)){
                        if ([string]::IsNullOrEmpty($VariableName)){
                            try{
                                $Null = $Vars.Add($name, $DecryptedString)
                            }Catch{
                                Write-Warning -Message "Error Adding $name"
                            }
                        }Else{
                            Return $DecryptedString
                        }
                    }
                }
            }
        }
        $vars
    }