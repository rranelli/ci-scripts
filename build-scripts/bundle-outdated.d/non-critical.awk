BEGIN {
    print "[Warning] Outdated *non-production* gems:"
}
! /.*default.*/ && /in groups?/ {
    gsub(/ in group.*$/, "")
    print $0
}
END {
    if (!NR) print "  * No outdated gems, Good job! :clap:"
}
