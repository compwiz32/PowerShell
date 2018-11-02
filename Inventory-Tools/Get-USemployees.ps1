


get-aduser -filter "co -eq 'United States'" -prop * | select DisplayName, StreetAddress, City, Co, physicalDeliveryOfficeName, `
EMAILADDRESS, MOBILE, mobilephone, officephone | Export-Csv C:\Scripts\Output\USEmployees.csv -NoTypeInformation
