Function Get-AlexaRank {
    [alias('alx','alexa')]
    param(
        # Enter a domain name to lookup Alexa Rank
        [Parameter( Mandatory,
                    ValueFromPipeline)]
        [String]
        $Domain
    )

    Process{
        $data = (Invoke-RestMethod "http://data.alexa.com/data?cli=10&dat=s&url=$domain").alexa.sd[1]
        [PSCustomObject]@{
            Domain = $domain
            Rank = [int]$data.reach.rank
            Popularity = [int]$data.popularity.text
            Delta = $data.rank.delta
        }
    }
}