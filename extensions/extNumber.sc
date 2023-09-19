+ SimpleNumber {
    // Interpret the receiver as if it was a millisecond value
    // Example: 5.ms == 0.005
    ms { ^this / 1000 }
}

+ Float {
    // The default asStringPrec uses "%g". This method allows us to instead
    // use a "%f" style output.
    //
    // Example:
    //
    //  asStringPrecF(-2.08008714253083e-07) == "-0.000000208008714"
    //
    asStringPrecF { |prec = 14|
        var as, c, pre;
        as = this.abs.asString;
        // Pass through values that don't have an negative exponent
        if (as.containsi("e-").not) { ^this.asStringPrec(prec) } {
            // Otherwise split on the exponent
            c = as.split($e);
            c[0].remove($.);
            pre = if(this < 0, "-0.", "0.");
            ^[pre,
                "0".extend(c[1].asInteger.neg - 1, $0),
                c[0]].join[..(prec + pre.size - 1)]
        }
    }
}