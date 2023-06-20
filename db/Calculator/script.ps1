# script to deploy DACPAC locally

# Navigate to db
cd .\db\Calculator\

# find MSBuild.exe
$r1 = cmd /c "WHERE /R ""C:\Program Files"" MSBuild.exe"
if(0 -eq $r1.Length) {
    Write-Host "MSBuild.exe cannot be found."
    # exit
}
$msbuild = $r1[0]
# C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe

# find SqlPackage.exe
$r2 = cmd /c "WHERE /R ""C:\Program Files"" SqlPackage.exe"
if(0 -eq $r2.Length) {
    Write-Host "SqlPackage.exe cannot be found."
    # exit
}
$sqlpackage = $r2[0]
# C:\Program Files\Microsoft SQL Server\160\DAC\bin\SqlPackage.exe

# build DB
$cmd = """$msbuild"" ""Calculator.sqlproj"" /t:Build /p:Configuration=Release /p:Platform=""Any CPU"""
cmd /c $cmd


# publish DACPAC
$dacpac = ".\bin\Release\Calculator.dacpac"
$destSvrName = '.'
$destDbName = 'Calculator'
$destConnection = "Server=$destSvrName;Initial Catalog=$destDbName;Integrated Security=SSPI;"
$cmd = """$sqlpackage"" /a:Publish /sf:""$dacpac"" /tcs:""$destConnection"""
cmd /c $cmd
