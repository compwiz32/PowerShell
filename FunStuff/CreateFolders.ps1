$names = @(
    'AAA-Auto'
    'AccessOne'
    'Align'
    'Amazon'
    'Amex'
    'ATT'
    'Chase'
)



new-item -name $($NumPattern,$name -join " ")  -ItemType Directory -Path "C:\Users\mkana\Documents\Obsidian\Work\800-899 Hobbies\"
