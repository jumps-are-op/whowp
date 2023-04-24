IN = whowp
TO = /usr/local/bin

install: whowp
	cp -- "${IN}" "${TO}"

uninstall:
	rm -f -- "${TO}/${IN}"
