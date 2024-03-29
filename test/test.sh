#!/bin/sh -e
# shellcheck disable=SC2016

# Made by daringcuteseal (also known as Pearl)
# Modified by jumps are op (jumpsareop@gmail.com) to work on a POSIX™ /bin/sh
# This software is under GPL version 2 and comes with ABSOLUTELY NO WARRANTY

# Configuration
dateformat="%d/%m/%Y"

info(){ printf "[1;32m===>[1m %s[m\n" "$1";}
date(){ command date "+$dateformat";}
_date(){
	curdate=$(date) curyear=${curdate##*/} curdate=${curdate%/*}
	curday=${curdate%/*} curmonth=${curdate#*/}
	case $* in
		"tomorrow")count=+1;; "yesterday")count=-1;;
		"2 days")count=+2;; "3 days")count=+3;;
		"1 year ago")echo "$curday/$curmonth/$((curyear-1))"; exit;;
		*)echo "$*: Unhandled date" >&2; exit 1;;
	esac
	# shellcheck disable=SC2086,SC1102
	curday=$((curday$count))
	[ "$curday" -lt 0 ] && curmonth=$((curmonth-1)) && curday=30
	[ "$curmonth" = 0 ] && curmonth=12 && curyear=$((curyear-1))
	echo "$curday/$curmonth/$curyear"
}

# Call Whow (assuming it's on ..)
WHOWP_PATH=${WHOWP_PATH:-../whowp}


# Generate configuration file
gen(){
	cat >rc <<-"EOF"
		icons yes
		infile "./info"
		timeformat 12
		dateformat "%a, %b %d %Y"
		dateformat_cfg "dd/mm/yyyy"
		category "test:blue" "test2"
		custom 1 '
		cat <<-_EOF_
			A custom section test
			---------------------
			Kernel : $(uname -s) $(uname -r)
			Arch   : $(uname -m)
		_EOF_
		'
		format "separator:0" "separator:1" "separator:2" "separator:3" \
			"date" "calendar" "important" "todos" "events" "scheds" "custom:1"
	EOF


	cat >info <<-EOF
		todo A to-do
		todo A to-do I have to finish today @$(date)
		todo A to-do I have to finish tomorrow @$(_date tomorrow)
		todo A to-do I have to finish in 3 days @$(_date "3 days")
		todo A to-do I forgot to do since yesterday @$(_date "yesterday")
		todo A to-do I've done @done
		todo A to-do I've done early @$(_date "3 days") @done
		todo An important to-do @important
		todo An important to-do I have to finish today @$(date) @important
		todo An important to-do I have to finish tomorrow @$(_date tomorrow) @important
		todo An important to-do I have to finish in 2 days @$(_date "2 days") @important
		todo An important to-do I forgot to do since yesterday @$(_date "yesterday") @important
		todo An important to-do I've done @important @done
		todo An important to-do I've done early @$(_date "2 days") @important @done
		todo A to-do with a category @test
		todo A to-do with a category without a color @test2
		todo A to-do with a category that I have to finish today @$(date) @test
		todo A to-do with a category that I have to finish tomorrow @$(_date tomorrow) @test
		todo A to-do with a category that I have to finish in 2 days @$(_date "2 days") @test
		todo A to-do with a category that I forgot to do since yesterday @$(_date "yesterday") @test
		todo A to-do with a category I've done @test @done
		todo A to-do with a category I've done early @$(_date "3 days") @test @done
		event @$(date) An event today
		event @$(_date "tomorrow") An event tomorrow
		event @$(_date "2 days") An event in 2 days
		event @$(date) An event today with a category @test
		event @$(date) An event today with a category without a color @test2
		event @$(_date "tomorrow") An event tomorrow @test
		event @$(_date "2 days") An event in 2 days @test
		event @$(date) An important event today @important
		event @$(_date "tomorrow") An important event tomorrow @important
		event @$(_date "2 days") An important event in 2 days @important
		event @$(_date "1 year ago") An event a year ago
		event @$(_date "1 year ago") An important event a year ago @important
		sched @ev @06:00 AM @06:30 AM Schedule every day from 06:00 AM to 06:30 AM
		sched @wd @06:00 AM @06:30 AM Schedule on weekdays from 06:00 AM to 06:30 AM
		sched @we @06:00 AM @06:30 AM Schedule on weekends from 06:00 AM to 06:30 AM
		sched @ev @08:00 AM @% Schedule without end time every day
		sched @mon @09:00 AM @10:00 AM Schedule every Monday
		sched @tue @09:00 AM @10:00 AM Schedule every Tuesday, with category @test
	EOF
}

