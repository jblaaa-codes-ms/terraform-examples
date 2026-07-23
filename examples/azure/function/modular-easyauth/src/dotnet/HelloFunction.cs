using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace FuncEasyAuth;

public class HelloFunction(ILogger<HelloFunction> logger)
{
    [Function("hello")]
    public IActionResult Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = "hello")] HttpRequest req)
    {
        logger.LogInformation("hello function triggered");
        return new OkObjectResult(new { message = "hello-world" });
    }
}
