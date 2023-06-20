using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Net;
using Calculator.Common.Models;
using Calculator.Log.Services;
using Calculator.Common.Exceptions;

namespace Calculator.Execute.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ExecuteController : ControllerBase
    {
        private readonly IExecuteService _execSvc;
        private readonly ILogger<ExecuteController> _logger;

        public ExecuteController(IExecuteService execSvc, ILogger<ExecuteController> logger)
        {
            _execSvc = execSvc;
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            _logger = logger;
        }

        [HttpPost("")]
        public async Task<IActionResult> Post(OperationRequest request)
        {
            var response = new OperationResponse
            {
                Result = 0,
                Expression = request.Expression,
                Message = ""
            };
            try
            {
                var result = await _execSvc.Execute(request.Expression);
                response.Result = result;
                return Ok(response);
            }
            catch(Exception ex)
            {
                _logger.LogError(ex.ToString());
                return Problem(ex.ToString());
            }
        }     
    }
}
