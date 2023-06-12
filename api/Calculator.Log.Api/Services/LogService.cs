using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Net.Http;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using System.Text;
using System.Data.SqlClient;
using Calculator.Common.Exceptions;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Calculator.Common.Models;
using static Calculator.Common.Configuration.SqlDataReaderExtensions;

namespace Calculator.Log.Services
{
    public class LogService : ILogService
    {
        private readonly bool _isProduction;
        private readonly IConfiguration _configuration;

        public LogService(bool isProduction, IConfiguration configuration)
        {
            _isProduction = isProduction;
            _configuration = configuration;
        }


        public async Task LogOperation(string expression, double result, string error)
        {
            try
            {
                var connectionString = GetConnectionString();
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (var cmd = conn.CreateCommand())
                    {
                        var date = DateTime.Now;
                        cmd.CommandText = "INSERT INTO dbo.OperationLogs(Expression, Result, Date, Error) VALUES(@Expression, @Result, @Date, @Error)";
                        cmd.Parameters.AddWithValue("@Expression", expression);
                        cmd.Parameters.AddWithValue("@Result", result);
                        cmd.Parameters.AddWithValue("@Date", date);
                        cmd.Parameters.AddWithValue("@Error", error);
                        await cmd.ExecuteNonQueryAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new LoggingException(ex.Message, ex);
            }
        }

        public async Task<List<OperationLog>> GetOperationLogs(DateTime sd, DateTime ed)
        {
            var list = new List<OperationLog>();
            var connectionString = GetConnectionString();
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT * FROM dbo.OperationLogs WHERE Date BETWEEN @sd AND @ed";
                    cmd.Parameters.AddWithValue("@sd", sd);
                    cmd.Parameters.AddWithValue("@ed", ed);
                    var rdr = await cmd.ExecuteReaderAsync();
                    while (rdr.Read())
                    {
                        int id = 0;
                        string expression = "";
                        double result = 0;
                        DateTime date = DateTime.MinValue;
                        string error = "";
                        rdr.TryGetValue<int>("Id", ref id);
                        rdr.TryGetValue<string>("Expression", ref expression);
                        rdr.TryGetValue<double>("Result", ref result);
                        rdr.TryGetValue<DateTime>("Date", ref date);
                        rdr.TryGetValue<string>("Error", ref error);
                        var log = new OperationLog()
                        {
                            Id = id,
                            Expression = expression,
                            Result = result,
                            Date = date,
                            Error = error
                        };
                        list.Add(log);
                    }
                }
            }
            return list;
        }

        private string GetConnectionString()
        {
            var connectionString = _configuration["ConnectionStrings:Default"];
            var useEnvVar = _configuration.GetValue<bool>("Settings:UseEnvVar");
            if (useEnvVar)
            {
                // Windows
                connectionString = Environment.GetEnvironmentVariable("CALC_DB_CONNECTIONSTRING", EnvironmentVariableTarget.User);
                // Linux
                if (string.IsNullOrEmpty(connectionString))
                {
                    connectionString = Environment.GetEnvironmentVariable("CALC_DB_CONNECTIONSTRING");
                }
                Console.WriteLine($"CALC_DB_CONNECTIONSTRING: {connectionString}");
                return connectionString;
            }
            else
            {
                if (_isProduction)
                {
                    var useKeyVault = _configuration.GetValue<bool>("Settings:UseKeyVault");
                    if (useKeyVault)
                    {
                        var cred = new DefaultAzureCredential();
                        var kvUrl = $"https://{_configuration["Settings:KeyVaultName"]}.vault.azure.net";
                        var kvUri = new Uri(kvUrl);
                        var client = new SecretClient(kvUri, cred);
                        connectionString = client.GetSecret("ConnectionStrings--Default").Value.Value;
                        Console.WriteLine($"ConnectionStrings--Default: {connectionString}");
                        return connectionString;
                    }
                }
            }
            Console.WriteLine($"ConnectionStrings:Default: {connectionString}");
            return connectionString;
        }
    }
}
