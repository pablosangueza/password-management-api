FROM mcr.microsoft.com/dotnet/aspnet:6.0 as base
ENV ASPNETCORE_ENVIRONMENT=Development
EXPOSE 80
EXPOSE 443


FROM mcr.microsoft.com/dotnet/sdk:6.0 as devbase
WORKDIR /src

FROM devbase as build
COPY ./src .
RUN dotnet build "PasswordManagementAPI.sln" -c Release -o /app

FROM build AS publish
RUN dotnet publish "PasswordManagement.API/PasswordManagement.API.csproj" -c Release -o /app

FROM base as final
RUN sed 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/' /etc/ssl/openssl.cnf > /etc/ssl/openssl.cnf.changed && mv /etc/ssl/openssl.cnf.changed /etc/ssl/openssl.cnf
WORKDIR /app

COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PasswordManagement.API.dll"]