[ "$1" != nogen ] && gen

whowp(){ "$WHOWP_PATH" -c rc "$@";}

info 'Check 1: options'
info 'Testing help'
whowp --help

#####

info 'Check 2: show commands'
info 'Testing `whowp show`'
whowp show

info 'Testing `whowp show important`'
whowp show important

info 'Testing `whowp show todos`'
whowp show todos

info 'Testing `whowp show events`'
whowp show events

#####

info 'Check 3: to-do commands'
info "Showing to-do's"
whowp show todos

info "Deleting to-do's (\`whowp todo del all\`)"
whowp todo del all

info "Showing to-do's"
whowp show todos

info 'Testing `whowp todo add "An added to-do"`'
whowp todo add "An added to-do"

info 'Testing `whowp todo add "An added to-do" @test`'
whowp todo add "An added to-do" @test

info 'Testing `whowp todo add "An added to-do" @important`'
whowp todo add "An added to-do" @important

info 'Testing `whowp todo add "An added to-do" "@$(_date tomorrow)"`'
whowp todo add "An added to-do" "@$(_date tomorrow)"

info "Showing to-do's"
whowp show todos

info 'Testing `whowp todo mark 1`'
whowp todo mark 1

info 'Testing `whowp todo mark 4`'
whowp todo mark 4

info 'Testing `whowp todo del 1`'
whowp todo del 1

info 'Testing `whowp todo del 2`'
whowp todo del 2

info "Showing to-do's"
whowp show todos


#####

info 'Check 4: events commands'
info "Showing events"
whowp show events

info 'Deleting events (`whowp event del all`)'
whowp event del all

info "Showing events"
whowp show events

info 'Testing `whowp event add "@$(date)" "An event today"`'
whowp event add "@$(date)" "An event today"

info 'Testing `whowp event add "@$(_date tomorrow)" "An event tomorrow"` @test'
whowp event add "@$(_date "tomorrow")" "An event tomorrow" @test

info 'Testing `whowp event add "@$(_date 2 days)" "An event in 2 days" @important`'
whowp event add "@$(_date "2 days")" "An event in 2 days" @important

info "Showing events"
whowp show events

info 'Testing `whowp event del 1`'
whowp event del 1

info 'Testing `whowp event del 2`'
whowp event del 2

info "Showing event's"
whowp show events


#####

info 'Check 5: schedules commands'
info "Showing schedules"
whowp show sched

info 'Deleting schedules (`whowp sched del all`)'
whowp sched del all

info "Showing schedules"
whowp show sched

info 'Testing `whowp sched add "$(date)" "A schedule today"`'
info 'Testing `whowp sched add @wd @06:00 AM @06:30 AM Schedule on weekdays from 06:00 AM to 06:30 AM`'
info 'Testing `whowp sched add @we @06:00 AM @06:30 AM Schedule on weekends from 06:00 AM to 06:30 AM`'
info 'Testing `whowp sched add @ev @08:00 AM @% Schedule without end time every day`'
info 'Testing `whowp sched add @mon @09:00 AM @10:00 AM Schedule every Monday`'
info 'Testing `whowp sched add @tue @09:00 AM @10:00 AM Schedule every Tuesday, with category @test`'
whowp sched add @wd @06:00 AM @06:30 AM Schedule on weekdays from 06:00 AM to 06:30 AM
whowp sched add @we @06:00 AM @06:30 AM Schedule on weekends from 06:00 AM to 06:30 AM
whowp sched add @ev @08:00 AM @% Schedule without end time every day
whowp sched add @mon @09:00 AM @10:00 AM Schedule every Monday
whowp sched add @tue @09:00 AM @10:00 AM Schedule every Tuesday, with category @test

info "Showing schedules"
whowp show sched

info 'Testing `whowp sched del 1`'
whowp sched del 1

info 'Testing `whowp sched del 2`'
whowp sched del 2

info "Showing schedules"
whowp show sched

info "Tests done successfully."
