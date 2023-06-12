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

namespace Calculator.Log.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OperationLogsController : ControllerBase
    {
        private readonly ILogService _logSvc;

        public OperationLogsController(ILogService logSvc)
        {
            _logSvc = logSvc;
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
        }

        [HttpGet("")]
        public async Task<IActionResult> GetOperationLogs(DateTime sd, DateTime ed)
        {
            var list = await _logSvc.GetOperationLogs(sd, ed);
            return Ok(list);
        }

        [HttpPost("")]
        public async Task<IActionResult> Post(OperationLogRequest request)
        {
            try
            {
                await _logSvc.LogOperation(request.Expression, request.Result, request.Error);
                return Ok();
            }
            catch (LoggingException ex)
            {
                Console.WriteLine(ex.ToString());
                return Ok(ex.ToString());
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                throw;
            }
        }
    }
}
