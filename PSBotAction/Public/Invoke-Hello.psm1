function Invoke-Hello
{
    return @{
        Id = 'b8f03d3e-02fd-40fc-9650-f858d40327ad';
        Response = "Hey what's up"
        KeyWords = @('hey', 'hello', 'whats up');
        Action = 'Invoke-HelloFunction';
        Auth = @('abelal');
        AuthOverride = @()
    }
}

function Invoke-HelloFunction
{
    return 'Invoked HelloFunction'
}