FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["Source/AXBSample/AXBSample.csproj", "Source/AXBSample/"]

RUN dotnet restore "Source/AXBSample/AXBSample.csproj"
COPY . .
WORKDIR "/src/Source/AXBSample"
RUN dotnet build "AXBSample.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AXBSample.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AXBSample.dll"]