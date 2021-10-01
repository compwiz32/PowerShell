$SpeakerInfo = [PSCustomObject]@{
    Name      = 'Anthony Nocentino'
    Shortname = 'Anthony'
    Bio       = "$($SpeakerInfo.Name) is a Principal Field Solutions Architect at Pure Storage, Pluralsight Author, and Microsoft Data Platform MVP. $($SpeakerInfo.Shortname) designs solutions, deploys the technology, and provides expertise on business system performance, architecture, and security. $($SpeakerInfo.Shortname) has a Bachelors and Masters in Computer Science with research publications in high performance/low latency data access algorithms and spatial database systems."
    Email     = 'anocentino@purestorage.com'
    GitHub    = 'https://github.com/nocentino/'
    Twitter   = '@nocentino'
    Website   = 'https://www.nocentino.com/'
}

$EventInfo = [PSCustomObject]@{
    EventTitle            = "Containers: You Better Get on Board, PowerShell Edition ($($SpeakerInfo.Name)"
    EventDate             = "$(get-date -Date 10/20/21 -DisplayHint Date)"
    EventTime             = '8:00 PM EST'
    EventDuration         = '2 hrs'
    VideoChatLink         = 'https://teams.microsoft.com/l/meetup-join/19%3ameeting_ODdlMmY4NWMtN2VhMS00MDUzLWEzODYtNTZmNmI0Yjc5YTFl%40thread.v2/0?context=%7b%22Tid%22%3a%22a70051d7-ca08-4339-bade-6d710a2ff616%22%2c%22Oid%22%3a%22aebb0a79-a180-4153-981d-276bb4f65981%22%7d'
    TimeZoneInfo          = 'https://everytimezone.com/s/6651df3f'
    EventDescriptionFull  = @"
Containers are taking over, changing the way systems are developed and deployed…and thats not hyperbole. Just imagine if you could deploy SQL Server or even your whole application stack in just minutes. You can do that, using containers!

Join $($SpeakerInfo.Name) for a look at how to get your container journey started, learn some common container scenarios and introduce deployment orchestration with Kubernetes. In this session we will look at Container Fundamentals, Common Container Scenarios, Deploying Applications in Containers, Running PowerShell in Containers and Kubernetes and Orchestration with Kubernetes
"@
    EventDescriptionShort = "Join $($SpeakerInfo.Name) for a look at how to get your container journey started, learn some common container scenarios and introduce deployment orchestration with Kubernetes."
    SocialTags            = "#PowerShell", "#Containers"
    VideoTags             = @(
        "Powershell docker containers",
        "Powershell containers tutorial",
        "Container PowerShell Fundamentals",
        "Common Container Scenarios",
        "Deploying Applications in Containers with PowerShell",
        "Running PowerShell in Containers and Kubernetes",
        "Orchestration with Kubernetes and PowerShell"
    )
}

$BoilerPlateText = [PSCustomObject]@{
    MeetupFooter    = @"
About RTPSUG:
We're a group of PowerShell pros from all walks of life who love to share ideas with fellow community members. Our meetings are open to anyone who would like to talk about and learn more about how to PowerShell!

Want to know what time this meeting is in your time zone?
$($EventInfo.TimeZoneInfo)

Notice of Event Recording:
We record all of our meetings and place the recordings on our YouTube channel a few days after our meetings. By attending this meeting, you agree to allow us to use any recordings of yourself for later use and posted in public forums such as YouTube and Reddit.
"@
    YouTubeFooter   = @"
The Research Triangle PowerShell Users Group (RTPSUG) is the largest PowerShell group in the world! We meet twice a month to discuss topics and trends related to PowerShell and automation. Our topics range from beginner to advanced concepts and give people the opportunity to learn new skills and ask questions. Our mission is to create a space for all attendees to feel welcome and be part of a community.

For more information on our group, please visit any of following links:

WEB: https://rtpsug.com
MEETUP: https://www.meetup.com/Research-Triangle-PowerShell-Users-Group
LINKEDIN: https://www.linkedin.com/company/rtpsug/
TWITTER: https://twitter.com/rtpsug
GITHUB: https://github.com/rtpsug
"@
    RecordingNotice = "We record all of our meetings and place the recordings on our YouTube channel a few days after our meetings. By attending this meeting, you agree to allow us to use any recordings of yourself for later use and posted in public forums such as YouTube and Reddit."
}

$MeetupInfo = [PSCustomObject]@{
    MeetingTitle    = $EventInfo.EventTitle
    MeetingDate     = $EventInfo.EventDate
    MeetingTime     = $EventInfo.EventTime
    Duration        = $EventInfo.EventDuration
    OnlineEvent     = $true
    OnlineEventLink = $EventInfo.VideoChatLink
    PublicLink      = 'MeetupLink'
    Description     = @"
$($EventInfo.EventDescriptionFull)

Speaker Bio:
$($SpeakerInfo.Bio)

$($BoilerPlateText.MeetupFooter)
"@


}

$SocialInfo = [PSCustomObject]@{
    TwitterBody = $($EventInfo.EventDescriptionShort)
    TwitterTags = $EventInfo.SocialTags
    TwitterLink = $MeetupInfo.PublicLink
}

$WebsiteInfo = [PSCustomObject]@{
    PostTitle = $EventInfo.EventTitle
    PostBody  = @"
Meeting Date:
$($EventInfo.EventDate)

$($EventInfo.EventDescriptionFull)

Speaker Bio:
$($SpeakerInfo.Bio)

Link to join us online:
$($EventInfo.VideoChatLink)

Recording Notice:
$($BoilerPlateText.RecordingNotice)
"@
}


$YouTubeInfo = [PSCustomObject]@{
    VideoDescription = @"
$($EventInfo.EventDescriptionFull)

Speaker Bio:
$($SpeakerInfo.Bio)

About the Research PowerShell UserGroup:
$($BoilerPlateText.YouTubeFooter)
"@
    VideoTags        = $($EventInfo.VideoTags)
}
