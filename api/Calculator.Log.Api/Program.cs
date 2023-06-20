using Calculator.Log.Controllers;
using Calculator.Common.Interfaces;
using Microsoft.AspNetCore.Builder;
using Calculator.Log.Services;
using Microsoft.Extensions.Configuration;

var builder = WebApplication.CreateBuilder(args);
builder.Logging.ClearProviders();
builder.Logging.AddConsole();

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors();
builder.Services.AddHttpClient();

var logSvc = new LogService(builder.Environment.IsProduction(), builder.Configuration);
builder.Services.AddSingleton<ILogService, LogService>(prov => logSvc);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors(x => x.AllowAnyHeader()
      .AllowAnyMethod()
      .AllowAnyOrigin());

app.UseAuthorization();

// Dapr configurations
app.UseCloudEvents();
app.MapSubscribeHandler();

app.MapControllers();


app.Run();
