FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

RUN apt update
RUN apt install -y clang zlib1g-dev

ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["PressUpApi/PressUpApi.csproj", "PressUpApi/"]
RUN dotnet restore "PressUpApi/PressUpApi.csproj"
COPY . .
WORKDIR "/src/PressUpApi"
RUN dotnet build "./PressUpApi.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./PressUpApi.csproj" -c $BUILD_CONFIGURATION -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["./PressUpApi"]
