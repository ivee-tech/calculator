using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Net;
using Calculator.Common.Models;
using Calculator.Log.Services;
using Calculator.Common.Interfaces;
using Azure;
using Calculator.Common.Exceptions;
using Dapr;

namespace Calculator.Log.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OperationLogsController : ControllerBase
    {
        private readonly ILogService _logSvc;
        private readonly ILogger<OperationLogsController> _logger;

        public OperationLogsController(ILogService logSvc, ILogger<OperationLogsController> logger)
        {
            _logSvc = logSvc;
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            _logger = logger;
        }

        [HttpGet("")]
        public async Task<IActionResult> GetOperationLogs(DateTime sd, DateTime ed)
        {
            var list = await _logSvc.GetOperationLogs(sd, ed);
            return Ok(list);
        }

        [HttpPost("")]
        [Topic("pubsub", "calc-operation-logs")]
        public async Task<IActionResult> Post(OperationLogRequest request)
        {
            try
            {
                _logger.LogInformation($"Logging operation {request.Expression}...");
                await _logSvc.LogOperation(request.Expression, request.Result, request.Error);
                _logger.LogInformation($"Operation {request.Expression} logged successfully.");
                return Ok();
            }
            catch (LoggingException ex)
            {
                _logger.LogError(ex.ToString());
                return Problem(ex.ToString());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.ToString());
                throw;
            }
        }
    }
}
