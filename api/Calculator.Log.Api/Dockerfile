ARG USE_ENV_VAR

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
ARG USE_ENV_VAR
ENV USE_ENV_VAR=${USE_ENV_VAR}
RUN dotnet publish "Calculator.Log.Api.csproj" -c Release -o /app/publish
RUN apt-get update
RUN apt-get install -y jq
RUN echo $(jq --arg uev "${USE_ENV_VAR}" '.Settings.UseEnvVar = $uev' /app/publish/appsettings.json) > /app/publish/appsettings.json

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Calculator.Log.Api.dll"]
