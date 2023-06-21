{
    #s = ""; e = $0;
    while(match($0, /[0-9]*[.][0-9][0-9][0-9]+/)) {
        p = substr($0, 1, RSTART - 1);
        m = sprintf("%.2f", substr($0, RSTART, RLENGTH));
        e = substr($0, RSTART+RLENGTH)
        $0 = p m e;
    }
    print $0
}
