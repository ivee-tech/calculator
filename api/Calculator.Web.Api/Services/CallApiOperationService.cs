using Microsoft.AspNetCore.Mvc;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using Microsoft.CodeAnalysis.CSharp.Scripting;
using Calculator.Common.Models;
using Calculator.Common.Configuration;
using Calculator.Common.Interfaces;
using Calculator.Common.Exceptions;
using Calculator.Common.Services;
using Calculator.Web.Api.Configuration;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Calculator.Web.Api.Controllers
{
    public class CallApiOperationService : IOperationService
    {

        private readonly bool _isProduction;

        private readonly IWebHostEnvironment _environment;
        private readonly IConfiguration _configuration;
        private readonly ApiClient _apiClient;

        public CallApiOperationService(IWebHostEnvironment environment, IConfiguration configuration, ApiClient apiClient)
        {
            _environment = environment;
            _configuration = configuration;
            _apiClient = apiClient;
            _isProduction = _environment.IsProduction();
        }

        public async Task<List<OperationLog>> Get(DateTime sd, DateTime ed)
        {
            var url = $"{_configuration["Settings:LogApiBaseUrl"]}/operationlogs?sd={sd.ToString("s")}&ed={ed.ToString("s")}";
            var list = await _apiClient.GetAsync<List<OperationLog>>(url, Constants.Log);
            return list;
        }

        public async Task<OperationResponse> ExecuteAndLogOperation(OperationRequest request)
        {

            if(string.IsNullOrEmpty(request?.Expression))
            {
                var error = "Expression cannot be empty.";
                Console.WriteLine(error);
                throw new Exception(error);
            }
            request.Expression = Uri.UnescapeDataString(request?.Expression);
            var logUrl = $"{_configuration["Settings:LogApiBaseUrl"]}/operationlogs";
            double result = 0;
            var logRequest = new OperationLogRequest { Expression = request.Expression, Result = result, Error = "" };
            try
            {
                var execUrl = $"{_configuration["Settings:ExecuteApiBaseUrl"]}/execute";
                var response = await _apiClient.PostAsync<OperationResponse>(execUrl, request, Constants.Execute);
                result = response.Result;
                logRequest.Result = result;
                await _apiClient.PostAsync<OperationLogRequest>(logUrl, logRequest, Constants.Log);
                return response;
            }
            catch (ApiException ex)
            {
                var error = ex.ToString();
                Console.WriteLine(error);
                switch (ex.Type)
                {
                    case Constants.Execute:
                        logRequest.Error = error;
                        await _apiClient.PostAsync<OperationLogRequest>(logUrl, logRequest, Constants.Log);
                        break;
                    case Constants.Log:
                        var response = new OperationResponse { Expression = request.Expression, Result = result, Message = $"WARNING: Failed logging. Logging Error: {error}" };
                        return response;
                    default:
                        break;
                }
                throw new Exception(error);
            }
            catch (Exception ex)
            {
                var error = ex.ToString();
                Console.WriteLine(error);
                throw new Exception(error);
            }
        }

    }
}
