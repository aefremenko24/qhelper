tell application id "com.figure53.QLab.5"
    repeat with theCue in (selected of front workspace as list)
        try
            set the q name of theCue to ("LX " & q number of theCue as string)
            set the q_number of theCue to (q number of theCue)
        end try
    end repeat
end tell
