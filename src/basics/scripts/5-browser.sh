#!/bin/sh

cat > /usr/local/bin/xdg-open << 'EOF'
#!/bin/sh

sleep SLEEP_DURATION
exec $BROWSER "$1"
EOF
sed -i "s/SLEEP_DURATION/${SLEEP_BEFORE_BROWSER}/" /usr/local/bin/xdg-open
chmod ugo+rx /usr/local/bin/xdg-open

cat > /usr/local/bin/cmd.exe << 'EOF'
#!/bin/sh

sleep SLEEP_DURATION
exec $BROWSER "$(echo $3 | sed 's|\^&|\&|g')"
EOF
sed -i "s/SLEEP_DURATION/${SLEEP_BEFORE_BROWSER}/" /usr/local/bin/cmd.exe
chmod ugo+rx /usr/local/bin/cmd.exe

out "[] xdg-open and cmd.exe browser wrapper created"
