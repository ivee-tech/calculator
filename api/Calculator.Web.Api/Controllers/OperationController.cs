using Microsoft.AspNetCore.Mvc;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using Microsoft.CodeAnalysis.CSharp.Scripting;
using Calculator.Web.Api.Models;
using Calculator.Web.Api.Configuration;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Calculator.Web.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OperationController : ControllerBase
    {

        private readonly IWebHostEnvironment _env;
        private readonly IConfiguration _configuration;

        public OperationController(IWebHostEnvironment env, IConfiguration configuration)
        {
            _env = env;
            _configuration = configuration;
        }

        [HttpGet]
        public async Task<IActionResult> Get(DateTime sd, DateTime ed)
        {
            var opSvc = new OperationService(_env.IsProduction(), _configuration);
            var list = await opSvc.Get(sd, ed);
            return Ok(list);
        }

        [HttpPost("execute")]
        public async Task<IActionResult> ExecuteAndLogOperation(OperationRequest request)
        {
            if(string.IsNullOrEmpty(request?.Expression))
            {
                return BadRequest("Expression cannot be empty.");
            }
            var opSvc = new OperationService(_env.IsProduction(), _configuration);
            try
            {
                var response = await opSvc.ExecuteAndLogOperation(request);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return Problem(ex.ToString());
            }
        }

    }
}
