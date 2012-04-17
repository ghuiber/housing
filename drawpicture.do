clear
version 12
set more off
pause on
mata mata clear


// PROGRAM DEFINITIONS

// read in data on physical units of permitted housing stock
capture prog drop getUnits
program getUnits

insheet using msa_units.txt, clear
rename v1 id
rename v2 year
rename v3 month
rename v4 name
rename v5 total
rename v6 unit1
rename v7 unit2
rename v8 units34
rename v9 units5plus
rename v10 structs5plus

label variable unit1 "1-unit"
label variable unit2 "2-unit"
label variable units34 "3 or 4 units"
label variable units5plus "5 or more units"
label variable structs5plus "structures with 5 or more units"

notes: "New privately owned housing units authorized. Unadjusted by metro area."

end

// read in data on dollar valuation of the permitted housing stock
capture prog drop getValuation
program getValuation

insheet using msa_valuation.txt, clear
rename v1 id
rename v2 year
rename v3 month
rename v4 name
rename v5 total
rename v6 unit1
rename v7 unit2
rename v8 units34
rename v9 units5plus

label variable unit1 "1-unit"
label variable unit2 "2-unit"
label variable units34 "3 or 4 units"
label variable units5plus "5 or more units"

notes: "New privately owned housing units authorized valuation by metro area."
notes: "Thousands of dollars."

end

// assemble dollars and units of permitted housing stock
capture prog drop getUnitsAndDollars
program getUnitsAndDollars

tempfile units
getUnits
rename total units
collapse (sum) units, by(year month)
save "`units'", replace

tempfile dollars
getValuation
rename total dollar000s
collapse (sum) dollar000s, by(year month)
save "`dollars'", replace

merge 1:1 year month using "`units'"

replace dollar000s=dollar000s/10^5
replace units=units/10^3

label var dollar000s "Dollars (hundred millions)"
label var units      "Units (thousands)"

gen date=ym(year, month)
format date %tm

end

// draw a two-way scstter plot with time on the x-axis
capture prog drop graphTwoway
program graphTwoway

getUnitsAndDollars

local title "New housing peaked years before the bubble burst"
local note "Source: http://www.census.gov/construction/bps/historical_data/"
twoway (scatter dollar000s units date) (fpfit dollar000s date) /// 
		 (fpfit units date), ylabel(, angle(horizontal) format(%4.0fc)) ///
		 title("`title'", size(medium)) note("`note'")
graph export housing.eps, replace		 

end

// or, if you like it better, draw a ts plot
capture prog drop graphTS
program graphTS

getUnitsAndDollars
tsset date, monthly

local title "New housing peaked years before the bubble burst"
local note "Source: http://www.census.gov/construction/bps/historical_data/"
twoway (tsline dollar000s units) (fpfit dollar000s date) ///
		 (fpfit units date), ylabel(, angle(horizontal) format(%4.0fc)) ///
		 title("`title'", size(medium)) note("`note'")
graph export housing.eps, replace

end

// PROGRAM CALLS

//graphTwowayHousing
graphTS

