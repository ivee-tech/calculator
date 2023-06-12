using Calculator.Common.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Calculator.Log.Services
{
    public interface IExecuteService
    {
        Task<double> Execute(string expression);
    }
}
