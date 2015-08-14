BEGIN {
    print "**[CRITICAL]** Outdated *production* gems:"
}
/in groups? ".*default.*"/ {
    gsub(/ in group.*$/, "")
    print
}
END {
    if (!NR) print "  * No outdated gems, Good job! :clap:"
}
