Function Get-NetApiRank {
    [alias('nar')]
    param(
        # Enter a domain name to look up its rank in the NetAPI Top 1M (free, no API key)
        [Parameter( Mandatory,
                    ValueFromPipeline)]
        [String]
        $Domain
    )

    Process{
        $data = Invoke-RestMethod "https://netapi.com/api-json/?method=domain-rank&domain=$domain"
        [PSCustomObject]@{
            Domain    = $data.domain
            Rank      = $data.rank
            RankInTld = $data.rank_in_tld
            InTop1M   = $data.in_top_1m
            Snapshot  = $data.snapshot_date
        }
    }
}