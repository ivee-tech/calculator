ARG USE_ENV_VAR
ARG CALL_TYPE

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /src
COPY ["Calculator.Web.Api/Calculator.Web.Api.csproj", "Calculator.Web.Api/"]
COPY ["Calculator.Common/Calculator.Common.csproj", "Calculator.Common/"]
RUN dotnet restore "Calculator.Web.Api/Calculator.Web.Api.csproj"
COPY . .
WORKDIR "/src/Calculator.Web.Api"
RUN dotnet build "Calculator.Web.Api.csproj" -c Release -o /app/build

FROM build AS publish
ARG USE_ENV_VAR
ENV USE_ENV_VAR=${USE_ENV_VAR}
ARG CALL_TYPE
ENV CALL_TYPE=${CALL_TYPE} 
RUN dotnet publish "Calculator.Web.Api.csproj" -c Release -o /app/publish
RUN apt-get update
RUN apt-get install -y jq
# RUN echo $(sed s/__Settings--UseEnvVar__/${USE_ENV_VAR}/g /app/publish/appsettings.json) > /app/publish/appsettings.json
RUN echo $(jq --arg uev "${USE_ENV_VAR}" '.Settings.UseEnvVar = $uev' /app/publish/appsettings.json) > /app/publish/appsettings.json
RUN echo $(jq --arg ct "${CALL_TYPE}" '.Settings.CallType = $ct' /app/publish/appsettings.json) > /app/publish/appsettings.json

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Calculator.Web.Api.dll"]
