function Invoke-Joke
{
    
    $rand = Get-Random -Minimum 1 -Maximum 4
    
    switch ($rand) {
        1 { $joke = @{'response' = (Invoke-RestMethod -Uri 'http://api.yomomma.info/' -TimeoutSec 3 -UseBasicParsing).joke } }
        2 { $joke = @{'response' = (Invoke-RestMethod -Uri 'https://icanhazdadjoke.com/' -TimeoutSec 3 -Headers @{"Accept"="application/json"} -UseBasicParsing).joke } }
        3 { $joke = @{'response' = (Invoke-RestMethod -Uri 'http://api.icndb.com/jokes/random/' -TimeoutSec 3 -UseBasicParsing).value.joke } }
        default { $joke = @{'response' = (Invoke-RestMethod -Uri 'http://api.icndb.com/jokes/random/' -TimeoutSec 3 -UseBasicParsing).value.joke } }
    }
    
    return @{
        Id = [Guid]::NewGuid().Guid;
        Response = $joke.response;
        KeyWords = @('joke');
        Action = '';
        Auth = @();
        AuthOverride = @('')
    }
}