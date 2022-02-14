Describe "Get-BFRestData" {
    Context "Ensuring command logs into default BigFix server using queryied credentials - parse warning mesg." {
        $results = .\Get-BFRestData.ps1 -bRaw $true -relevance "names of bes computers" -WarningVariable warning 

        It "Should Warn" {
            $warning | Should Match "login returned OK"
        }
        It "Should return specified-object (i.e. 'names of bes computers' XML) -- Not Null" {
            $results | Should not Be $null
        }
    }
}
