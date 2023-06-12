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
RUN dotnet publish "Calculator.Web.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Calculator.Web.Api.dll"]
