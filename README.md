# Calculator application
Sample DevOps app - calculator application with Sql DB, .NET Web Api, and Vue UI


### Execute locally

Pre-requisites:
- SQL Server
- .NET 6.0
- VUE CLI


**Task - Install Calculator DB**

Navigate to *db\Calculator* folder

``` PS
cd .\db\Calculator\
```

Find *MSBuild.exe*

``` PS
$r1 = cmd /c "WHERE /R ""C:\Program Files"" MSBuild.exe"
if(0 -eq $r1.Length) {
    Write-Host "MSBuild.exe cannot be found."
    # exit
}
$msbuild = $r1[0]
# C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe
```

Find *SqlPackage.exe*

``` PS
$r2 = cmd /c "WHERE /R ""C:\Program Files"" SqlPackage.exe"
if(0 -eq $r2.Length) {
    Write-Host "SqlPackage.exe cannot be found."
    # exit
}
$sqlpackage = $r2[0]
# C:\Program Files\Microsoft SQL Server\160\DAC\bin\SqlPackage.exe
```

Build DB

``` PS
$cmd = """$msbuild"" ""Calculator.sqlproj"" /t:Build /p:Configuration=Release /p:Platform=""Any CPU"""
cmd /c $cmd
```

Publish DACPAC

``` PS
$dacpac = ".\bin\Release\Calculator.dacpac"
$destSvrName = '.'
$destDbName = 'Calculator'
$destConnection = "Server=$destSvrName;Initial Catalog=$destDbName;Integrated Security=SSPI;"
$cmd = """$sqlpackage"" /a:Publish /sf:""$dacpac"" /tcs:""$destConnection"""
cmd /c $cmd
```

**Task - Build & Run Web Api**

Navigate to *api* folder and open *Calculator.Web.Api.sln* in VS 2022.

Ensure the connection string point sto your local DB:

``` json
  "ConnectionStrings": {
    "Default": "Data source=.;Initial Catalog=Calculator;Integrated Security=SSPI;"
  },
```

Run the Web Api project and ensure the browser is opening on `https://localhost:7057` (optionally Swagger UI is available):

![Web Api Swagger](./docs/images/01-web-api-swagger.png)

Optionally, test the `Execute` endpoint:

![Test Execute](./docs/images/02-web-api-test-execute.png)

**Task - Run Calculator UI**

Navigate to *ui*

Install dependencies

``` PS
npm install
```

Ensure the API endpoint in *public/assets/config/config.dev.json* file is configured properly

``` json
{
    "apiBaseUrl": "https://localhost:7057/api",
...
}
```

Run the app

``` PS
npm run serve
``` 

Open a browser window and navigate to `http://localhost:8080`

![UI Run](./docs/images/03-ui-run.png)


## Execute locally using containers

## Execute in K8S
