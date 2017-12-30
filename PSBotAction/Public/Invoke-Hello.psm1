function Invoke-Hello
{
    return @{
        Id = [Guid]::NewGuid().Guid;
        Response = "Hey what's up"
        KeyWords = @('hey', 'hello', "what's", 'up', 'yo', 'bot');
        Action = '';
        Auth = @();
        AuthOverride = @()
    }
}