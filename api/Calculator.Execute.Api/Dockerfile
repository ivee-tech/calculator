FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /src
COPY ["Calculator.Execute.Api/Calculator.Execute.Api.csproj", "Calculator.Execute.Api/"]
COPY ["Calculator.Common/Calculator.Common.csproj", "Calculator.Common/"]
RUN dotnet restore "Calculator.Execute.Api/Calculator.Execute.Api.csproj"
COPY . .
WORKDIR "/src/Calculator.Execute.Api"
RUN dotnet build "Calculator.Execute.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Calculator.Execute.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Calculator.Execute.Api.dll"]
