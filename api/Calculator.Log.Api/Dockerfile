FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /src
COPY ["Calculator.Log.Api/Calculator.Log.Api.csproj", "Calculator.Log.Api/"]
COPY ["Calculator.Common/Calculator.Common.csproj", "Calculator.Common/"]
RUN dotnet restore "Calculator.Log.Api/Calculator.Log.Api.csproj"
COPY . .
WORKDIR "/src/Calculator.Log.Api"
RUN dotnet build "Calculator.Log.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Calculator.Log.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Calculator.Log.Api.dll"]
