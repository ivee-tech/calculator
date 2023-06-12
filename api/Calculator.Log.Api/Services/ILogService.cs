using Calculator.Common.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Calculator.Log.Services
{
    public interface ILogService
    {
        Task LogOperation(string expression, double result, string error);
        Task<List<OperationLog>> GetOperationLogs(DateTime sd, DateTime ed);
    }
}
