BEGIN {
    print "[Warning] Outdated *non-production* gems:"
}
! /.*default.*/ && /in groups?/ {
    gsub(/ in group.*$/, "")
    print
    flag=1
}
END {
    if (flag != 1) print "  * No outdated gems, Good job! :clap:"
}
