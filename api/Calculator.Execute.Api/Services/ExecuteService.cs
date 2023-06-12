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
using System.Text.RegularExpressions;
using Microsoft.CodeAnalysis.CSharp.Scripting;

namespace Calculator.Log.Services
{
    public class ExecuteService : IExecuteService
    {
        private readonly IConfiguration _configuration;

        public ExecuteService(IConfiguration configuration)
        {
            _configuration = configuration;
        }


        public async Task<double> Execute(string expression)
        {
            try
            {
                double result = 0;
                var pattern = @"(?<n>(\d)+(\.\d+)*)";
                var expr = Regex.Replace(expression, pattern, "(double)(${n})");
                result = await CSharpScript.EvaluateAsync<double>(expr).ConfigureAwait(false);
                return result;
            }
            catch (Exception ex)
            {
                throw new ExpressionException(ex.Message, ex);
            }
        }
    }
}
