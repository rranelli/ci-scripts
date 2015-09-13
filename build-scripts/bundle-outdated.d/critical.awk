BEGIN {
    print "**[CRITICAL]** Outdated *production* gems:"
}
/in groups? ".*default.*"/ {
    gsub(/ in group.*$/, "")
    print
    flag=1
}
END  {
    if (flag != 1) print "  * No outdated gems, Good job! :clap:"
}
